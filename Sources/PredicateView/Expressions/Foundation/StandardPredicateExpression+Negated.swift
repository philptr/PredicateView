//
//  StandardPredicateExpression+Negated.swift
//
//
//  Created by Phil Zakharchenko on 5/3/24.
//

import Foundation

extension StandardPredicateExpression where Output == Bool {
    func negated() -> any StandardPredicateExpression<Bool> {
        PredicateExpressions.Equal(
            lhs: self,
            rhs: PredicateExpressions.Value(false)
        )
    }
}
