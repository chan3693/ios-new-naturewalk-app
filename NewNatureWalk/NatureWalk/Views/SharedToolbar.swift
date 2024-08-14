//
//  SharedToolbar.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-08.
//

import SwiftUI

struct SharedToolbar : ViewModifier {
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    @Binding var rootScreen : RootView
    
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    @Environment(\.dismiss) var dismiss
    
    @State private var navigateToLogin: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Menu {
                        if !fireAuthHelper.isLoggedIn{
                            NavigationLink(destination: LoginView()
                                .environmentObject(fireAuthHelper)
                                .environmentObject(fireDBHelper)){
                                Text("Login")
                            }
                        }
                      
                        if fireAuthHelper.isLoggedIn{
                            if rootScreen != .sessionList{
                                Button{
                                    self.rootScreen = .sessionList
                                }label: {
                                    Text("Sessions List")
                                }
                            }
                            if rootScreen != .favoritesList{
                                Button{
                                    self.rootScreen = .favoritesList
                                }label: {
                                    Text("Favorites List")
                                }
                            }
                            if rootScreen != .purchaseList{
                                Button{
                                    self.rootScreen = .purchaseList
                                }label: {
                                    Text("Purchase List")
                                }
                            }
                            if rootScreen != .profile{
                                Button{
                                    self.rootScreen = .profile
                                }label: {
                                    Text("Profile")
                                }
                            }
                            Divider()
                            Button{
                                self.fireAuthHelper.signOut()
//                                message = "Sign Out Successful"
//                                showAlert = true
//                                dismiss()
                                self.rootScreen = .sessionList
                                navigateToLogin = true
                            }label: {
                                Text("Sign Out")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.blue)
                    }
                }
            }
//            .alert(isPresented: self.$showAlert){
//                Alert(title: Text("Result"), message: Text(self.message), dismissButton: .default(Text("Dismiss"))
//                )
//            }
        NavigationLink(destination: LoginView()
            .environmentObject(fireAuthHelper)
            .environmentObject(fireDBHelper),
                       isActive: $navigateToLogin) {
                       }
    }
}

extension View {
    func shareToolbar(rootView : Binding<RootView>) -> some View {
        self.modifier(SharedToolbar(rootScreen: rootView))
    }
}

