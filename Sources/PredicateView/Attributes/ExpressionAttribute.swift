//
//  ExpressionAttribute.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

public protocol ExpressionAttribute<Expr>: OperatorContainer, Hashable where Expr: SimpleExpression {
    var `operator`: Expr.Operator { get set }
    var value: Expr.AttributeValue { get set }
}

public struct StandardAttribute<Expr>: ExpressionAttribute where Expr: SimpleExpression {
    public var `operator`: Expr.Operator
    public var value: Expr.AttributeValue
}

public struct MetadataAttribute<Expr, Metadata>: ExpressionAttribute where Expr: SimpleExpression {
    public var `operator`: Expr.Operator
    public var value: Expr.AttributeValue
    public var metadata: Metadata
    
    public static func == (lhs: MetadataAttribute<Expr, Metadata>, rhs: MetadataAttribute<Expr, Metadata>) -> Bool {
        lhs.operator == rhs.operator && lhs.value == rhs.value
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.operator)
        hasher.combine(self.value)
    }
}
