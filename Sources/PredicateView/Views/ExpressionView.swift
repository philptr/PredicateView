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
    associatedtype Expr: Expression<Root>
    
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

