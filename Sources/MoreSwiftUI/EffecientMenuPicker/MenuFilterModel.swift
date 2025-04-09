//
//  MenuFilterModel.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/8/25.
//

import Foundation
import Combine

// For compatible with iOS 16, use ObservableObject rather than @Observable
public class MenuFilterModel<Element>: ObservableObject {
    public let items: [Element]
    private let isIncluded: (Element, String) throws -> Bool
    
    @Published private(set) var filteredItems: [Element] = []
    
    public init(items: [Element], _ isIncluded: @escaping (_ element: Element, _ token: String) throws -> Bool) {
        self.items = items
        self.isIncluded = isIncluded
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
