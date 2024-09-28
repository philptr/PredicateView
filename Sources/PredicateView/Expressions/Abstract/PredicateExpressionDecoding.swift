//
//  PredicateExpressionDecoding.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// Describes an ``Expression`` that is able to decode from a provided ``PredicateExpression``.
///
/// Typically, a given type should only be concerned with decoding predicates that map to itself.
/// As such, the return type in most cases should be `Self`.
///
/// However, in some cases, such as expressions containing other subexpressions, notably
/// ``LogicalExpression``, the returned ``Expression`` may be of a type different than `Self`.
public protocol PredicateExpressionDecoding<Root>: ExpressionProtocol {
    func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType,
        using decoders: [any PredicateExpressionDecoding<Root>]
    ) -> (any ExpressionProtocol<Root>)?
}

public protocol LeafPredicateExpressionDecoding<Root>: PredicateExpressionDecoding {
    func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any ExpressionProtocol<Root>)?
}

extension LeafPredicateExpressionDecoding {
    public func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType,
        using decoders: [any PredicateExpressionDecoding<Root>]
    ) -> (any ExpressionProtocol<Root>)? {
        self.decode(expression)
    }
}
