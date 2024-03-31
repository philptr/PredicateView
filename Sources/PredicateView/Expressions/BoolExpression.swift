//
//  BoolExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/3/24.
//

import SwiftUI

struct BoolExpression<Root>: SimpleExpression {
    typealias ExprView = BoolExpressionView<Root>
    
    enum Operator: String, CaseIterable {
        case `is` = "is"
        case isNot = "is not"
        
        var label: String {
            switch self {
            case .is: "Yes"
            case .isNot: "No"
            }
        }
        
        var associatedValue: Bool {
            switch self {
            case .is: true
            case .isNot: false
            }
        }
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Bool>
    let title: String
    var attribute: ExpressionAttribute<Self> = .init(operator: .is, value: true)
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)? {
        switch attribute.operator {
        case .is:
            PredicateExpressions.Equal(
                lhs: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                rhs: PredicateExpressions.Value(attribute.value)
            )
        case .isNot:
            PredicateExpressions.NotEqual(
                lhs: PredicateExpressions.KeyPath(root: input, keyPath: keyPath),
                rhs: PredicateExpressions.Value(attribute.value)
            )
        }
    }
}

struct BoolExpressionView<Root>: ExpressionView {
    typealias Expression = BoolExpression<Root>
    
    @Binding var expression: Expression
    
    var body: some View {
        TokenView(Root.self, header: {
            Text("\(expression.title) \(expression.attribute.operator.rawValue)")
        }, content: {
            Picker("Value", selection: $expression.attribute.value) {
                ForEach(Expression.Operator.allCases, id: \.self) {
                    Text($0.label)
                        .tag($0.associatedValue)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }, menu: {
            expression.operatorPickerView(using: $expression.attribute)
        })
    }
}

