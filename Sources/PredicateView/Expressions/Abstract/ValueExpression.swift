//
//  ValueExpression.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import Foundation

// MARK: - ValueExpression

public protocol ValueExpression<Root>: Expression {
    associatedtype Root
    associatedtype Value: Hashable
    
    var keyPath: KeyPath<Root, Value> { get }
    var title: String { get }
}

// MARK: - SimpleExpression

public protocol SimpleExpression<Root>: ValueExpression {
    static var defaultAttribute: ExpressionAttribute<Self> { get }
    var attribute: ExpressionAttribute<Self> { get set }
    
    static func buildPredicate<V>(
        for variable: V,
        using value: Value,
        operation: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value>
}

extension SimpleExpression {
    public var currentValue: AnyHashable { attribute }
    
    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let keyPath = PredicateExpressions.KeyPath(root: input, keyPath: keyPath)
        return Self.buildPredicate(for: keyPath, using: attribute.value, operation: attribute.operator)
    }
}

// MARK: - ExpressionWrapper

public protocol ExpressionWrapper<Root, WrappedExpression>: ValueExpression {
    associatedtype WrappedExpression: SimpleExpression<Root>
    
    var attribute: ExpressionAttribute<WrappedExpression>? { get set }
    var `operator`: Operator { get }
    
    static func buildPredicate<V>(
        for variable: V,
        using value: WrappedExpression.Value?,
        wrappedOperation: WrappedExpression.Operator?,
        operation: Operator
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
        let wrappedValue = attribute?.value
        let op = attribute?.operator
        return Self.buildPredicate(for: keyPath, using: wrappedValue, wrappedOperation: op, operation: `operator`)
    }
}

private struct ExpressionWrapperValue: Hashable {
    var op: AnyHashable
    var attribute: AnyHashable?
}
