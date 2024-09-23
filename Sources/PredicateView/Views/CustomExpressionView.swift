//
//  CustomExpressionView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI

public protocol CustomExpressionView<Root, Value, Operator>: BindableView {
    associatedtype Root
    associatedtype Value: Hashable
    associatedtype Operator: ExpressionOperator
    
    static var title: String { get }
    static var defaultValue: Value { get }
    
    static func predicate(for value: Value, operator: Operator) -> Predicate<Root>
    static func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> AnyExpression<Root>?
}

extension CustomExpressionView where Value: DefaultExpressionValueConvertible {
    public static var defaultValue: Value { .defaultExpressionValue }
}

extension CustomExpressionView {
    public static func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> AnyExpression<Root>? {
        nil
    }
}
