//
//  Item.swift
//  PredicateViewExample
//
//  Created by Phil Zakharchenko on 9/21/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    enum Status: String, CaseIterable, Codable {
        case todo, inProgress, done, unknown
    }
    
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var title: String = ""
    var _status: Status.RawValue? = nil
    
    init() {
        self.id = UUID()
        self.timestamp = Date(timeIntervalSinceNow: .random(in: -3600 * 24...3600 * 24))
        self.title = "Item \(Int.random(in: 1...1000))"
        self._status = Status.allCases.randomElement()!.rawValue
    }
    
    var status: Status {
        guard let _status, let status = Status(rawValue: _status) else { return .unknown }
        return status
    }
}