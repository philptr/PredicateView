//
//  CompoundExpression.swift
//
//
//  Created by Phil Zakharchenko on 4/20/24.
//

import Foundation

// MARK: - CompoundExpression

public protocol CompoundExpression<Root>: ExpressionProtocol {
    associatedtype Root
    
    var children: [any ExpressionProtocol<Root>] { get set }
    var attribute: CompoundAttribute<Self> { get set }
}

extension CompoundExpression {
    public var currentValue: AnyHashable { CompoundExpressionValue(self) }
}

// MARK: - CompoundExpressionValue

struct CompoundExpressionValue<Expr>: Hashable where Expr: CompoundExpression {
    var rootAttribute: CompoundAttribute<Expr>
    var childAttributes: [AnyHashable]
    
    init(_ expression: Expr) {
        self.rootAttribute = expression.attribute
        self.childAttributes = expression.children.map(\.currentValue)
    }
}
