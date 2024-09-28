//
//  OperatorContainer.swift
//  
//
//  Created by Phil Zakharchenko on 3/17/24.
//

import Foundation

public protocol OperatorContainer: Equatable {
    associatedtype Expr: ExpressionProtocol
    var `operator`: Expr.Operator { get set }
}
