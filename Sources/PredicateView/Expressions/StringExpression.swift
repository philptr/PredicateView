//
//  StringExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

extension AnyExpression {
    public init(keyPath: KeyPath<Root, String>, title: String) {
        self.wrappedValue = StringExpression(keyPath: keyPath, title: title)
    }
    
    public init(keyPath: KeyPath<Root, String?>, title: String) {
        self.wrappedValue = OptionalExpression<Root, StringExpression>(keyPath: keyPath, title: title)
    }
}

struct StringExpression<Root>: ContentExpression {
    enum Operator: String, CaseIterable {
        case equals = "equals"
        case contains = "contains"
        case beginsWith = "begins with"
    }
    
    static var defaultAttribute: ExpressionAttribute<Self> { .init(operator: .contains, value: "") }
    
    var id = UUID()
    let keyPath: KeyPath<Root, String>
    let title: String
    var attribute: ExpressionAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using value: Value,
        operation: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        guard !value.isEmpty else { return nil }
        return switch operation {
        case .equals:
            PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.Value(value)
            )
        case .contains:
            PredicateExpressions.StringLocalizedStandardContains(
                root: variable,
                other: PredicateExpressions.Value(value)
            )
        case .beginsWith:
            PredicateExpressions.SequenceStartsWith(
                base: variable,
                prefix: PredicateExpressions.Value(value)
            )
        }
    }
    
    static func makeContentView(_ value: Binding<Value>) -> some View {
        TextField("Value", text: value)
    }
}
