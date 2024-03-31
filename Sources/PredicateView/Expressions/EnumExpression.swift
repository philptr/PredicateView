//
//  EnumExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/3/24.
//

import SwiftUI

struct EnumExpression<Root, EnumType>: SimpleExpression where EnumType: CaseIterable & CustomStringConvertible & Codable & Hashable & Identifiable, EnumType.AllCases: RandomAccessCollection {
    typealias ExprView = EnumExpressionView
    
    enum Operator: String, CaseIterable {
        case `is` = "is"
        case isNot = "is not"
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, EnumType>
    let title: String
    var attribute: ExpressionAttribute<Self> = .init(operator: .is, value: EnumType.allCases.first!)
    
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
    
    struct EnumExpressionView: ExpressionView {
        typealias Expression = EnumExpression<Root, EnumType>
        
        @Binding var expression: Expression
        
        var body: some View {
            TokenView(Root.self, header: {
                Text("\(expression.title) \(expression.attribute.operator.rawValue)")
            }, content: {
                Picker("Value", selection: $expression.attribute.value) {
                    CustomStringConvertibleEnumPicker<EnumType>()
                }
                .labelsHidden()
            }, menu: {
                expression.operatorPickerView(using: $expression.attribute)
            })
        }
    }
}

struct RawRepresentableEnumExpression<Root, EnumType>: SimpleExpression where EnumType: CaseIterable & RawRepresentable & Codable & Hashable, EnumType.AllCases: RandomAccessCollection, EnumType.RawValue: StringProtocol {
    typealias ExprView = EnumExpressionView
    
    enum Operator: String, CaseIterable {
        case `is` = "is"
        case isNot = "is not"
    }
    
    var id = UUID()
    let keyPath: KeyPath<Root, EnumType>
    let title: String
    var attribute: ExpressionAttribute<Self> = .init(operator: .is, value: EnumType.allCases.first!)
    
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

    struct EnumExpressionView: ExpressionView {
        typealias Expression = RawRepresentableEnumExpression<Root, EnumType>
        
        @Binding var expression: Expression
        
        var body: some View {
            TokenView(Root.self, header: {
                Text("\(expression.title) \(expression.attribute.operator.rawValue)")
            }, content: {
                Picker("Value", selection: $expression.attribute.value) {
                    RawRepresentableEnumPicker<EnumType>()
                }
                .labelsHidden()
            }, menu: {
                expression.operatorPickerView(using: $expression.attribute)
            })
        }
    }
}

fileprivate struct CustomStringConvertibleEnumPicker<EnumType>: View where EnumType: CaseIterable & Hashable & CustomStringConvertible & Identifiable, EnumType.AllCases: RandomAccessCollection {
    var body: some View {
        ForEach(EnumType.allCases, id: \.self) { option in
            Text(option.description).tag(option)
        }
    }
}

fileprivate struct RawRepresentableEnumPicker<EnumType>: View where EnumType: CaseIterable & Hashable & RawRepresentable, EnumType.AllCases: RandomAccessCollection, EnumType.RawValue: StringProtocol {
    var body: some View {
        ForEach(EnumType.allCases, id: \.self) { option in
            Text(option.rawValue).tag(option)
        }
    }
}
