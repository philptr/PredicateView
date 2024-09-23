//
//  TitledExpression.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 9/22/24.
//

import Foundation

/// A specialized expression that has a read-only title shown to the user.
public protocol TitledExpression<Root>: Expression {
    var title: String { get }
}
