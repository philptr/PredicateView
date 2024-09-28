//
//  ExpressionWrapper.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// A protocol that wraps a ``PredicateExpressionConvertible`` and provides additional functionality
/// for building predicates.
public protocol ExpressionWrapper<Root, WrappedExpression>: KeyPathExpression {
    /// The type of expression being wrapped, which must conform to ``PredicateExpressionConvertible``.
    associatedtype WrappedExpression: PredicateExpressionConvertible<Root>
    
    /// The type of attribute associated with the wrapped expression.
    associatedtype Attribute: ExpressionAttribute<WrappedExpression>
    
    /// The current attribute of the wrapped expression.
    var attribute: Attribute? { get set }
    
    /// The operator currently being used in this expression wrapper.
    var `operator`: Operator { get }
    
    /// Builds a predicate expression using the provided variable, wrapped expression, and operator.
    ///
    /// - Parameters:
    ///   - variable: The input variable to use in the predicate.
    ///   - wrappedExpression: The optional wrapped expression attribute.
    ///   - operator: The operator to use in the predicate.
    /// - Returns: An optional `StandardPredicateExpression<Bool>` representing the built predicate,
    ///   or `nil` if the predicate couldn't be built.
    static func buildPredicate<V>(
        for variable: V,
        using wrappedExpression: Attribute?,
        operator: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value>
}

extension ExpressionWrapper {
    /// A computed property that returns a type-erased representation of the current state
    /// of the expression wrapper.
    public var currentValue: AnyHashable {
        ExpressionWrapperValue(op: self.operator, attribute: self.attribute)
    }
    
    /// Builds a predicate using the input variable, the current attribute, and operator.
    ///
    /// - Parameter input: The input variable to use in the predicate.
    /// - Returns: An optional `StandardPredicateExpression<Bool>` representing the built predicate,
    ///   or `nil` if the predicate couldn't be built.
    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let keyPath = PredicateExpressions.KeyPath(root: input, keyPath: keyPath)
        return Self.buildPredicate(for: keyPath, using: attribute, operator: `operator`)
    }
}

/// A private structure used to create a hashable representation of an expression wrapper's state.
private struct ExpressionWrapperValue: Hashable {
    var op: AnyHashable
    var attribute: AnyHashable?
}
