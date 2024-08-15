//
//  ContentView.swift
//  NatureWalk
//
//  Created by Jacob Lee on 2024-06-25.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var isRememberMe: Bool = false
    
    @State private var showAlert: Bool = false
    
    @State private var message: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper

    var body: some View {
        NavigationStack{
            VStack {
                
                Form{
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                        .keyboardType(.default)
                        .textInputAutocapitalization(.never)
                    Toggle(isOn: $isRememberMe) {
                        Text("Remember Me")
                    }.onChange(of: isRememberMe) {
                        standardUserDefaults.set(isRememberMe, forKey: UserDefaultsKey.rememberMe.rawValue)
                    }
                    
                    Section {
                        Button(action: {
                            login()
                        }, label: {
                            Text("Login")
                        })
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Result"),
                                  message: Text(self.message),
                                  dismissButton: .default(Text("Dismiss")))
                        }
                    }
                }
            }
            .navigationTitle("Login")
            .onAppear() {
                
                isRememberMe = standardUserDefaults.bool(forKey: UserDefaultsKey.rememberMe.rawValue)
                
                if isRememberMe,
                   let savedEmail = standardUserDefaults.string(forKey: UserDefaultsKey.userEmail.rawValue),
                   let savedPassword = standardUserDefaults.string(forKey: UserDefaultsKey.userPassword.rawValue) {
                    email = savedEmail
                    password = savedPassword
                } else {
                    email = ""
                    password = ""
                }
            }
        }
        
    }
    
    private func login() {
        guard !email.isEmpty else {
            message = "Please input you email!"
            showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            message = "Please input you password!"
            showAlert = true
            return
        }
        
        fireAuthHelper.signIn(email: email, password: password) { errorMessage in
            if let errorMessage = errorMessage {
                message = errorMessage
                showAlert = true
                return
            }
            
            if isRememberMe {
                standardUserDefaults.set(email, forKey: UserDefaultsKey.userEmail.rawValue)
                standardUserDefaults.set(password, forKey: UserDefaultsKey.userPassword.rawValue)
            } else {
                standardUserDefaults.removeObject(forKey: UserDefaultsKey.userEmail.rawValue)
                standardUserDefaults.removeObject(forKey: UserDefaultsKey.userPassword.rawValue)
            }
            
//            message = "Login Successful"
//            showAlert = true
            dismiss()
        }

    }
}

//#Preview {
//    LoginView()
//}

