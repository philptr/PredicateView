//
//  PredicateDecodingDemoView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/28/24.
//

import SwiftData
import SwiftUI
import PredicateView

struct PredicateDecodingDemoView: View {
    @Environment(\.modelContext) private var modelContext
    @State var predicate: Predicate<Item> = #Predicate<Item> {
        $0.title.localizedStandardContains("Item")
    }
    
    @State private var savedPredicates: [Predicate<Item>] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("This demo showcases the optional capability of decoding a pre-built externally supplied `Predicate` and populating the control's UI from it. Each individual expression type, including any custom expression view types, implements decoding logic for its represented `PredicateExpression`s if it wants to participate in this behavior.")
            
            predicateView(for: $predicate)
            
            Text("You can clone the predicate you've built above, which will populate a new instance of the `PredicateView` control in the group below.")
            
            DisclosureGroup("Cloning") {
                VStack(alignment: .leading) {
                    Button("New Clone") {
                        savedPredicates.append(predicate)
                    }
                    
                    ForEach(Array($savedPredicates.enumerated()), id: \.offset) { index, $predicate in
                        predicateView(for: $predicate)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
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
