//
//  StringExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

struct StringExpression<Root>: SimpleExpression {
    typealias ExprView = StringExpressionView<Root>
    
    enum Operator: String, CaseIterable {
        case equals = "equals"
        case contains = "contains"
        case beginsWith = "begins with"
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, String>
    let title: String
    var attribute: ExpressionAttribute<Self> = .init(operator: .contains, value: "")
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)? {
        guard !attribute.value.isEmpty else { return nil }
        return switch attribute.operator {
        case .equals:
            PredicateExpressions.Equal(
                lhs: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                rhs: PredicateExpressions.Value(attribute.value)
            )
        case .contains:
            PredicateExpressions.StringLocalizedStandardContains(
                root: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                other: PredicateExpressions.Value(attribute.value)
            )
        case .beginsWith:
            PredicateExpressions.SequenceStartsWith(
                base: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                prefix: PredicateExpressions.Value(attribute.value)
            )
        }
    }
}

struct StringExpressionView<Root>: ExpressionView {
    typealias Expression = StringExpression<Root>
    
    @Binding var expression: Expression
    
    var body: some View {
        TokenView(Root.self, header: {
            Text("\(expression.title) \(expression.attribute.operator.rawValue)")
        }, content: {
            TextField("Value", text: $expression.attribute.value)
        }, menu: {
            expression.operatorPickerView(using: $expression.attribute)
        })
    }
}
