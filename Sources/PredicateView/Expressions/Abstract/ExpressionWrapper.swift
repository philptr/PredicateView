//
//  ExpressionWrapper.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

public protocol ExpressionWrapper<Root, WrappedExpression>: KeyPathExpression {
    associatedtype WrappedExpression: PredicateExpressionConvertible<Root>
    associatedtype Attribute: ExpressionAttribute<WrappedExpression>
    
    var attribute: Attribute? { get set }
    var `operator`: Operator { get }
    
    static func buildPredicate<V>(
        for variable: V,
        using wrappedExpression: Attribute?,
        operator: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value>
}

extension ExpressionWrapper {
    public var currentValue: AnyHashable {
        ExpressionWrapperValue(op: self.operator, attribute: self.attribute)
    }
    
    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let keyPath = PredicateExpressions.KeyPath(root: input, keyPath: keyPath)
        return Self.buildPredicate(for: keyPath, using: attribute, operator: `operator`)
    }
}

private struct ExpressionWrapperValue: Hashable {
    var op: AnyHashable
    var attribute: AnyHashable?
}
