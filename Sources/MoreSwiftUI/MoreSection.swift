//
//  MoreSection.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 3/14/24.
//

import SwiftUI

public extension Section where Parent : View, Footer: View {
    /// Create a section with the given collection, header, and footer view.
    ///
    /// This is a convinece init to help user to create section with following syntax:
    /// ```swift
    /// Section(list) { item in
    ///     // create section view for each item
    /// } header: {
    ///     // create header view
    /// } footer: {
    ///     // create footer view
    /// }
    /// ```
    init<Data, RowContent>(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder header: () -> Parent = EmptyView.init, @ViewBuilder footer: () -> Footer = EmptyView.init) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data : RandomAccessCollection, RowContent : View, Data.Element: Identifiable {
        self.init(content: {
            ForEach(data, id: \.id) { sectionRow in
                rowContent(sectionRow)
            }
        }, header: header, footer: footer)
    }
}

public extension Section where Parent : View, Footer == EmptyView {
    
    /// Create an expandable section with the given collection and header.
    ///
    /// This is a convinece init to help user to create section with following syntax:
    /// ```swift
    /// @State var expanded: Bool
    /// Section(list, $expanded) { item in
    ///     // create section view for each item
    /// } header: {
    ///     // create header view
    /// }
    /// ```
    init<Data, RowContent>(_ data: Data, isExpanded: Binding<Bool>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent, @ViewBuilder header: () -> Parent = EmptyView.init) where Content == ForEach<Data, Data.Element.ID, RowContent>, Data : RandomAccessCollection, RowContent : View, Data.Element: Identifiable {
        if #available(iOS 17.0, *) {
            self.init(isExpanded: isExpanded, content: {
                ForEach(data, id: \.id) { sectionRow in
                    rowContent(sectionRow)
                }
            }, header: header)
        } else {
            // Fallback on earlier versions
            self.init(content: {
                ForEach(data, id: \.id) { sectionRow in
                    rowContent(sectionRow)
                }
            }, header: header)
        }
    }
}
