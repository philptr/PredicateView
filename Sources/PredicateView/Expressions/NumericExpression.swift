//
//  NumericExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

struct NumericExpression<Root, Number>: SimpleExpression where Number: Numeric & Codable & Strideable & Hashable {
    typealias ExprView = NumericExpressionView<Root, Number>
    
    enum Operator: String, CaseIterable {
        case equals = "equals"
        case isLessThan = "is less than"
        case isGreaterThan = "is greater than"
        case isLessThanOrEqual = "is less than or equal"
        case isGreaterThanOrEqual = "is greater than or equal"
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Number>
    let title: String
    var attribute: ExpressionAttribute<Self> = .init(operator: .equals, value: 0)
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)? {
        switch attribute.operator {
        case .equals:
            return PredicateExpressions.Equal(
                lhs: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                rhs: PredicateExpressions.Value(attribute.value)
            )
        default:
            let operation: PredicateExpressions.ComparisonOperator
            switch attribute.operator {
            case .isLessThan:
                operation = .lessThan
            case .isGreaterThan:
                operation = .greaterThan
            case .isLessThanOrEqual:
                operation = .lessThanOrEqual
            case .isGreaterThanOrEqual:
                operation = .greaterThanOrEqual
            default: return nil
            }
            
            return PredicateExpressions.Comparison(
                lhs: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                rhs: PredicateExpressions.Value(attribute.value),
                op: operation
            )
        }
    }
}

struct NumericExpressionView<Root, Number>: ExpressionView where Number: Numeric & Strideable & Codable & Hashable {
    struct StepperField: View {
        let title: LocalizedStringKey
        @Binding var value: Number

        var body: some View {
            HStack(spacing: 2) {
                TextField(title, value: $value, formatter: NumberFormatter())
                    .labelsHidden()
                
                Stepper(title, value: $value)
                    .labelsHidden()
            }
        }
    }
    
    typealias Expression = NumericExpression<Root, Number>
    
    @Binding var expression: Expression
    
    var body: some View {
        TokenView(Root.self, header: {
            Text("\(expression.title) \(expression.attribute.operator.rawValue)")
        }, content: {
            StepperField(title: "Value", value: $expression.attribute.value)
        }, menu: {
            expression.operatorPickerView(using: $expression.attribute)
        })
    }
}
