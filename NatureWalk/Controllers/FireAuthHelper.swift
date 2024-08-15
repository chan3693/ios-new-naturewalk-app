//
//  FireAuthHelper.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import Foundation
import FirebaseAuth

class FireAuthHelper : ObservableObject{
    
    @Published var user :  User?{
        didSet{
            objectWillChange.send()
        }
    }
    
    @Published var isLoggedIn : Bool = false
    
    private static var shared : FireAuthHelper?
    
    
    static func getInstance() -> FireAuthHelper{
        
        if (shared == nil){
            shared = FireAuthHelper()
        }
        
        return shared!
    }
    
    private init(){
        listenToAuthState()
    }
    
    func listenToAuthState(){
        Auth.auth().addStateDidChangeListener{ [weak self] _, user in
            guard let self = self else{
                return
            }
            
            self.user = user
            print(#function, "Auth changed : \(user?.email)")
        }
    }
    
    func signIn(email : String, password : String, completion: @escaping (_ errorMessage: String?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password){ [self] authResult, error in
            
            guard let result = authResult else{
                print(#function, "Error while signing in : \(error)")
                completion("Wrong email or password!")
                return
            }
            
            print(#function, "authResult : \(authResult)")
            
            switch authResult{
            case .none:
                print(#function, "Unable to sign in : \(authResult?.description)")
                completion("login Error!")
            case .some(_):
                print(#function, "Successfully signed in : \(authResult?.description)")
                self.user = authResult?.user
                print(#function, "logged in user : \(user?.description)")
                
                UserDefaults.standard.set(email, forKey: "KEY_EMAIL")
                
                self.resetData()
                self.isLoggedIn = true

                completion(nil)
            }
            
        }
    }
    
    func resetData(){
        FireDBHelper.getInstance().removeListener()
        FireDBHelper.getInstance().favoritesList.removeAll()
        FireDBHelper.getInstance().purchaseList.removeAll()
        FireDBHelper.getInstance().getAllFromFavList()
        FireDBHelper.getInstance().getAllPurchaseList()
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            FireDBHelper.getInstance().removeListener()
            FireDBHelper.getInstance().favoritesList.removeAll()
            FireDBHelper.getInstance().purchaseList.removeAll()
            self.isLoggedIn = false
            
        }catch let error{
            print(#function, "Unable to sign out user : \(error)")
        }
    }
    
    func checkLoggedIn(){
        if Auth.auth().currentUser != nil{
            self.isLoggedIn = true
        } else{
            self.isLoggedIn = false
        }
    }
    
}

