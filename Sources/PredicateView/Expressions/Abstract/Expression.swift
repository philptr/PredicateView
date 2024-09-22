//
//  Expression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

// MARK: - Expression

public protocol Expression<Root>: Identifiable {
    associatedtype Root
    associatedtype ExprView: ExpressionView<Self>
    associatedtype Operator: ExpressionOperator
    
    var id: UUID { get set }
    var currentValue: AnyHashable { get }
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)?
}

public protocol ExpressionOperator: CaseIterable, Hashable, RawRepresentable where RawValue == String, AllCases: RandomAccessCollection, AllCases.Index == Int { }
