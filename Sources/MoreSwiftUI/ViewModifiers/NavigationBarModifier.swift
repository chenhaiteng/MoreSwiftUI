//
//  NavigationBarModifier.swift
//  Mandala
//
//  Created by Chen Hai Teng on 1/7/24.
//

import SwiftUI

struct NavigationBarBackground<S : ShapeStyle> : ViewModifier {
    let style: S
    let supportPad: Bool
    func body(content: Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad, !supportPad {
            content
        } else {
            content.toolbarBackground(.visible, for: .navigationBar).toolbarBackground(style, for: .navigationBar)
        }
    }
    
    init(_ style: S, supportPad: Bool = false) {
        self.style = style
        self.supportPad = supportPad
    }
}

public extension View {
    func navigationBarBackground<S>(_ style : S) -> some View where S: ShapeStyle {
        modifier(NavigationBarBackground(style, supportPad: true))
    }
    
    func iOSNavigationBarBackground<S>(_ style : S) -> some View where S: ShapeStyle {
        modifier(NavigationBarBackground(style))
    }
}

#Preview {
    NavigationStack {
        NavigationLink {
            Text("Test").navigationTitle("test")
        } label: {
            Text("Test")
        }.navigationTitle("List").navigationBarBackground(Color.red)
    }
}
