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
    associatedtype Operator: CaseIterable, Hashable, RawRepresentable where Operator.RawValue == String, Operator.AllCases: RandomAccessCollection, Operator.AllCases.Index == Int
    
    var id: UUID { get set }
    var currentValue: AnyHashable { get }
    
    func buildPredicate(using input: PredicateExpressions.Variable<Root>) -> (any StandardPredicateExpression<Bool>)?
}
