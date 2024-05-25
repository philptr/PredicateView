//
//  AnyExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public typealias ExpressionCompatible = Codable & Hashable

public struct AnyExpression<Root>: Identifiable {
    public var wrappedValue: any TitledExpression<Root>
    public var title: String { wrappedValue.title }
    public var id: UUID { wrappedValue.id }
    
    @inlinable
    public init(wrappedValue: any TitledExpression<Root>) {
        self.wrappedValue = wrappedValue
    }
    
    public func copy() -> Self {
        var result = wrappedValue
        result.id = .init()
        return AnyExpression(wrappedValue: wrappedValue)
    }
}
