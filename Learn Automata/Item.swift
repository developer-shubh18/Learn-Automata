//
//  Item.swift
//  Learn Automata
//
//  Created by Shubham kumar on 25/02/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
