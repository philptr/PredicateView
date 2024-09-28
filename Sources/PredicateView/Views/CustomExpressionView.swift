//
//  CustomExpressionView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI

/// Describes a custom expression view component that can be used to provide a user-visible template row.
/// Before implementing a custom expression view, see if any of the built-in expression types will serve your needs.
public protocol CustomExpressionView<Root, Value, Operator>: BindableView {
    associatedtype Root
    associatedtype Value: Hashable
    associatedtype Operator: ExpressionOperator
    
    /// The user-visible title of the expression.
    static var title: String { get }
    
    /// The key path of the value in the source type.
    /// This is used by the underlying matching and predicate decoding logic.
    static var keyPath: KeyPath<Root, Value> { get }
    
    /// The default value of the expression.
    /// This value will be used by the control after the user inserts it into their predicate.
    /// Optional whenver ``Value`` conforms to ``DefaultExpressionValueConvertible``.
    static var defaultValue: Value { get }
    
    /// Given the value and the operator the user has picked, constructs a predicate that applies the expression to the ``Root`` type.
    /// This method is called whenever the user updates the part of the control corresponding to this expression, therefore operations performed within it should be relatively inexpensive.
    static func predicate(for value: Value, operator: Operator) -> Predicate<Root>
    
    /// Implement this method to allow decoding this expression from a provided ``PredicateExpression``.
    /// Implementing this method is not required, but without it, a predicate supplied externally (such as via the ``Binding``) will not be able to populate the predicate control view for this expression.
    /// This methos is effectively the inverse of `predicate(for:operator:)`.
    static func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> DecodedKeyPathExpression<Self>?
    
}

public struct DecodedKeyPathExpression<ExpressionView: CustomExpressionView> {
    public let keyPathExpression: ExpressionView.KeyPathPredicateExpression
    public let `operator`: ExpressionView.Operator
    public let value: ExpressionView.Value
    
    public init(
        keyPathExpression: ExpressionView.KeyPathPredicateExpression,
        `operator`: ExpressionView.Operator,
        value: ExpressionView.Value
    ) {
        self.keyPathExpression = keyPathExpression
        self.`operator` = `operator`
        self.value = value
    }
}

extension CustomExpressionView where Value: DefaultExpressionValueConvertible {
    /// Provides a default implementation for `defaultValue` when `Value` conforms to ``DefaultExpressionValueConvertible``.
    public static var defaultValue: Value { .defaultExpressionValue }
}

extension CustomExpressionView {
    /// Provides a default implementation for `decode(_:)` that always returns `nil`.
    public static func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> DecodedKeyPathExpression<Self>? {
        nil
    }
}

extension CustomExpressionView {
    /// A type alias for the key path predicate expression used in this custom expression view.
    public typealias KeyPathPredicateExpression = PredicateExpressions.KeyPath<PredicateExpressions.Variable<Root>, Value>
    
    /// A type alias for the value predicate expression used in this custom expression view.
    public typealias ValuePredicateExpression = PredicateExpressions.Value<Value>
}
