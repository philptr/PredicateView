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

struct StringExpression<Root>: ContentExpression {
    typealias AttributeValue = String
    
    enum Operator: String, CaseIterable {
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
    
    static func makeContentView(_ value: Binding<Value>) -> some View {
        TextField("Value", text: value)
    }
}
