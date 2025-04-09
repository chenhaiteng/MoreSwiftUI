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
            TextField(titleKey, text: $text)
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

// Appearance of Menu
private enum MenuDimension {
#if os(macOS)
    static let maxHeight: CGFloat = (NSScreen.main?.frame.height ?? 1000) * 0.8
    static let itemHeight: CGFloat = 30
#elseif os(iOS)
    static let maxHeight: CGFloat = UIScreen.main.bounds.height * 0.8
    static let itemHeight: CGFloat = 52
#endif
}

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
                                            if(tag == selection) {
                                                Image(systemName: "checkmark")
                                                    .frame(width: 40)
                                                    .foregroundStyle(Color.accentColor)
                                            } else {
                                                Spacer().frame(width: 40)
                                            }
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


private struct ModelBaseMenuBody<SelectionValue> : View where SelectionValue: Hashable {
    @Binding var selection: SelectionValue
    @Binding var isPicking: Bool
    @ObservedObject private var model: MenuFilterModel<SelectionValue>
    @State private var menuHeight: CGFloat = 30
    @State private var token: String = ""
    
    var body : some View {
        VStack {
            SearchInputField("insert to search", text: $token).frame(height: 40).padding(.horizontal, 10)
            ScrollViewReader { scroller in
                ScrollView {
                    LazyVStack {
                        if model.filteredItems.isEmpty {
                            ForEach(model.items, id: \.self) { data in
                                HStack(spacing: 0) {
                                    if(data == selection) {
                                        Image(systemName: "checkmark")
                                            .frame(width: 40)
                                            .foregroundStyle(Color.accentColor)
                                    } else {
                                        Spacer().frame(width: 40)
                                    }
                                    Text("\(data)").tag(data).frame(
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
                                    if(data == selection) {
                                        Image(systemName: "checkmark")
                                            .frame(width: 40)
                                            .foregroundStyle(Color.accentColor)
                                    } else {
                                        Spacer().frame(width: 40)
                                    }
                                    Text("\(data)").tag(data).frame(
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
                }.onAppear {
                    menuHeight = max(min(CGFloat(model.displayCount) * MenuDimension.itemHeight, MenuDimension.maxHeight), 100)
                }.frame(height: menuHeight)
                    .onChange(of: model.filteredItems) { _ in
                        menuHeight = max(min(CGFloat(model.displayCount) * MenuDimension.itemHeight, MenuDimension.maxHeight), 100)
                        
                    }
                    .onChange(of: token) { newValue in
                        model.search(newValue)
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

@available(watchOS, unavailable)
@available(macOS 13.3, iOS 16.4, *)
public struct EffecientMenuPicker<SelectionValue, Content>: View where Content: View, SelectionValue: Hashable {
    let title:String
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
                Text("\(title)").frame(minWidth: 30)
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
    
    public init(_ title: String, selection: Binding<SelectionValue>, includes: @escaping (SelectionValue) -> Bool = {_ in true}, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._selection = selection
        self.includes = includes
        self.content = content
        self.model = nil
    }
    
    public init(_ title: String, selection: Binding<SelectionValue>, model: MenuFilterModel<SelectionValue>) where Content == EmptyView {
        self.title = title
        self._selection = selection
        self.includes = { _ in true }
        self.model = model
        self.content = EmptyView.init
    }
}

@available(macOS 13.3, iOS 16.4, *)
struct PickerPreview : View {
    @State var selection: Int = 0
    @State var search: String = ""
    var items: [Int]
    @ObservedObject var model: MenuFilterModel<Int>
    var body: some View {
        VStack {
            EffecientMenuPicker("For Each Demo - Pick \(selection)", selection: $selection, includes: { element in
                guard !search.isEmpty else { return true }
                return "\(element)".contains(search)
            }) {
                SearchInputField("insert to search", text: $search).frame(height: 40).padding(.horizontal, 10)
                ForEach(0..<100) { i in
                    Text("\(i)")
                }
            }.padding(20)
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
        self.model = MenuFilterModel(items: items) { v, token in
            return String(v).contains(token)
        }
    }
}

#Preview {
    if #available(macOS 13.3, iOS 16.4, *) {
        PickerPreview()
    } else {
        // Fallback on earlier versions
    }
}
