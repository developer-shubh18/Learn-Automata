//
//  Learn_AutomataApp.swift
//  Learn Automata
//
//  Created by Shubham kumar on 25/02/26.
//

import SwiftUI

@main
struct Learn_AutomataApp: App {
    @StateObject private var progressManager = ProgressManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
        }
    }
}
