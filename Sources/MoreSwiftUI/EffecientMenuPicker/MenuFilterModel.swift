//
//  MenuFilterModel.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/8/25.
//

import Foundation
import Combine
import SwiftUI
/**
 A protocol that requires a title method returning a localized string key.
 */
public protocol MenuDisplayable {
    func title() -> LocalizedStringKey
}

/**
 A model that provides data and filtering logic for the `EfficientMenuPicker` class.

 The `MenuFilterModel` class is used to manage a list of items and filter them based on a search token. It conforms to the `ObservableObject` protocol to allow SwiftUI views to react to changes in the filtered items.

 - Parameters:
    - Element: The type of items in the menu. Must conform to `MenuDisplayable` and `Hashable`.

 - Properties:
    - titleKey: The localized string key for the title of the search field.
    - items: The list of items to be displayed in the menu.
    - isIncluded: A closure that determines whether a given item should be included in the filtered results based on the search token.
    - filteredItems: The list of items that match the search token. This property is published to allow SwiftUI views to update when the filtered items change.

 - Methods:
    - init(_:items:_:): Initializes a new instance of `MenuFilterModel` with a title key, a list of items, and a filtering closure.
    - search(_:): Filters the items based on the given search token.
    - displayCount: The number of items to be displayed in the menu. If there are no filtered items, it returns the count of all items.
 */
public class MenuFilterModel<Element>: ObservableObject where Element: MenuDisplayable, Element: Hashable {
    public let titleKey: LocalizedStringKey
    public let items: [Element]
    private let isIncluded: (Element, String) throws -> Bool
    
    @Published private(set) var filteredItems: [Element] = []
    
    /**
     Initializes a new instance of `MenuFilterModel` with a title key, a list of items, and a filtering closure.
     
     - Parameters:
        - titleKey: The localized string key for the title of the search field. Defaults to "search".
        - items: The list of items to be displayed in the menu.
        - isIncluded: A closure that determines whether a given item should be included in the filtered results based on the search token.
     
     - Warning: The `isIncluded` closure should not capture strong references to avoid retain cycles. For example:
     ```swift
     // Good - no strong reference
     let model = MenuFilterModel("Menu", items: items) { element, token in
         return element.title().stringValue.contains(token)
     }
     
     // Bad - creates retain cycle
     let model = MenuFilterModel("Menu", items: items) { [self] element, token in
         return self.someMethod(element, token)
     }
     ```
     */
    public init(_ titleKey:LocalizedStringKey = "search", items: [Element], _ isIncluded: @escaping (_ element: Element, _ token: String) throws -> Bool) {
        self.items = items
        self.isIncluded = isIncluded
        self.titleKey = titleKey
    }
    
    public func search(_ token: String) {
        filteredItems = items.filter { element in
            (try? isIncluded(element, token)) ?? false
        }
    }
    
    public var displayCount: Int {
        filteredItems.isEmpty ? items.count : filteredItems.count
    }
}
