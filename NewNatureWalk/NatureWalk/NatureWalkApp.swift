//
//  NatureWalkApp.swift
//  NatureWalk
//
//  Created by Jacob Lee on 2024-06-25.
//

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
import FirebaseFirestore


@main
struct NatureWalkApp: App {
    
    init() {
        // initialize filebase services
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
