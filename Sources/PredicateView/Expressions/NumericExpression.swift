//
//  NumericExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

public typealias NumericExpressionCompatible = Numeric & Strideable & ExpressionCompatible

extension AnyExpression {
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: NumericExpressionCompatible {
        self.init(wrappedValue: NumericExpression(keyPath: keyPath, title: title))
    }
    
    public init<T>(keyPath: KeyPath<Root, T?>, title: String) where T: NumericExpressionCompatible {
        self.init(wrappedValue: OptionalExpression<Root, NumericExpression>(keyPath: keyPath, title: title))
    }
}

struct NumericExpression<Root, Number>: ContentExpression, WrappablePredicateExpression where Number: NumericExpressionCompatible {
    typealias AttributeValue = Number
    
    enum Operator: String, ExpressionOperator {
        case equals = "equals"
        case isLessThan = "is less than"
        case isGreaterThan = "is greater than"
        case isLessThanOrEqual = "is less than or equal"
        case isGreaterThanOrEqual = "is greater than or equal"
        case isNotEqual = "is not equal"
        
        var comparisonOperator: PredicateExpressions.ComparisonOperator? {
            switch self {
            case .isLessThan: .lessThan
            case .isGreaterThan: .greaterThan
            case .isLessThanOrEqual: .lessThanOrEqual
            case .isGreaterThanOrEqual: .greaterThanOrEqual
            default: nil
            }
        }
        
        init?(_ comparisonOperator: PredicateExpressions.ComparisonOperator) {
            switch comparisonOperator {
            case .lessThan: self = .isLessThan
            case .lessThanOrEqual: self = .isLessThanOrEqual
            case .greaterThan: self = .isGreaterThan
            case .greaterThanOrEqual: self = .isGreaterThanOrEqual
            @unknown default: return nil
            }
        }
    }
    
    static var defaultAttribute: StandardAttribute<Self> {
        .init(operator: .equals, value: 0)
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, Number>
    let title: String
    var attribute: StandardAttribute<Self> = Self.defaultAttribute
    
    static func buildPredicate<V>(
        for variable: V,
        using attribute: StandardAttribute<Self>
    ) -> (any StandardPredicateExpression<Bool>)? where V: StandardPredicateExpression<Value> {
        switch attribute.operator {
        case .equals:
            return PredicateExpressions.Equal(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value)
            )
        case .isNotEqual:
            return PredicateExpressions.NotEqual(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value)
            )
        default:
            guard let comparisonOperator = attribute.operator.comparisonOperator else { return nil }
            return PredicateExpressions.Comparison(
                lhs: variable,
                rhs: PredicateExpressions.Value(attribute.value),
                op: comparisonOperator
            )
        }
    }
    
    public func decode<PredicateExpressionType: PredicateExpression<Bool>>(
        _ expression: PredicateExpressionType
    ) -> (any ExpressionProtocol<Root>)? {
        switch expression {
        case let expression as PredicateExpressions.Equal<KeyPathPredicateExpression, ValuePredicateExpression>:
            populateFromDecodedExpression(
                ifKeyPathMatches: expression.lhs,
                attribute: .init(operator: .equals, value: expression.rhs.value)
            )
        case let expression as PredicateExpressions.NotEqual<KeyPathPredicateExpression, ValuePredicateExpression>:
            populateFromDecodedExpression(
                ifKeyPathMatches: expression.lhs,
                attribute: .init(operator: .isNotEqual, value: expression.rhs.value)
            )
        case let expression as PredicateExpressions.Comparison<KeyPathPredicateExpression, ValuePredicateExpression>:
            populateFromDecodedExpression(
                ifKeyPathMatches: expression.lhs,
                attribute: .init(operator: .init(expression.op) ?? .equals, value: expression.rhs.value)
            )
        default:
            nil
        }
    }
    
    @MainActor
    static func makeContentView(_ value: Binding<Number>) -> some View {
        StepperField(title: "Value", value: value)
    }
    
    private struct StepperField: View {
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
}
