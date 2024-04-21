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
        self.wrappedValue = RawRepresentableEnumExpression(keyPath: keyPath, title: title)
    }
    
    public init<T>(keyPath: KeyPath<Root, T?>, title: String) where T: RawRepresentableExpressionCompatible, T.AllCases: RandomAccessCollection, T.RawValue: StringProtocol {
        self.wrappedValue = OptionalExpression<Root, RawRepresentableEnumExpression>(keyPath: keyPath, title: title)
    }
}

struct RawRepresentableEnumExpression<Root, EnumType>: ContentExpression where EnumType: RawRepresentableExpressionCompatible, EnumType.AllCases: RandomAccessCollection, EnumType.RawValue: StringProtocol {
    enum Operator: String, CaseIterable {
        case `is` = "is"
        case isNot = "is not"
    }
    
    static var defaultAttribute: ExpressionAttribute<Self> { .init(operator: .is, value: EnumType.allCases.first!) }
    
    var id = UUID()
    let keyPath: KeyPath<Root, EnumType>
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
