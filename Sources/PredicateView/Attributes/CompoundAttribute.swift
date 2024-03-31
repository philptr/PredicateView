//
//  CompoundAttribute.swift
//  
//
//  Created by Phil Zakharchenko on 3/17/24.
//

import Foundation

public struct CompoundAttribute<Expr>: OperatorContainer, Hashable where Expr: CompoundExpression {
    public var `operator`: Expr.Operator
}
