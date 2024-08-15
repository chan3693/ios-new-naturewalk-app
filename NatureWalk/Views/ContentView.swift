//
//  ContentView.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
  
    var firedbHelper : FireDBHelper = FireDBHelper.getInstance()
    var fireAuthHelper : FireAuthHelper = FireAuthHelper.getInstance()
    
    @State private var root : RootView = .sessionList
    
    var body: some View {
        NavigationStack{
            Group{
                switch root {
                case .sessionList:
                    SessionListView()
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                case .favoritesList:
                    FavoritesListView()
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                case .purchaseList:
                    PurchaseListView()
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                case .profile:
                    ProfileView()
                        .environmentObject(firedbHelper)
                        .environmentObject(fireAuthHelper)
                }
            }
            .shareToolbar(rootView: $root)
            .environmentObject(firedbHelper)
            .environmentObject(fireAuthHelper)
        }
    }
}

