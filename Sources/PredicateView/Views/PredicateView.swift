//
//  PredicateView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/24/24.
//

import SwiftUI

/// A SwiftUI view that provides a user interface for building and editing predicates.
public struct PredicateView<Root>: View {
    /// The binding to the predicate being edited.
    @Binding public var predicate: Predicate<Root>
    
    /// The root logical expression that represents the current state of the predicate.
    @State private var rootExpression: LogicalExpression<Root> = .init()
    
    /// The configuration for the predicate view, including available row templates.
    @Bindable private var configuration: PredicateViewConfiguration<Root>
    
    /// Creates a new ``PredicateView`` suitable for displaying and optionally editing a provided predicate in the UI of your application.
    ///
    /// - Parameters:
    ///   - predicate: A binding to the predicate being displayed or edited.
    ///   - rowTemplates: An array of expression templates available for building the predicate.
    ///
    /// - Note: To make a ``PredicateView`` read-only, use the `disabled` modifier.
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
                Task { await buildPredicate() }
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

private extension Sequence where Element == (any ExpressionProtocol) {
    func decode<Root>(from expression: any PredicateExpression<Bool>, as root: Root.Type = Root.self) -> [any ExpressionProtocol<Root>] {
        let decoders = compactMap { $0 as? any PredicateExpressionDecoding<Root> }
        return decoders.compactMap { $0.decode(expression, using: decoders) }
    }
}
