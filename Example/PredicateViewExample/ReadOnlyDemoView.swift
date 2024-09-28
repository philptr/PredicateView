//
//  ReadOnlyDemoView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/28/24.
//

import SwiftData
import SwiftUI
import PredicateView

struct ReadOnlyDemoView: View {
    @Environment(\.modelContext) private var modelContext
    @State var predicate: Predicate<Item> = #Predicate<Item> {
        $0.title.localizedStandardContains("Item") && $0._status != "done"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            predicateView(for: $predicate)
                .disabled(true)
            
            Table(items) {
                TableColumn("Title", value: \.title)
                TableColumn("Status", value: \.status.rawValue)
                TableColumn("Created") { value in
                    Text(value.creationDate, style: .date)
                }
                TableColumn("Modified") { value in
                    Text(value.modificationDate, style: .date)
                }
            }
        }
        .padding()
    }
    
    private var items: [Item] {
        try! modelContext.fetch(.init(predicate: predicate))
    }
    
    private func predicateView(for predicate: Binding<Predicate<Item>>) -> some View {
        ScrollView(.horizontal) {
            PredicateView(predicate: predicate, rowTemplates: [
                .init(keyPath: \.title, title: "Title"),
                .init(keyPath: \.creationDate, title: "Creation date"),
                .init(keyPath: \.modificationDate, title: "Modification date"),
                .init(StatusExpressionView.self),
            ])
        }
    }
}
