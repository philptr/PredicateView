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
    
    var keyPath: KeyPath<Root, Value> { get }
}

extension KeyPathExpression {
    typealias KeyPathPredicateExpression = PredicateExpressions.KeyPath<PredicateExpressions.Variable<Root>, Value>
    typealias ValuePredicateExpression = PredicateExpressions.Value<Value>
}
