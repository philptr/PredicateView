//
//  RawRepresentableEnumExpression.swift
//  
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import SwiftUI

public typealias RawRepresentableExpressionCompatible = CaseIterable & RawRepresentable & ExpressionCompatible

extension AnyExpression {
    public init<T>(keyPath: KeyPath<Root, T>, title: String) where T: RawRepresentableExpressionCompatible, T.AllCases: RandomAccessCollection, T.RawValue: StringProtocol {
        self.init(wrappedValue: RawRepresentableEnumExpression(keyPath: keyPath, title: title))
    }
    
    public init<T>(keyPath: KeyPath<Root, T?>, title: String) where T: RawRepresentableExpressionCompatible, T.AllCases: RandomAccessCollection, T.RawValue: StringProtocol {
        self.init(wrappedValue: OptionalExpression<Root, RawRepresentableEnumExpression>(keyPath: keyPath, title: title))
    }
}

struct RawRepresentableEnumExpression<Root, EnumType>: ContentExpression, StaticPredicateExpression where EnumType: RawRepresentableExpressionCompatible, EnumType.AllCases: RandomAccessCollection, EnumType.RawValue: StringProtocol {
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
            RawRepresentableEnumPicker<EnumType>()
        }
        .labelsHidden()
    }
}

private struct RawRepresentableEnumPicker<EnumType>: View where EnumType: RawRepresentableExpressionCompatible, EnumType.AllCases: RandomAccessCollection, EnumType.RawValue: StringProtocol {
    var body: some View {
        ForEach(EnumType.allCases, id: \.self) { option in
            Text(option.rawValue).tag(option)
        }
    }
}
