//
//  PredicateViewConfiguration.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import Foundation

@Observable
final class PredicateViewConfiguration<Root> {
    var rowTemplates: [any TitledExpression<Root>]
    
    init(rowTemplates: [any TitledExpression<Root>]) {
        self.rowTemplates = rowTemplates
    }
}
