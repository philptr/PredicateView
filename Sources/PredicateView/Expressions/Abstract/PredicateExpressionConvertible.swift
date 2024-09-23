//
//  PredicateExpressionConvertible.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// Describes an ``Expression`` capable of both building a ``StandardPredicateExpression`` from
/// itself and decoding a provided ``PredicateExpression``.
public protocol PredicateExpressionConvertible<Root>: LeafPredicateExpressionDecoding {
    associatedtype Attribute: ExpressionAttribute<Self>
    associatedtype AttributeValue: Hashable
    
    static var defaultAttribute: Attribute { get }
    var attribute: Attribute { get set }
    
    func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)?
}

extension PredicateExpressionConvertible {
    public var currentValue: AnyHashable {
        attribute
    }
}

extension PredicateExpressionConvertible where Self: KeyPathExpression {
    func decoded(
        keyPath keyPathExpression: KeyPathPredicateExpression,
        attribute: @autoclosure () -> Attribute
    ) -> Self? {
        guard keyPathExpression.keyPath == keyPath else { return nil }
        var copy = self
        copy.attribute = attribute()
        return copy
    }
}
