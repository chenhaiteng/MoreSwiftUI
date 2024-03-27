//
//  BorderModifier.swift
//  Mantra
//
//  Created by Chen Hai Teng on 11/13/23.
//

import Foundation
import SwiftUI

struct CircularBorder<S: ShapeStyle>: ViewModifier {
    let shapeStyle: S
    let lineWidth: CGFloat
    func body(content: Content) -> some View {
        content.clipShape(Circle()).overlay {
            Circle().strokeBorder(shapeStyle, style: StrokeStyle(lineWidth: lineWidth))
        }
    }
}

struct RoundedBorder<S: ShapeStyle>: ViewModifier {
    let shapeStyle: S
    let conrnerRadius: CGFloat
    let lineWidth: CGFloat
    func body(content: Content) -> some View {
        content.clipShape(RoundedRectangle(cornerRadius: conrnerRadius, style: .continuous)).overlay {
            RoundedRectangle(cornerRadius: conrnerRadius, style: .continuous).strokeBorder(shapeStyle, style: StrokeStyle(lineWidth: lineWidth))
        }
    }
}

struct GlowingBorder: ViewModifier {
    let color: Color
    let lineWidth: CGFloat
    func body(content: Content) -> some View {
        guard lineWidth > 0.0 else { return AnyView(content) }
        var width = 1.0
        var newContent: AnyView = AnyView(content)
        
        while width <= lineWidth {
            newContent = AnyView(newContent.shadow(color: color, radius: width))
            width += 1.0
        }
        return newContent
    }
}


public extension View {
    func circularBorder<T: ShapeStyle>(shapeStyle: T, width:CGFloat = 1.0) -> some View {
        modifier(CircularBorder(shapeStyle: shapeStyle, lineWidth: width))
    }
    
    func roundedBorder<T: ShapeStyle>(shapeStyle: T, conrnerRadius:CGFloat = 25.0, width: CGFloat = 1.0) -> some View {
        modifier(RoundedBorder(shapeStyle: shapeStyle, conrnerRadius: conrnerRadius, lineWidth: width))
    }
    
    func glowingBorder(color: Color, lineWidth: CGFloat) -> some View {
        modifier(GlowingBorder(color:color, lineWidth: lineWidth))
    }
}
