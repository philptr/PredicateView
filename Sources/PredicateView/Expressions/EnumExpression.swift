//
//  EnumExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/3/24.
//

import SwiftUI

public typealias EnumExpressionCompatible = CaseIterable & CustomStringConvertible & Identifiable & ExpressionCompatible

extension AnyExpression {
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: EnumExpressionCompatible, T.AllCases: RandomAccessCollection {
        self.init(wrappedValue: EnumExpression(keyPath: keyPath, title: title))
    }
    
    public init<T>(keyPath: KeyPath<Root, T?>, title: String) where T: EnumExpressionCompatible, T.AllCases: RandomAccessCollection {
        self.init(wrappedValue: OptionalExpression<Root, EnumExpression>(keyPath: keyPath, title: title))
    }
}

struct EnumExpression<Root, EnumType>: ContentExpression, StaticPredicateExpression where EnumType: EnumExpressionCompatible, EnumType.AllCases: RandomAccessCollection {
    typealias AttributeValue = EnumType
    
    enum Operator: String, ExpressionOperator {
        case `is` = "is"
        case isNot = "is not"
    }
    
    static var defaultAttribute: StandardAttribute<Self> { .init(operator: .is, value: EnumType.allCases.first!) }
    
    var id = UUID()
    let keyPath: KeyPath<Root, EnumType>
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
    
    static func makeContentView(_ value: Binding<EnumType>) -> some View {
        Picker("Value", selection: value) {
            CustomStringConvertibleEnumPicker<EnumType>()
        }
        .labelsHidden()
    }
}

private struct CustomStringConvertibleEnumPicker<EnumType>: View where EnumType: EnumExpressionCompatible, EnumType.AllCases: RandomAccessCollection {
    var body: some View {
        ForEach(EnumType.allCases, id: \.self) { option in
            Text(option.description).tag(option)
        }
    }
}
