//
//  ToggleButton.swift
//
//
//  Created by Chen Hai Teng on 3/27/24.
//

import SwiftUI

/// A button to support toggle value conditionally.
public struct ToggleButton<Label> : View where Label: View {
    @ViewBuilder private let label: () -> Label
    @Binding private var isOn: Bool
    private let action: (Bool) -> Bool
    
    public var body: some View {
        Button {
            if action(!isOn) {
                isOn.toggle()
            }
        } label: {
            label()
        }
    }
    
    /// Create a toggle button.
    /// - Parameters:
    ///   - isOn: A binding to a property that determines whether the toggle is on
    ///     or off.
    ///   - action: The action to perform when the user try to toggle the value. It will return boolean value to determine if the toggle successfully or not.
    ///   - label: A view that describes the purpose of the toggle.
    public init(isOn: Binding<Bool>, action: @escaping (_ isOn: Bool) -> Bool, label: @escaping () -> Label) {
        self.label = label
        self.action = action
        self._isOn = isOn
    }
}

fileprivate struct DEMO: View {
    @State var isOn: Bool = false
    var body: some View {
        ToggleButton(isOn: $isOn) { isOn in
            debugPrint("\(isOn)")
            return true
        } label: {
            Text(isOn ? "on" : "off")
        }
    }
}

#Preview {
    DEMO()
}
