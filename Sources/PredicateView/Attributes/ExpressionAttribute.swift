//
//  ExpressionAttribute.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public struct ExpressionAttribute<Expr>: OperatorContainer, Hashable where Expr: SimpleExpression {
    public var `operator`: Expr.Operator
    public var value: Expr.Value
}
