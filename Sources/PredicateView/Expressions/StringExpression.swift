//
//  StringExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

extension AnyExpression {
    public init(keyPath: KeyPath<Root, String>, title: String) {
        self.init(wrappedValue: StringExpression(keyPath: keyPath, title: title))
    }
    
    public init(keyPath: KeyPath<Root, String?>, title: String) {
        self.init(wrappedValue: OptionalExpression<Root, StringExpression>(keyPath: keyPath, title: title))
    }
}

struct StringExpression<Root>: ContentExpression, WrappablePredicateExpression {
    typealias AttributeValue = String
    
    enum Operator: String, ExpressionOperator {
        case equals = "equals"
        case contains = "contains"
        case beginsWith = "begins with"
    }
    
    static var defaultAttribute: StandardAttribute<Self> { .init(operator: .contains, value: "") }
    
    var id = UUID()
    let keyPath: KeyPath<Root, String>
    let title: String
    var attribute: StandardAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using attribute: StandardAttribute<Self>
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        guard !attribute.value.isEmpty else { return nil }
        return switch attribute.operator {
        case .equals:
            PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value)
            )
        case .contains:
            PredicateExpressions.StringLocalizedStandardContains(
                root: variable,
                other: PredicateExpressions.Value(attribute.value)
            )
        case .beginsWith:
            PredicateExpressions.SequenceStartsWith(
                base: variable,
                prefix: PredicateExpressions.Value(attribute.value)
            )
        }
    }
    
    func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any Expression<Root>)? {
        switch expression {
        case let expression as PredicateExpressions.Equal<KeyPathPredicateExpression, ValuePredicateExpression>:
            StringExpression(
                keyPath: expression.lhs.keyPath,
                title: title,
                attribute: .init(operator: .equals, value: expression.rhs.value)
            )
        case let expression as PredicateExpressions.StringLocalizedStandardContains<KeyPathPredicateExpression, ValuePredicateExpression>:
            StringExpression(
                keyPath: expression.root.keyPath,
                title: title,
                attribute: .init(operator: .contains, value: expression.other.value)
            )
        case let expression as PredicateExpressions.SequenceStartsWith<KeyPathPredicateExpression, ValuePredicateExpression>:
            StringExpression(
                keyPath: expression.base.keyPath,
                title: title,
                attribute: .init(operator: .equals, value: expression.prefix.value)
            )
        default:
            nil
        }
    }
    
    static func makeContentView(_ value: Binding<Value>) -> some View {
        TextField("Value", text: value)
    }
}
