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
    var creationDate: Date = Date()
    var modificationDate: Date = Date()
    var title: String = ""
    var _status: Status.RawValue? = nil
    
    init() {
        self.id = UUID()
        self.creationDate = Date(timeIntervalSinceNow: .random(in: -3600 * 24 * 30...3600 * 24 * 30))
        self.modificationDate = Date(timeIntervalSinceNow: .random(in: -3600 * 24 * 30...3600 * 24 * 30))
        self.title = "Item \(Int.random(in: 1...1000))"
        self._status = Status.allCases.randomElement()!.rawValue
    }
    
    var status: Status {
        guard let _status, let status = Status(rawValue: _status) else { return .unknown }
        return status
    }
}
