//
//  FireDBHelper.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FireDBHelper : ObservableObject{
    
    @Published var sessionList = [Session]()
    @Published var favoritesList = [Session]()
    @Published var userProfile = Profile()
    @Published var purchaseList = [Session]()
    
    private static var shared : FireDBHelper?
    
    private let db : Firestore
    
    private let COLLECTION_USER : String = "User_Collection"
    private let COLLECTION_FAVORITES: String = "Favorites_List"
    private let COLLECTION_PURCHASE: String = "Purchase_List"
    private var sessionListener: ListenerRegistration?
    private var favoritesListener: ListenerRegistration?
    private var purchaseListener: ListenerRegistration?
    
    init(db : Firestore){
        self.db = db
    }
    
    static func getInstance() -> FireDBHelper{
        if(shared == nil){
            shared = FireDBHelper(db: Firestore.firestore())
        }
        return shared!
    }
    
    func removeListener() {
        sessionListener?.remove()
        sessionListener = nil
        favoritesListener?.remove()
        favoritesListener = nil
        purchaseListener?.remove()
        purchaseListener = nil
    }
        
    func getAllPublishedSessions(){
        do{
            self.sessionListener = self.db
                .collection("Session")
                .addSnapshotListener({ (querySnapshot, error) in
                    guard let snapshot = querySnapshot else{
                        print(#function, "No result received from firestore : \(error)")
                        return
                    }
                    snapshot.documentChanges.forEach{ (docChange) in
                        do{
                            print(#function, "docChange : \(docChange)")
                            print(#function, "docChange.document : \(docChange.document)")
                            print(#function, "docChange.document.data() : \(docChange.document.data())")
                            print(#function, "docChange.document.documentID : \(docChange.document.documentID)")
                            
                            var session : Session = try docChange.document.data(as: Session.self)
                            
                            session.id = docChange.document.documentID
                            
                            print(#function, "Session : \(session)")
                            
                            let matchedIndex = self.sessionList.firstIndex(where: {( $0.id?.elementsEqual(session.id!) )! })
                            
                            switch(docChange.type){
                            case .added:
                                print(#function, "Document added : \(docChange.document.documentID) (\(session.name)")
                                
                                if (matchedIndex == nil){
                                    self.sessionList.append(session)
                                }
                                
                            case .modified:
                                print(#function, "Document modified : \(docChange.document.documentID) (\(session.name)")
                                
                                if (matchedIndex != nil){
                                    self.sessionList[matchedIndex!] = session
                                }
                                
                            case .removed:
                                print(#function, "Document deleted : \(docChange.document.documentID) (\(session.name)")
                                
                                if (matchedIndex != nil){
                                    self.sessionList.remove(at: matchedIndex!)
                                }
                            }
                            
                        }catch let error{
                            print(#function, "Unable to access docment change : \(docChange)")
                        }
                    }
                })
        }catch let error{
            print(#function, "Unable to retrieve the documents from firestore : \(error)")
        }
    }
    
    func insertToFavList(newSession : Session, uuid : String){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                try self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITES)
                    .document(uuid)
                    .getDocument{(document, error) in
                        if let document = document, document.exists {
                            print(#function, "\(uuid) already exists in fav db")
                        } else if let error = error {
                            print(#function, "Error in checking doc : \(error)")
                        } else {
                            do{
                                try self.db
                                    .collection(self.COLLECTION_USER)
                                    .document(loggedInUserEmail)
                                    .collection(self.COLLECTION_FAVORITES)
                                    .document(uuid)
                                    .setData(from: newSession)
                                print(#function, "\(uuid) added to fav db")
                            } catch let error{
                                print(#function, "Error in adding doc : \(error)")
                            }
                        }
                    }
            }catch let error{
                print(#function, "Unable to insert the document to firestore : \(error)")
            }
        }
        
    }
    
    func getAllFromFavList(){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        print(#function, "loggedInUSerEmail : \(loggedInUserEmail)")
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                self.favoritesListener = self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITES)
                    .addSnapshotListener({ (querySnapshot, error) in
                        
                        guard let snapshot = querySnapshot else{
                            print(#function, "No result received from firestore : \(error)")
                            return
                        }
                        snapshot.documentChanges.forEach{ (docChange) in
                            do{
                                print(#function, "docChange : \(docChange)")
                                print(#function, "docChange.document : \(docChange.document)")
                                print(#function, "docChange.document.data() : \(docChange.document.data())")
                                print(#function, "docChange.document.documentID : \(docChange.document.documentID)")
                                
                                var session : Session = try docChange.document.data(as: Session.self)
                                session.id = docChange.document.documentID
                                
                                print(#function, "Session : \(session)")
                                
                                let matchedIndex = self.favoritesList.firstIndex(where: {( $0.id?.elementsEqual(session.id!) )! })
                                
                                switch(docChange.type){
                                case .added:
                                    print(#function, "Document added : \(docChange.document.documentID) (\(session.name)")
                                    
                                    if (matchedIndex == nil){
                                        self.favoritesList.append(session)
                                    }
                                case .modified:
                                    print(#function, "Document modified : \(docChange.document.documentID) (\(session.name)")
                                    if (matchedIndex != nil){
                                        self.favoritesList[matchedIndex!] = session
                                    }
                                case .removed:
                                    print(#function, "Document deleted : \(docChange.document.documentID) (\(session.name)")
                                    
                                    if (matchedIndex != nil){
                                        self.favoritesList.remove(at: matchedIndex!)
                                    }
                                }
                            }catch let error{
                                print(#function, "Unable to access docment change : \(docChange)")
                            }
                        }
                    })
            }catch let error{
                print(#function, "Unable to retrieve the documents from firestore : \(error)")
            }
        }
    }
    
    func deleteFromFavList(sessionToDelete : Session){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                self.db.collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_FAVORITES)
                    .document(sessionToDelete.id!)
                    .delete{ error in
                        
                        if let err = error {
                            print(#function, "Unable to delete document : \(err)")
                        }else{
                            print(#function, "Successfully deleted document : \(sessionToDelete.id) (\(sessionToDelete.name))")
                        }
                    }
                
            }catch let error{
                print(#function, "Unable to delete the documents from firestore : \(error)")
            }
        }
    }
    
    // MARK: - user Profile
    
    func getUserProfile() {
       
        guard let uid = Auth.auth().currentUser?.uid,
              let email = Auth.auth().currentUser?.email else {
            print(#function, "NO logged in user")
            return
        }
        
        self.db.collection(COLLECTION_USER)
            .document(email)
            .addSnapshotListener({ documentSnapshot, error in
                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                    // insert
                    print(#function, "no document, inset default profile with email:\(email)")
                    return
                }
                do {
                    var profile : Profile = try documentSnapshot.data(as: Profile.self)
                    
                    profile.id = documentSnapshot.documentID
                    self.userProfile = profile
                    print(#function, "userProfile : \(profile)")
                } catch let error{
                    print(#function, "Unable to access docment change : \(documentSnapshot), error\(error)")
                }
                
            })
        
    }
    
    func updateProfile(_ profile : Profile, complete: @escaping (Bool) -> Void){

        guard let email = Auth.auth().currentUser?.email else {
            print(#function, "NO logged in user")
            complete(false)
            return
        }
        
        self.db.collection(COLLECTION_USER)
            .document(email)
            .updateData(
                ["email" : profile.email,
                 "name": profile.name,
                 "contact": profile.contact,
                 "payment": profile.payment,
                 "creditCardNum": profile.creditCardNum]
            ) { error in
                if let err = error {
                    print(#function, "Unable to update doucument: \(err)")
                    
                } else {
                    print(#function, "Successed update doucument: \(profile.email)")
                    complete(true)
                }
            }
    }

    
    func getAllPurchaseList(){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        print(#function, "loggedInUSerEmail : \(loggedInUserEmail)")
        if loggedInUserEmail.isEmpty{
            print(#function, "No logged in user")
        }else{
            do{
                self.purchaseListener = self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PURCHASE)
                    .addSnapshotListener({(querySnapshot, error) in
                        guard let snapshot = querySnapshot else{
                            print(#function, "No result received from firestore : \(error)")
                            return
                        }
                        snapshot.documentChanges.forEach{(docChange) in
                            do{
                                print(#function, "docChange : \(docChange)")
                                print(#function, "docChange.document : \(docChange.document)")
                                print(#function, "docChange.document.data() : \(docChange.document.data())")
                                print(#function, "docChange.document.documentID : \(docChange.document.documentID)")
                                
                                var session : Session = try docChange.document.data(as: Session.self)
                                session.id = docChange.document.documentID
                                
                                print(#function, "Session : \(session)")
                                
                                let matchedIndex = self.purchaseList.firstIndex(where: {( $0.id?.elementsEqual(session.id!) )! })
                                
                                switch(docChange.type){
                                case .added:
                                    print(#function, "Document added : \(docChange.document.documentID) (\(session.name)")
                                    
                                    if (matchedIndex == nil){
                                        self.purchaseList.append(session)
                                    }
                                case .modified:
                                    print(#function, "Document modified : \(docChange.document.documentID) (\(session.name)")
                                    if (matchedIndex != nil){
                                        self.purchaseList[matchedIndex!] = session
                                    }
                                case .removed:
                                    print(#function, "Document deleted : \(docChange.document.documentID) (\(session.name)")
                                    
                                    if (matchedIndex != nil){
                                        self.purchaseList.remove(at: matchedIndex!)
                                    }
                                }
                            }catch let error{
                                print(#function, "Unable to access docment change : \(docChange)")
                            }
                        }
                    })
            }catch let error{
                print(#function, "Unable to retrieve the documents from firestore : \(error)")
            }

        }
    }
    
    func insertToPurchaseList(newSession : Session, uuid : String){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        print(#function, "loggedInUSerEmail : \(loggedInUserEmail)")
        if loggedInUserEmail.isEmpty{
            print(#function, "No logged in user")
        }else{
            do{
                try self.db
                    .collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PURCHASE)
                    .document(uuid)
                    .getDocument{(document, error) in
                        if let document = document, document.exists{
                            print(#function, "\(uuid) already exists in fav db")
                        } else if let error = error {
                            print(#function, "Error in checking doc : \(error)")
                        } else {
                            do{
                                try self.db
                                    .collection(self.COLLECTION_USER)
                                    .document(loggedInUserEmail)
                                    .collection(self.COLLECTION_PURCHASE)
                                    .document(uuid)
                                    .setData(from : newSession)
                                print(#function, "\(uuid) added to purchase list")
                            }catch let error{
                                print(#function, "Error in adding doc : \(error)")
                            }
                        }
                        
                    }
            }catch let error{
                print(#function, "Unable to insert the document to firestore : \(error)")
            }
        }
    }
    
    func deleteFromPurchaseList(sessionToDelete : Session){
        let loggedInUserEmail = UserDefaults.standard.string(forKey: "KEY_EMAIL") ?? ""
        
        if (loggedInUserEmail.isEmpty){
            print(#function, "No logged in user")
        }else{
            do{
                self.db.collection(COLLECTION_USER)
                    .document(loggedInUserEmail)
                    .collection(COLLECTION_PURCHASE)
                    .document(sessionToDelete.id!)
                    .delete{ error in
                        
                        if let err = error {
                            print(#function, "Unable to delete document : \(err)")
                        }else{
                            print(#function, "Successfully deleted document : \(sessionToDelete.id) (\(sessionToDelete.name))")
                        }
                    }
                
            }catch let error{
                print(#function, "Unable to delete the documents from firestore : \(error)")
            }
        }
    }
}
