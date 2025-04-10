//
//  EffecientMenuPicker.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/5/25.
//

import SwiftUI

// Preference Key to get menu item count
private struct SubViewCount : PreferenceKey {
    static let defaultValue: Int = 0
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }
    typealias Value = Int
}

// Menu Component
private struct MenuLabelIcon: View {
    var body: some View {
        VStack {
            Group {
                Image(systemName:"control")
                Image(systemName: "control").rotationEffect(.degrees(180.0))
            }.font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white)
        }.padding(.all, 1)
    }
}

private struct SearchInputField: View {
    @Binding private var text: String
    private let titleKey: LocalizedStringKey
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "magnifyingglass.circle")
                .scaledToFit()
                .foregroundStyle(Color.secondary)
            TextField(titleKey, text: $text).autocorrectionDisabled()
        }.frame(height: 40).padding(.horizontal, 10)
    }
    
    init(_ title: String = "", text: Binding<String>) {
        self._text = text
        self.titleKey = LocalizedStringKey(title)
    }
    
    init(_ titleKey: LocalizedStringKey, text: Binding<String>) {
        self._text = text
        self.titleKey = titleKey
    }
}

private struct Checkmark: View {
    @State var checked: Bool
    var body: some View {
        Group {
            if(checked) {
                Image(systemName: "checkmark")
                    .foregroundStyle(Color.accentColor)
            } else {
                Spacer()
            }
        }.frame(width: 30)
    }
}

// Appearance of Menu
@usableFromInline
enum MenuDimension {
#if os(macOS)
    @usableFromInline
    static let maxHeight: CGFloat = (NSScreen.main?.frame.height ?? 1000) * 0.8
    @usableFromInline
    static let itemHeight: CGFloat = 30
#elseif os(iOS)
    @usableFromInline
    static let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    @usableFromInline
    static let itemHeight: CGFloat = 52
#endif
    @usableFromInline
    static let maxItems: Int = 1000
}

// View Modifier of Menu
private struct MenuLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
#if os(macOS)
        content.background(Color.accentColor, in: RoundedRectangle(cornerRadius: 3))
#else
        content
#endif
    }
}

@available(macOS 13.3, iOS 10.0, *)
private struct MenuBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
#if os(macOS)
        content.frame(minWidth: 120, idealWidth: 200).presentationCompactAdaptation(.popover)
#else
        content.frame(width: min(240, UIScreen.main.bounds.width*0.6), alignment: .center).background(in: RoundedRectangle(cornerRadius: 20))
#endif
    }
}

@available(macOS 13.3, iOS 16.4, *)
private struct MenuButtonStyle<MenuContent: View>: ViewModifier {
    @Binding var isPicking: Bool
    let menuContent: () -> MenuContent
    func body(content: Content) -> some View {
#if os(macOS)
        content.buttonStyle(.bordered).popover(isPresented: $isPicking, content: menuContent)
#else
        content.fullScreenCover(isPresented: $isPicking) {
            ZStack {
                menuContent()
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.primary.opacity(0.001)).onTapGesture {
                isPicking = false
            }.presentationBackground(.clear)
        }
#endif
    }
    init(isPicking: Binding<Bool>, menuContent: @escaping () -> MenuContent) {
        self._isPicking = isPicking
        self.menuContent = menuContent
    }
}

@available(macOS 13.3, iOS 10.0, *)
private extension View {
    @ViewBuilder
    func menuLabelStyle() -> some View {
        modifier(MenuLabelStyle())
    }
    @ViewBuilder
    func menuBodyStyle() -> some View {
        modifier(MenuBodyStyle())
    }
}

@available(macOS 13.3, iOS 16.4, *)
private extension View {
    @ViewBuilder
    func menuButtonStyle<MenuContent: View>(isPicking: Binding<Bool>, @ViewBuilder menuContent: @escaping () -> MenuContent) -> some View {
        modifier(MenuButtonStyle(isPicking: isPicking, menuContent: menuContent))
    }
}

@available(iOS 18.0, macOS 15.0, *)
private struct MenuBody<SelectionValue, Content> : View where SelectionValue: Hashable, Content: View {
    let content: () -> Content
    let includes: (SelectionValue) -> Bool
    @Binding var selection: SelectionValue
    @Binding var isPicking: Bool
    @State private var menuHeight: CGFloat = 30
    @State private var key = ""
    
    var body : some View {
        ScrollViewReader { scroller in
            ScrollView {
                Group(subviews: content()) { subviews in
                    ZStack {
                        LazyVStack {
                            ForEach(subviews) { subview in
                                if let tag = subview.containerValues.tag(
                                    for: SelectionValue.self
                                ) {
                                    if includes(tag) {
                                        HStack(spacing: 0) {
                                            Checkmark(checked: tag == selection)
                                            subview
                                                .frame(
                                                    maxWidth:.infinity,
                                                    alignment: .leading
                                                )
                                        }.contentShape(Rectangle()).onTapGesture {
                                            selection = tag
                                            isPicking = false
                                        }.padding(.horizontal, 5).id(tag)
                                        Divider().padding(.horizontal, 10)
                                    }
                                } else {
                                    subview.padding(.horizontal, 15)
                                    Divider().padding(.horizontal, 10)
                                }
                            }
                        }
                    }.preference(key: SubViewCount.self, value: subviews.count)
                }.padding(.vertical, 10).onPreferenceChange(SubViewCount.self) { value in
                    menuHeight = min(CGFloat(value) * MenuDimension.itemHeight, MenuDimension.maxHeight)
                }
            }.onAppear {
                scroller.scrollTo(selection, anchor: .center)
            }.frame(height: menuHeight)
        }
    }
    
    init(selection: Binding<SelectionValue>, isPicking: Binding<Bool>, includes: @escaping (SelectionValue) -> Bool = { _ in true }, content: @escaping () -> Content) {
        self.content = content
        self._selection = selection
        self._isPicking = isPicking
        self.includes = includes
    }
}

@inlinable func clamp<T: Comparable>(_ v: T, in range: Range<T>) -> T {
    max(min(v, range.upperBound), range.lowerBound)
}

@inlinable func height(of count: Int) -> CGFloat {
    clamp(CGFloat(count) * MenuDimension.itemHeight, in: 100.0..<MenuDimension.maxHeight)
}

private struct ModelBaseMenuBody<SelectionValue> : View where SelectionValue: Hashable, SelectionValue: MenuDisplayable {
    @Binding var selection: SelectionValue
    @Binding var isPicking: Bool
    @ObservedObject private var model: MenuFilterModel<SelectionValue>
    @State private var menuHeight: CGFloat = 30
    @State private var token: String = ""
    @State private var debouncedToken: String = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var isLoading: Bool = false
    
    private func handleSearch(_ newValue: String) {
        isLoading = true
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms debounce
            await MainActor.run {
                model.search(newValue)
                isLoading = false
            }
        }
    }
    
    var body : some View {
        VStack {
            SearchInputField(model.titleKey, text: $token).frame(height: 40).padding(.horizontal, 10)
            if model.items.count > MenuDimension.maxItems {
                Text("Showing first \(MenuDimension.maxItems) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            ScrollViewReader { scroller in
                ScrollView {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if model.items.isEmpty {
                        Text("No items available")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        LazyVStack {
                            if model.filteredItems.isEmpty {
                                ForEach(model.items, id: \.self) { data in
                                    HStack(spacing: 0) {
                                        Checkmark(checked: data == selection)
                                        Text(data.title()).tag(data).frame(
                                            maxWidth:.infinity,
                                            alignment: .leading
                                        )
                                    }.contentShape(Rectangle()).onTapGesture {
                                        selection = data
                                        isPicking = false
                                    }
                                    Divider().padding(.horizontal, 10)
                                }
                            } else {
                                ForEach(model.filteredItems, id: \.self)  { data in
                                    HStack(spacing: 0) {
                                        Checkmark(checked: data == selection)
                                        Text(data.title()).tag(data).frame(
                                            maxWidth:.infinity,
                                            alignment: .leading
                                        )
                                    }.contentShape(Rectangle()).onTapGesture {
                                        selection = data
                                        isPicking = false
                                    }
                                    Divider().padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                }.onAppear {
                    menuHeight = height(of: min(model.displayCount, MenuDimension.maxItems))
                }.frame(height: menuHeight)
                    .onChange(of: model.filteredItems) { _ in
                        menuHeight = height(of: min(model.displayCount, MenuDimension.maxItems))
                    }
                    .onChange(of: token) { newValue in
                        handleSearch(newValue)
                    }
            }
        }
    }
    
    init(selection: Binding<SelectionValue>, isPicking: Binding<Bool>, model: MenuFilterModel<SelectionValue>) {
        self._selection = selection
        self._isPicking = isPicking
        self.model = model
    }
}

/**
 A customizable menu picker component for SwiftUI.

 Memory Management:
 - The picker uses SwiftUI's built-in memory management
 - MenuFilterModel should be owned by the parent view to prevent retain cycles
 - Closures (includes and content) are properly marked as @escaping
 - No strong reference cycles are created by default
 - Search tasks are properly cancelled to prevent memory leaks

 Performance Considerations:
 - Uses LazyVStack for efficient list rendering
 - Implements 300ms debounced search filtering
 - Optimizes height calculations with caching
 - Uses ScrollViewReader for efficient scrolling
 - Maximum height is clamped to prevent performance issues with large lists

 Thread Safety:
 - All UI updates are performed on the main thread
 - State management is handled by SwiftUI
 - No explicit thread synchronization needed
 - Search operations are properly dispatched to the main thread

 - Example usage:
    ```swift
    // Dynamic data source
    struct ContentView: View {
        @State private var selectedItem: String = "Option 1"
        let items = ["Option 1", "Option 2", "Option 3"]

        var body: some View {
            EffecientMenuPicker("Select an option", selection: $selectedItem) {
                ForEach(items, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
        }
    }
    ```
    ```swift
    // 
    struct ContentView: View {
        @State private var selectedItem: String = "Option 1"
        private let model = MenuFilterModel("filter menu",items: ["Option 1", "Option 2", "Option 3"]) { v, token in
            return String(v).contains(token)
        }

        var body: some View {
            EffecientMenuPicker("Select an option", selection: $selectedItem, model)
        }
    }
    ```
 - Note:
    The model-based `EffecientMenuPicker` supports macOS 13.3, iOS 16.4, and later versions.
    The DSL style `EffecientMenuPicker` supports macOS 15.0, iOS 18.0, and later versions.
 - See also:
    `MenuFilterModel`
 */
@available(watchOS, unavailable)
@available(macOS 13.3, iOS 16.4, *)
public struct EffecientMenuPicker<SelectionValue, Content>: View where Content: View, SelectionValue: Hashable, SelectionValue : MenuDisplayable {
    let titleKey:LocalizedStringKey
    private let content: () -> Content
    @Binding private var selection: SelectionValue
    @State private var isPicking = false
    private var model: MenuFilterModel<SelectionValue>?
    private let includes: (SelectionValue) -> Bool
    
    public var body: some View {
        Button {
            isPicking = true
        } label: {
            HStack {
                Text(titleKey).frame(minWidth: 30)
                MenuLabelIcon().menuLabelStyle()
            }.frame(minHeight: 20)
        }.menuButtonStyle(isPicking: $isPicking) {
            if let model = model {
                ModelBaseMenuBody(selection: $selection, isPicking: $isPicking, model: model).menuBodyStyle()
            } else {
                if #available(macOS 15.0, iOS 18.0, *) {
                    MenuBody(
                        selection: $selection,
                        isPicking: $isPicking,
                        includes: includes,
                        content: content
                    ).menuBodyStyle()
                } else {
                    // Fallback on earlier versions
                    let _ = assert(false, "No model provided to picker")
                }
            }
        }
    }
    
    /**
     Initializes a new instance of `EffecientMenuPicker` with a title, selection binding, and a content view builder.

     - Parameters:
        - titleKey: The localized string key for the title of the picker.
        - selection: A binding to the selected value, which is derived from the tag of the subview in content.
        - includes: A closure that determines whether a given selection value should be included in the picker. The default value is a closure that always returns true.
        - content: A view builder that creates the content of the picker.

     Creates an `EffecientMenuPicker` that uses a DSL style to provide the data and filtering logic. The picker will display the items from the content view builder and allow the user to select an item. The selected item will be bound to the `selection` parameter.

     Example usage:
     ```swift
     struct ContentView: View {
         @State private var selectedItem: String = "Option 1"

         var body: some View {
             EffecientMenuPicker("Select an option", selection: $selectedItem) {
                 Text("Option 1").tag("Option 1")
                 Text("Option 2").tag("Option 2")
                 Text("Option 3").tag("Option 3")
             }
         }
     }
     ```
     */
    @available(macOS 15.0, iOS 18.0, *)
    public init(_ titleKey: LocalizedStringKey, selection: Binding<SelectionValue>, includes: @escaping (SelectionValue) -> Bool = {_ in true}, @ViewBuilder content: @escaping () -> Content) {
        self.titleKey = titleKey
        self._selection = selection
        self.includes = includes
        self.content = content
        self.model = nil
    }
    
    /**
     Initializes a new instance of `EffecientMenuPicker` with a title, selection binding, and a model.

     - Parameters:
        - titleKey: The localized string key for the title of the picker.
        - selection: A binding to the selected value.
        - model: The model that provides the data and filtering logic for the picker.

     Creates an `EffecientMenuPicker` that uses a model to provide the data and filtering logic. The picker will display the items from the model and allow the user to select an item. The selected item will be bound to the `selection` parameter.

     Example usage:
     ```swift
     struct ContentView: View {
         @State private var selectedItem: String = "Option 1"
         private let model = MenuFilterModel("filter menu", items: ["Option 1", "Option 2", "Option 3"]) { v, token in
             return String(v).contains(token)
         }

         var body: some View {
             EffecientMenuPicker("Select an option", selection: $selectedItem, model: model)
         }
     }
     ```
     */
    public init(_ titleKey: LocalizedStringKey, selection: Binding<SelectionValue>, model: MenuFilterModel<SelectionValue>) where Content == EmptyView {
        self.titleKey = titleKey
        self._selection = selection
        self.includes = { _ in true }
        self.model = model
        self.content = EmptyView.init
    }
}

extension Int : MenuDisplayable {
    public func title() -> LocalizedStringKey {
        return "\(self)"
    }
}
@available(macOS 13.3, iOS 16.4, *)
struct PickerPreview : View {
    @State var selection: Int = 0
    @State var search: String = ""
    var items: [Int]
    var model: MenuFilterModel<Int>
    var body: some View {
        VStack {
            if #available(iOS 18.0, macOS 15.0, *) {
                EffecientMenuPicker("For Each Demo - Pick \(selection)", selection: $selection, includes: { element in
                    guard !search.isEmpty else { return true }
                    return "\(element)".contains(search)
                }) {
                    SearchInputField("insert to search", text: $search).frame(height: 40).padding(.horizontal, 10)
                    Text("Option 1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
//                    ForEach(0..<100) { i in
//                        Text("\(i)")
//                    }
                }.padding(20)
            }
            EffecientMenuPicker(
                "Model base Demo - Pick \(selection)",
                selection: $selection,
                model: model
            )
            .padding(20)
        }.frame(maxWidth:.infinity, maxHeight: .infinity)
    }
    init() {
        self.items = Array(0..<125)
        self.model = MenuFilterModel("filter menu",items: items) { v, token in
            return String(v).contains(token)
        }
    }
}

#Preview {
    if #available(macOS 13.3, iOS 16.4, *) {
        PickerPreview()
    }
}
