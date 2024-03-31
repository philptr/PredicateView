//
//  OperatorContainer.swift
//  
//
//  Created by Phil Zakharchenko on 3/17/24.
//

import Foundation

public protocol OperatorContainer: Equatable {
    associatedtype Expr: Expression
    var `operator`: Expr.Operator { get set }
}
