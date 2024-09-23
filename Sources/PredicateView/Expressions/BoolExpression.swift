//
//  BoolExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/3/24.
//

import SwiftUI

extension AnyExpression {
    public init(keyPath: KeyPath<Root, Bool>, title: String) {
        self.init(wrappedValue: BoolExpression(keyPath: keyPath, title: title))
    }
    
    public init(keyPath: KeyPath<Root, Bool?>, title: String) {
        self.init(wrappedValue: OptionalExpression<Root, BoolExpression>(keyPath: keyPath, title: title))
    }
}

struct BoolExpression<Root>: ContentExpression, WrappablePredicateExpression {
    typealias AttributeValue = Bool
    
    enum Operator: String, ExpressionOperator {
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
    
    static var defaultAttribute: StandardAttribute<Self> { .init(operator: .is, value: true) }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Bool>
    let title: String
    var attribute: StandardAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using attribute: StandardAttribute<Self>
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        switch attribute.operator {
        case .is:
            PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value)
            )
        case .isNot:
            PredicateExpressions.NotEqual(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value)
            )
        }
    }
    
    func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any Expression<Root>)? {
        switch expression {
        case let expression as PredicateExpressions.Equal<KeyPathPredicateExpression, ValuePredicateExpression>:
            decoded(
                keyPath: expression.lhs,
                attribute: .init(operator: .is, value: expression.rhs.value)
            )
        case let expression as PredicateExpressions.NotEqual<KeyPathPredicateExpression, ValuePredicateExpression>:
            decoded(
                keyPath: expression.lhs,
                attribute: .init(operator: .isNot, value: expression.rhs.value)
            )
        default:
            nil
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
