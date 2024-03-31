//
//  Expression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

// MARK: - Expression

public protocol Expression<Root>: Identifiable {
    associatedtype Root
    associatedtype ExprView: ExpressionView<Self>
    associatedtype Operator: CaseIterable, Hashable, RawRepresentable where Operator.RawValue == String, Operator.AllCases: RandomAccessCollection
    
    var id: UUID { get set }
    var currentValue: AnyHashable { get }
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)?
}

extension Expression {
    public func operatorPickerView<Attribute: OperatorContainer>(
        using attribute: Binding<Attribute>
    ) -> some View where Attribute.Expr == Self {
        Picker("Operator", selection: attribute.operator) {
            ForEach(Self.Operator.allCases, id: \.self) { option in
                Text(option.rawValue)
                    .tag(option)
            }
        }
        .pickerStyle(.inline)
    }
    
    public func makeView(for expression: Binding<Self>) -> some ExpressionView {
        makeView(for: expression, parent: nil)
    }
    
    public func makeView(for expression: Binding<Self>, parent: Binding<LogicalExpression<Root>>?) -> some ExpressionView {
        ExprView(expression: expression, parent: parent)
    }
}

// MARK: - SimpleExpression

public protocol SimpleExpression<Root>: Expression {
    associatedtype Root
    associatedtype Value: Hashable
    
    var keyPath: KeyPath<Root, Value> { get }
    var title: String { get }
    var attribute: ExpressionAttribute<Self> { get set }
}

extension SimpleExpression {
    public var currentValue: AnyHashable { attribute }
}

// MARK: - CompoundExpression

public protocol CompoundExpression<Root>: Expression {
    associatedtype Root
    
    var children: [any Expression<Root>] { get set }
    var attribute: CompoundAttribute<Self> { get set }
}

struct CompoundExpressionValue<Expr>: Hashable where Expr: CompoundExpression {
    var rootAttribute: CompoundAttribute<Expr>
    var childAttributes: [AnyHashable]
    
    init(_ expression: Expr) {
        self.rootAttribute = expression.attribute
        self.childAttributes = expression.children.map(\.currentValue)
    }
}

extension CompoundExpression {
    public var currentValue: AnyHashable { CompoundExpressionValue(self) }
}
