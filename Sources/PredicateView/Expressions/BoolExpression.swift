//
//  BoolExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/3/24.
//

import SwiftUI

extension AnyExpression {
    public init(keyPath: KeyPath<Root, Bool>, title: String) {
        self.wrappedValue = BoolExpression(keyPath: keyPath, title: title)
    }
    
    public init(keyPath: KeyPath<Root, Bool?>, title: String) {
        self.wrappedValue = OptionalExpression<Root, BoolExpression>(keyPath: keyPath, title: title)
    }
}

struct BoolExpression<Root>: ContentExpression {
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
    
    static var defaultAttribute: ExpressionAttribute<Self> { .init(operator: .is, value: true) }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Bool>
    let title: String
    var attribute: ExpressionAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using value: Value,
        operation: Operator
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        switch operation {
        case .is:
            PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.Value(value)
            )
        case .isNot:
            PredicateExpressions.NotEqual(
                lhs: variable,
                rhs: PredicateExpressions.Value(value)
            )
        }
    }
    
    static func makeContentView(_ value: Binding<Bool>) -> some View {
        Picker("Value", selection: value) {
            ForEach(Operator.allCases, id: \.self) { expression in
                Text(expression.label)
                    .tag(expression.associatedValue)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
}
