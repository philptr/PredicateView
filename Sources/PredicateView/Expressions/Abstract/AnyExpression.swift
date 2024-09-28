//
//  AnyExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public typealias ExpressionCompatible = Codable & Hashable

/// A generic struct that wraps any type conforming to the ``TitledExpression`` protocol.
/// It provides type erasure for expressions, allowing different types of expressions
/// to be used interchangeably as long as they share the same ``Root`` type.
public struct AnyExpression<Root>: Identifiable {
    /// The underlying expression that conforms to the ``TitledExpression`` protocol.
    public var wrappedValue: any TitledExpression<Root>
    
    /// The title of the wrapped expression that may be used to be surfaced to the user within the control.
    public var title: String { wrappedValue.title }
    
    /// The unique identifier of the wrapped expression.
    public var id: UUID { wrappedValue.id }
    
    /// Initializes a new ``AnyExpression`` instance with the provided ``TitledExpression``.
    ///
    /// - Parameter wrappedValue: The expression to be wrapped.
    @inlinable
    public init(wrappedValue: any TitledExpression<Root>) {
        self.wrappedValue = wrappedValue
    }
    
    // MARK: - Internal
    
    /// Creates a copy of the ``AnyExpression`` with a new unique identifier.
    ///
    /// - Returns: A new ``AnyExpression`` instance with the same wrapped value but a new `id`.
    func copy() -> Self {
        var result = wrappedValue
        result.id = .init()
        return AnyExpression(wrappedValue: wrappedValue)
    }
}
