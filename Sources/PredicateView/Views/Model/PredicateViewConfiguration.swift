//
//  PredicateViewConfiguration.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

@Observable
final class PredicateViewConfiguration<Root> {
    var rowTemplates: [any SimpleExpression<Root>]
    var isEditable: Bool
    
    init(rowTemplates: [any SimpleExpression<Root>], isEditable: Bool) {
        self.rowTemplates = rowTemplates
        self.isEditable = isEditable
    }
}
