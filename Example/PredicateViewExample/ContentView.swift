//
//  ContentView.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import SwiftUI
import SwiftData
import PredicateView

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink("Simple Data Model") {
                    PredicateDemoView()
                        .navigationTitle("Simple Data Model")
                        .toolbarTitleDisplayMode(.inline)
                }
                
                NavigationLink("SwiftData") {
                    SwiftDataDemoView()
                        .navigationTitle("SwiftData")
                        .toolbarTitleDisplayMode(.inline)
                }
                
                NavigationLink("Custom Expressions") {
                    CustomExpressionDemoView()
                        .navigationTitle("Custom Expressions")
                        .toolbarTitleDisplayMode(.inline)
                }
                
                NavigationLink("Predicate Decoding") {
                    PredicateDecodingDemoView()
                        .navigationTitle("Predicate Decoding")
                        .toolbarTitleDisplayMode(.inline)
                }
                
                NavigationLink("Read Only") {
                    ReadOnlyDemoView()
                        .navigationTitle("Read Only")
                        .toolbarTitleDisplayMode(.inline)
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
        } detail: {
            Text("Select an item")
        }
    }
}
