//
//  ContentExpression.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import SwiftUI

// MARK: - ContentExpression

public protocol ContentExpression<Root>: SimpleExpression {
    associatedtype ExprView = ContentExpressionView<Root, Self>
    associatedtype Result: View
    
    @ViewBuilder
    static func makeContentView(_ value: Binding<Value>) -> Result
}

// MARK: - StandardValueExpressionView

public struct ContentExpressionView<Root, Expr: ContentExpression<Root>>: ExpressionView {
    public var expression: Binding<Expr>
    public init(expression: Binding<Expr>) {
        self.expression = expression
    }
    
    @ViewBuilder
    public var body: some View {
        @Binding(projectedValue: self.expression) var expression: Expr
        
        TokenView(Root.self, header: {
            Text("\(expression.title) \(expression.attribute.operator.rawValue)")
        }, content: {
            Expr.makeContentView($expression.attribute.value)
        }, menu: {
            Expr.operatorPickerView(using: $expression.attribute.operator)
        })
    }
}
