//
//  WrappablePredicateExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// Describes an ``Expression`` that can be wrapped by an ``ExpressionWrapper``, such as ``OptionalExpression``.
public protocol WrappablePredicateExpression: PredicateExpressionConvertible & KeyPathExpression {
    static func buildPredicate<V: StandardPredicateExpression<Value>>(
        for variable: V,
        using attribute: Attribute
    ) -> (any StandardPredicateExpression<Bool>)?
}

extension PredicateExpressionConvertible where Self: WrappablePredicateExpression {
    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let keyPath = PredicateExpressions.KeyPath(root: input, keyPath: keyPath)
        return Self.buildPredicate(for: keyPath, using: attribute)
    }
}
