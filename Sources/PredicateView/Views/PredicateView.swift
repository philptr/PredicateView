//
//  PredicateView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/24/24.
//

import SwiftUI

public struct PredicateView<Root>: View {
    @Binding public var predicate: Predicate<Root>
    
    @State private var rootExpression: LogicalExpression<Root> = .init(children: [])
    @Bindable private var configuration: PredicateViewConfiguration<Root>
    
    public init(predicate: Binding<Predicate<Root>>, rowTemplates: [ErasedExpression<Root>], isEditable: Bool = true) {
        self._predicate = predicate
        let templates = rowTemplates.map(\.wrappedValue)
        self.configuration = PredicateViewConfiguration(rowTemplates: templates, isEditable: isEditable)
    }
    
    public var body: some View {
        rootExpression.makeView(for: $rootExpression)
            .environment(configuration)
            .onPreferenceChange(PredicateAttributePreferenceKey.self) { _ in
                Task { buildPredicate() }
            }
    }

    private func buildPredicate() {
        predicate = Predicate<Root> { input in
            rootExpression.buildPredicate(using: input) ?? PredicateExpressions.Value(true)
        }
    }
}
