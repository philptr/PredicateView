//
//  PredicateView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/24/24.
//

import SwiftUI

public struct PredicateView<Root>: View {
    @Binding public var predicate: Predicate<Root>
    
    @State private var rootExpression: LogicalExpression<Root> = .init()
    @Bindable private var configuration: PredicateViewConfiguration<Root>
    
    public init(predicate: Binding<Predicate<Root>>, rowTemplates: [AnyExpression<Root>]) {
        self._predicate = predicate
        let templates = rowTemplates.map(\.wrappedValue)
        self.configuration = PredicateViewConfiguration(rowTemplates: templates)
    }
    
    private func updateExpression() {
        let templates = configuration.rowTemplates
        let expressions = (templates + [LogicalExpression<Root>()])
            .decode(from: predicate.expression, as: Root.self)
        
        rootExpression = if expressions.count == 1,
           let expression = expressions.first as? LogicalExpression<Root> {
            expression
        } else {
            .init(children: expressions)
        }
    }
    
    public var body: some View {
        LogicalExpression<Root>.makeView(for: $rootExpression)
            .environment(configuration)
            .onPreferenceChange(PredicateAttributePreferenceKey.self) { _ in
                Task { buildPredicate() }
            }
            .onAppear {
                updateExpression()
            }
    }

    private func buildPredicate() {
        predicate = Predicate<Root> { input in
            rootExpression.buildPredicate(using: input) ?? PredicateExpressions.Value(true)
        }
    }
}

private extension Sequence where Element == (any Expression) {
    func decode<Root>(from expression: any PredicateExpression<Bool>, as root: Root.Type = Root.self) -> [any Expression<Root>] {
        let decoders = compactMap { $0 as? any PredicateExpressionDecoding<Root> }
        return decoders.compactMap { $0.decode(expression, using: decoders) }
    }
}
