//
//  ValueExpression.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import Foundation

// MARK: - TitledExpression

public protocol TitledExpression<Root>: Expression {
    var title: String { get }
}

// MARK: - ValueExpression

public protocol ValueExpression<Root>: TitledExpression {
    associatedtype Root
    associatedtype Value: Hashable
    
    var keyPath: KeyPath<Root, Value> { get }
}

// MARK: - SimpleExpression

public protocol SimpleExpression<Root>: ValueExpression {
    associatedtype Attribute: ExpressionAttribute<Self>
    associatedtype AttributeValue: Hashable
    
    static var defaultAttribute: Attribute { get }
    var attribute: Attribute { get set }
    
    static func buildPredicate<V: StandardPredicateExpression<Value>>(
        for variable: V,
        using attribute: Attribute
    ) -> (any StandardPredicateExpression<Bool>)?
}

extension SimpleExpression {
    public var currentValue: AnyHashable {
        attribute
    }

    public func buildPredicate(
        using input: PredicateExpressions.Variable<Root>
    ) -> (any StandardPredicateExpression<Bool>)? {
        let keyPath = PredicateExpressions.KeyPath(root: input, keyPath: keyPath)
        return Self.buildPredicate(for: keyPath, using: attribute)
    }
}

// MARK: - ExpressionWrapper

public protocol ExpressionWrapper<Root, WrappedExpression>: ValueExpression {
    associatedtype WrappedExpression: SimpleExpression<Root>
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
