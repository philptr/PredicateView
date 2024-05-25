//
//  PredicateDemoView.swift
//  PredicateView
//
//  Created by Phil Zakharchenko on 2/25/24.
//

import SwiftUI

public struct PredicateDemoView: View {
    struct Model: Identifiable {
        enum EmploymentStatus: String, CaseIterable, Codable {
            case employed, unemployed, selfEmployed, student, other
        }
        
        struct Color: Identifiable, Codable, Hashable {
            enum Name: String, CaseIterable, Codable {
                case red, green, blue, purple, orange, yellow, black, white, brown, pink
            }
            
            var id = UUID()
            let name: Name
            let cost: Float
        }
        
        let id = UUID()
        let firstName: String
        let lastName: String
        let age: Int
        let location: String
        let employmentStatus: EmploymentStatus?
        let isRegistered: Bool
        let preferredColors: [Color]
        
        var fullName: String {
            firstName + " " + lastName
        }
    }
    
    @State var data: [Model]
    @State var predicate: Predicate<Model> = .true
    
    public init() {
        var data: [Model] = []
        let firstNames = ["Daniel", "Mike", "Bob", "Alice", "Eve", "John", "Doe", "Jane", "Emily", "Chris"]
        let lastNames = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Miller", "Davis", "Garcia", "Rodriguez", "Wilson"]
        let locations = ["New York", "Austin", "Atlanta", "San Francisco", "Chicago", "Los Angeles", "Seattle", "Boston", "Miami", "Denver"]

        for _ in 0..<100 {
            let firstName = firstNames.randomElement()!
            let lastName = lastNames.randomElement()!
            let age = Int.random(in: 18...60)
            let location = locations.randomElement()!
            let employmentStatus = (Model.EmploymentStatus.allCases + [nil]).randomElement()!
            let isRegistered = Bool.random()
            
            let colorCount = Int.random(in: 0..<Model.Color.Name.allCases.count)
            let preferredColors = (0..<colorCount).map { _ in
                Model.Color(name: Model.Color.Name.allCases.randomElement()!, cost: Float.random(in: 1..<10))
            }
            
            let model = Model(firstName: firstName, lastName: lastName, age: age, location: location, employmentStatus: employmentStatus, isRegistered: isRegistered, preferredColors: preferredColors)
            data.append(model)
        }
        
        self._data = State(initialValue: data)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            PredicateView(predicate: $predicate, rowTemplates: [
                .init(keyPath: \.firstName, title: "First Name"),
                .init(keyPath: \.lastName, title: "Last Name"),
                .init(keyPath: \.location, title: "Location"),
                .init(keyPath: \.age, title: "Age"),
                .init(keyPath: \.employmentStatus, title: "Employment Status"),
                .init(keyPath: \.isRegistered, title: "Registration Status"),
                .init(keyPath: \.preferredColors, title: "Preferred Colors", rowTemplates: [
                    .init(keyPath: \.name, title: "Name"),
                    .init(keyPath: \.cost, title: "Cost"),
                ])
            ])
            
            FilteredResultsTable(predicate: $predicate, data: $data)
        }
        .padding()
    }

    private struct FilteredResultsTable: View {
        @Binding var predicate: Predicate<Model>
        @Binding var data: [Model]
        
        var body: some View {
            Table(filteredData) {
                TableColumn("Full Name", value: \.fullName)
                TableColumn("Age", value: \.age.description)
                TableColumn("Location", value: \.location)
                TableColumn("Employment Status") { model in
                    if let employmentStatus = model.employmentStatus?.rawValue {
                        Text(employmentStatus)
                    } else {
                        Image(systemName: "questionmark")
                    }
                }
                TableColumn("Registered") { model in
                    Image(systemName: model.isRegistered ? "checkmark" : "xmark")
                }
                TableColumn("Preferred Colors") { model in
                    ScrollView(.horizontal) {
                        HStack(spacing: 2) {
                            ForEach(model.preferredColors) { color in
                                HStack(spacing: 2) {
                                    Text(color.name.rawValue.capitalized)
                                    Text("$" + String(format: "%.2f", color.cost))
                                        .foregroundStyle(.secondary)
                                }
                                .font(.caption)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 2)
                                .background {
                                    Capsule()
                                        .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                                        .fill(Color.accentColor.opacity(0.1))
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            
            Text("\(filteredData.count) results found")
                .font(.footnote)
        }
        
        private var filteredData: [Model] {
            try! data.filter(predicate)
        }
    }
}
