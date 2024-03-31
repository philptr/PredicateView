//
//  ExpressionView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 3/17/24.
//

import SwiftUI

public protocol ExpressionView<Expr>: View {
    associatedtype Root
    associatedtype Expr: Expression<Root>
    
    init(expression: Binding<Expr>)
}

extension ExpressionView {
    public init(expression: Binding<Expr>, parent: Binding<LogicalExpression<Root>>?) {
        self.init(expression: expression)
    }
}

public protocol HierarchicalExpressionView<Expr>: ExpressionView {
    init(expression: Binding<Expr>, parent: Binding<LogicalExpression<Root>>?)
}
