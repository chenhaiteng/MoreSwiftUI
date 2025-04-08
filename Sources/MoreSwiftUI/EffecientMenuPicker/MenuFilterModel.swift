//
//  MenuFilterModel.swift
//  MoreSwiftUI
//
//  Created by Chen Hai Teng on 4/8/25.
//

import Foundation

// For compatible with iOS 16, use ObservableObject rather than @Observable
public class MenuFilterModel<Element>: ObservableObject {
    public let items: [Element]
    private let isIncluded: (Element, String) throws -> Bool
    
    @Published var filteredItems: [Element] = []
    
    public init(items: [Element], _ isIncluded: @escaping (_ element: Element, _ token: String) throws -> Bool) {
        self.items = items
        self.isIncluded = isIncluded
    }
    
    public func search(_ token: String) {
        filteredItems = items.filter { element in
            (try? isIncluded(element, token)) ?? false
        }
    }
}
