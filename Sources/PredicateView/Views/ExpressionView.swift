//
//  ExpressionView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/17/24.
//

import SwiftUI

// MARK: - ExpressionView

public protocol ExpressionView<Expr>: View {
    associatedtype Root
    associatedtype Expr: ExpressionProtocol<Root>
    
    var expression: Binding<Expr> { get }
    init(expression: Binding<Expr>)
}

extension ExpressionView {
    public init(expression: Binding<Expr>, parent: Binding<LogicalExpression<Root>>?) {
        self.init(expression: expression)
    }
}

// MARK: - HierarchicalExpressionView

public protocol HierarchicalExpressionView<Expr>: ExpressionView {
    init(expression: Binding<Expr>, parent: Binding<LogicalExpression<Root>>?)
}

extension HierarchicalExpressionView {
    func childView<Element>(for child: Binding<any ExpressionProtocol<Element>>) -> some View {
        func _view<T: ExpressionProtocol>(for expression: T) -> any View where T.Root == Element {
            T.makeView(
                for: Binding(get: { child.wrappedValue as! T }, set: { child.wrappedValue = $0 })
            )
            .preference(
                key: PredicateAttributePreferenceKey.self,
                value: [expression.id: expression.currentValue]
            )
        }
        
        return AnyView(_view(for: child.wrappedValue))
    }
}
