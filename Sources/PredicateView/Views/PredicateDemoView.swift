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
            case employed
            case unemployed
            case selfEmployed
            case student
            case other
        }
        
        let id = UUID()
        let firstName: String
        let lastName: String
        let age: Int
        let location: String
        let employmentStatus: EmploymentStatus
        let isRegistered: Bool
        
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
            let employmentStatus = Model.EmploymentStatus.allCases.randomElement()!
            let isRegistered = Bool.random()
            
            let model = Model(firstName: firstName, lastName: lastName, age: age, location: location, employmentStatus: employmentStatus, isRegistered: isRegistered)
            data.append(model)
        }
        
        self._data = State(initialValue: data)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            PredicateView(predicate: $predicate, rowTemplates: [
                .init(keyPath: \.firstName, title: "First Name"),
                .init(keyPath: \.lastName, title: "Last Name"),
                .init(keyPath: \.fullName, title: "Full Name"),
                .init(keyPath: \.location, title: "Location"),
                .init(keyPath: \.age, title: "Age"),
                .init(keyPath: \.employmentStatus, title: "Employment Status"),
                .init(keyPath: \.isRegistered, title: "Registration Status")
            ])
            
            FilteredListView(predicate: $predicate, data: $data)
        }
        .padding()
    }

    private struct FilteredListView: View {
        @Binding var predicate: Predicate<Model>
        @Binding var data: [Model]
        
        var body: some View {
            Table(filteredData) {
                TableColumn("Full Name", value: \.fullName)
                TableColumn("Age", value: \.age.description)
                TableColumn("Location", value: \.location)
                TableColumn("Employment Status", value: \.employmentStatus.rawValue)
                TableColumn("Registered") { model in
                    Image(systemName: model.isRegistered ? "checkmark" : "xmark")
                }
            }
        }
        
        private var filteredData: [Model] {
            try! data.filter(predicate)
        }
    }
}
