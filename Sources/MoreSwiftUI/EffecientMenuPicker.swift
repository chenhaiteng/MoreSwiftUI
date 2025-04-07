//
//  EffecientMenuPicker.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/5/25.
//

import SwiftUI

// Preference Key to get menu item count
struct SubViewCount : PreferenceKey {
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

// Appearance of Menu
private enum MenuDimension {
#if os(macOS)
    static let maxHeight: CGFloat = (NSScreen.main?.frame.height ?? 1200)*0.5
    static let itemHeight: CGFloat = 30
#elseif os(iOS)
    static let maxHeight: CGFloat = UIScreen.main.bounds.height
    static let itemHeight: CGFloat = 52
#endif
}

struct MenuLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
#if os(macOS)
        content.background(Color.accentColor, in: RoundedRectangle(cornerRadius: 3))
#else
        content
#endif
    }
}

@available(macOS 13.3, iOS 10.0, *)
struct MenuBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
#if os(macOS)
        content.frame(minWidth: 120, idealWidth: 200).presentationCompactAdaptation(.popover)
#else
        content.frame(width: min(240, UIScreen.main.bounds.width*0.6), alignment: .center).background(in: RoundedRectangle(cornerRadius: 20))
#endif
    }
}

@available(macOS 13.3, iOS 16.4, *)
struct MenuButtonStyle<MenuContent: View>: ViewModifier {
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
extension View {
    @ViewBuilder
    public func menuLabelStyle() -> some View {
        modifier(MenuLabelStyle())
    }
    @ViewBuilder
    public func menuBodyStyle() -> some View {
        modifier(MenuBodyStyle())
    }
}

@available(macOS 13.3, iOS 16.4, *)
extension View {
    @ViewBuilder
    public func menuButtonStyle<MenuContent: View>(isPicking: Binding<Bool>, @ViewBuilder menuContent: @escaping () -> MenuContent) -> some View {
        modifier(MenuButtonStyle(isPicking: isPicking, menuContent: menuContent))
    }
}

@available(iOS 18.0, macOS 15.0, *)
private struct MenuBody<SelectionValue, Content> : View where SelectionValue: Hashable, Content: View {
    let content: () -> Content
    @Binding var selection: SelectionValue
    @Binding var isPicking: Bool
    @State private var menuHeight: CGFloat = 30
    
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
                                    }.padding(.horizontal, 5)
                                } else {
                                    subview.disabled(true).padding(.leading, 40)
                                }
                                Divider().padding(.horizontal, 10)
                            }
                        }
                    }.preference(key: SubViewCount.self, value: subviews.count)
                }.padding(.vertical, 10).onPreferenceChange(SubViewCount.self) { value in
                    menuHeight = (CGFloat(value) * MenuDimension.itemHeight)
                }
            }.onAppear {
                scroller.scrollTo(selection, anchor: .center)
            }.frame(height: menuHeight)
        }
    }
    
    init(selection: Binding<SelectionValue>, isPicking: Binding<Bool>, content: @escaping () -> Content) {
        self.content = content
        self._selection = selection
        self._isPicking = isPicking
    }
}

@available(watchOS, unavailable)
@available(macOS 15.0, iOS 18.0, *)
struct EffecientMenuPicker<SelectionValue, Content>: View where Content: View, SelectionValue: Hashable {
    let title:String
    let content: () -> Content
    @Binding var selection: SelectionValue
    @State private var isPicking = false
    
    var body: some View {
        Button {
            isPicking = true
        } label: {
            HStack {
                Text("\(title)").frame(minWidth: 30)
                MenuLabelIcon().menuLabelStyle()
            }.frame(minHeight: 20)
        }.menuButtonStyle(isPicking: $isPicking) {
            MenuBody(
                selection: $selection,
                isPicking: $isPicking,
                content: content
            )
            .menuBodyStyle()
        }
    }
    
    init(_ title: String, selection: Binding<SelectionValue>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content
    }
}

@available(iOS 18.0, macOS 15, *)
struct PickerPreview: View {
    @State var selection: Int = 0
    var body: some View {
        EffecientMenuPicker("Pick \(selection)", selection: $selection) {
            ForEach(0..<5) { i in
                Text("\(i)")
            }
        }.padding(20)
    }
}
#Preview {
    if #available(iOS 18.0, macOS 15.0, *) {
        ZStack {
            PickerPreview()
        }.frame(maxWidth:.infinity, maxHeight: .infinity)
    } else {
        // Fallback on earlier versions
    }
}
