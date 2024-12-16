//
//  ValueExpression.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import Foundation

// MARK: - KeyPathExpression

public protocol KeyPathExpression<Root>: TitledExpression {
    associatedtype Root
    associatedtype Value: Hashable
    
    /// The key path of the value in the source type.
    /// This is used by the underlying matching and predicate decoding logic.
    var keyPath: KeyPath<Root, Value> { get }
}

extension KeyPathExpression {
    typealias KeyPathPredicateExpression = PredicateExpressions.KeyPath<PredicateExpressions.Variable<Root>, Value>
    typealias ValuePredicateExpression = PredicateExpressions.Value<Value>
}

extension KeyPath: @retroactive @unchecked Sendable { }
