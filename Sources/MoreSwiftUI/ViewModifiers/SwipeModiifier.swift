//
//  SwipeModifier.swift
//  Mandala
//
//  Created by Chen Hai Teng on 12/22/23.
//

import SwiftUI

public enum SwipeDirection {
    case leftToRight(_ start: CGFloat)
    case rightToLeft(_ start: CGFloat)
    case topToBottom(_ start: CGFloat)
    case bottomToTop(_ start: CGFloat)
}

struct HPageSwipe: ViewModifier {
    let minimumDistance: CGFloat
    var onSwipe: (_ direction: SwipeDirection) -> Void
    func body(content: Content) -> some View {
        content.contentShape(Rectangle()).highPriorityGesture(DragGesture(minimumDistance: minimumDistance, coordinateSpace: .local).onEnded({ value in
            if value.translation.width > 0.0 {
                onSwipe(.leftToRight(value.startLocation.x))
            } else {
                onSwipe(.rightToLeft(value.startLocation.x))
            }
        }))
    }
    
    init(minimumDistance: CGFloat = 20.0, onSwipe: @escaping (_: SwipeDirection) -> Void) {
        self.minimumDistance = minimumDistance
        self.onSwipe = onSwipe
    }
}

struct VPageSwipe: ViewModifier {
    let minimumDistance: CGFloat
    var onSwipe: (_ direction: SwipeDirection) -> Void
    func body(content: Content) -> some View {
        content.contentShape(Rectangle()).highPriorityGesture(DragGesture(minimumDistance: minimumDistance, coordinateSpace: .local).onEnded({ value in
            if value.translation.height > 0.0 {
                onSwipe(.topToBottom(value.startLocation.y))
            } else {
                onSwipe(.bottomToTop(value.startLocation.y))
            }
        }))
    }
    
    init(minimumDistance: CGFloat = 20.0, onSwipe: @escaping (_: SwipeDirection) -> Void) {
        self.minimumDistance = minimumDistance
        self.onSwipe = onSwipe
    }
}

public extension View {
    func onHSwipe(minimumDistance: CGFloat = 20.0, _ action: @escaping (SwipeDirection)->Void) -> some View {
        modifier(HPageSwipe(minimumDistance:minimumDistance, onSwipe: action))
    }
    
    func onVSwipe(minimumDistance: CGFloat = 20.0, _ action: @escaping (SwipeDirection)->Void) -> some View {
        modifier(VPageSwipe(minimumDistance:minimumDistance, onSwipe: action))
    }
}
