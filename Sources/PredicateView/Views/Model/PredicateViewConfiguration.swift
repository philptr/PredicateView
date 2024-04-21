//
//  PredicateViewConfiguration.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

@Observable
final class PredicateViewConfiguration<Root> {
    var rowTemplates: [any ValueExpression<Root>]
    var isEditable: Bool
    
    init(rowTemplates: [any ValueExpression<Root>], isEditable: Bool) {
        self.rowTemplates = rowTemplates
        self.isEditable = isEditable
    }
}
