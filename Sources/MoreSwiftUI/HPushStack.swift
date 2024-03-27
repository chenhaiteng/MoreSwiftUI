//
//  HPushStack.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 3/19/24.
//

import SwiftUI

/// A horizontal layout to push its subviews from the leading.
public struct HPushStack : Layout {
    let alignment: VerticalAlignment
    let spacing: CGFloat
    let reversed: Bool
    
//    struct CatchData {
//        let offsets: [CGFloat]
//    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        if let w = proposal.width, let h = proposal.height {
            return CGSize(width: w, height: h)
        }
        
        let sizes = subviews.map { $0.sizeThatFits(.unspecified)
        }
        
        if let w = proposal.width {
            let h = sizes.max { $0.height < $1.height }?.height ?? 0.0
            return CGSize(width: w, height: h)
        }
        
        if let h = proposal.height {
            let w = sizes.reduce(0.0) { $1.width + $0 + spacing } - spacing
            return CGSize(width: w, height: h)
        }
        
        return CGSize(width: CGFloat.infinity, height: .infinity)
    }
    
    private func alignment(for viewSize:CGSize, height: CGFloat) -> CGFloat {
        switch alignment {
        case .top:
            return 0.0
        case .bottom:
            return (height - viewSize.height)
        default:
            return (height - viewSize.height)/2.0
        }
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let sorted = subviews.sorted { $0.priority > $1.priority }
        if reversed {
            origin.x = bounds.maxX
            for view in sorted.reversed() {
                let viewSize = view.sizeThatFits(.unspecified)
                let offseted = CGPoint(x: origin.x - viewSize.width, y: origin.y + alignment(for: viewSize, height: bounds.height))
                view.place(at: offseted, proposal: proposal)
                origin.x -= (viewSize.width + spacing)
            }
        } else {
            for view in sorted {
                let viewSize = view.sizeThatFits(proposal)
                let offseted = CGPoint(x: origin.x, y: origin.y + alignment(for: viewSize, height: bounds.height))
                view.place(at: offseted, proposal: proposal)
                origin.x += (viewSize.width + spacing)
            }
        }
    }
    
    public init(spacing: CGFloat = 10.0, alignment: VerticalAlignment = .center, reversed: Bool = false) {
        self.spacing = spacing
        self.alignment = alignment
        self.reversed = reversed
    }
}

#Preview {
    VStack(spacing:10.0) {
        ForEach(0..<2, id: \.self) { index in
            HPushStack(alignment: .top, reversed: index != 0) {
                Text("ABC").border(.gray, width: 2.0)
                Button {
                    
                } label: {
                    Text("E")
                }.border(.gray, width: 2.0)
            }.border(Color.red)
            HPushStack(reversed: index != 0) {
                Text("ABC").border(.gray, width: 2.0)
                Button {
                    
                } label: {
                    Text("E")
                }.border(.gray, width: 2.0)
            }.border(Color.green).padding()
            HPushStack(alignment: .bottom, reversed: index != 0) {
                Text("ABC").layoutPriority(100.0).border(.gray, width: 2.0)
                Button {
                    
                } label: {
                    Text("E")
                }.border(.gray, width: 2.0).layoutPriority(150.0)
            }.border(Color.blue)
        }
    }
}
