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
