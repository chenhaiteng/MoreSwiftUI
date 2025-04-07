//
//  EffecientMenuPicker.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/5/25.
//

import SwiftUI

struct SubViewCount : PreferenceKey {
    static let defaultValue: Int = 0
    static func reduce(value: inout Int, nextValue: () -> Int) {
        value += nextValue()
    }
    typealias Value = Int
}

@available(iOS 18.0, macOS 15.0, *)
private struct CommonImplementation<SelectionValue, Content> : View where SelectionValue: Hashable, Content: View {
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
                                                .foregroundStyle(Color.blue)
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
                    menuHeight = CGFloat(value) * 30
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


#if os(iOS) || targetEnvironment(macCatalyst)
@available(macOS, unavailable)
@available(iOS 18.0, *)
struct PickerImplementation<SELECTION: Hashable, Content: View>: View {
    let title:String
    let content: () -> Content
    @Binding var selection: SELECTION
    @State private var isPicking = false
    @Namespace var tranisitionNS
    var body: some View {
        Button {
            isPicking = true
        } label: {
            HStack {
                Text("\(title)").frame(minWidth: 30, idealWidth: 80)
                VStack {
                    Group {
                        Image(systemName:"control")
                        Image(systemName: "control").rotationEffect(.degrees(180.0))
                    }.font(.system(size: 10, weight: .bold))
                }.padding(.all, 1)
            }.frame(minHeight: 20)
        }.id("menu").buttonStyle(.borderless).fullScreenCover(
            isPresented: $isPicking
        ) {
            ZStack {
                CommonImplementation(selection: $selection,
                                     isPicking: $isPicking,
                                     content: content).frame(width: min(240,  UIScreen.main.bounds.width*0.6), alignment: .center).background(
                                        in: RoundedRectangle(cornerRadius: 20)
                                     )
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.primary.opacity(0.001)).onTapGesture {
                isPicking = false
            }.presentationBackground(.clear)
        }
    }
    
    init(_ title: String, selection: Binding<SELECTION>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content
    }
}
#endif

#if os(macOS)
@available(macOS 15.0, *)
struct PickerImplementation<SELECTION: Hashable, Content: View>: View {
    let title:String
    let content: () -> Content
    @Binding var selection: SELECTION
    @State private var isPicking = false
    
    var body: some View {
        Button {
            isPicking = true
        } label: {
            HStack {
                Text("\(title)").frame(minWidth: 30, idealWidth: 80)
                VStack {
                    Group {
                        Image(systemName:"control")
                        Image(systemName: "control").rotationEffect(.degrees(180.0))
                    }.font(.system(size: 10, weight: .bold))
                }.padding(.all, 1).background(Color.blue, in: RoundedRectangle(cornerRadius: 3))
            }.frame(minHeight: 20)
        }.buttonStyle(.bordered).popover(isPresented: $isPicking) {
            CommonImplementation(selection: $selection,
                                 isPicking: $isPicking,
                                 content: content).frame(minWidth: 120, idealWidth: 200).presentationCompactAdaptation(.popover)
        }
    }
    
    init(_ title: String, selection: Binding<SELECTION>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content
    }
}
#endif

@available(macOS 15.0, iOS 18.0, *)
struct EffecientMenuPicker<SelectionValue, Content>: View where Content: View, SelectionValue: Hashable{
    let title:String
    let content: () -> Content
    @Binding var selection: SelectionValue
    
    var body: some View {
        PickerImplementation(title, selection: $selection, content: content)
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
            ForEach(0..<20) { i in
                Text("\(i)")
            }
        }.padding(20)
    }
}
#Preview {
    if #available(iOS 18.0, macOS 15.0, *) {
        ZStack {
            PickerPreview()
        }.frame(maxWidth:.infinity, maxHeight: .infinity).background(Color.red)
    } else {
        // Fallback on earlier versions
    }
}
