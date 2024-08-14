//
//  DetailView.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import SwiftUI
import FirebaseAuth

struct DetailView: View {
    
    let selectedSessionIndex : Int
    @State private var favLabel = ""
    @State private var showLogin = false
    @State var isFavorites = false
    @State var isPurchased = false
    @State private var currentSesstion = Session()
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(alignment: .leading, spacing: 15){
                    HStack{
                        Text(currentSesstion.name)
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Button{
                            self.addToFavorites()
                        }label: {
                            Image(systemName: favLabel)
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                    }//HStack
                    
                    Text(currentSesstion.description)
                        .font(.body)
                        .padding(.vertical)
                    
                    Group{
                        HStack{
                            Text("Price :")
                                .font(.headline)
                            Text("$\(String(currentSesstion.pricing)) / person")
                        }
                        HStack{
                            Text("Star Rating :")
                                .font(.headline)
                            ForEach(0..<5) { index in
                                self.star(index: index)
                            }
                        }
                        HStack{
                            Text("Organization Hosting :")
                                .font(.headline)
                            Text(currentSesstion.organizationName)
                        }
                        HStack{
                            Text("Contact :")
                                .font(.headline)
                            Button(action: {
                                if let call = URL(string: "tel://\(currentSesstion.phone)"){
                                    UIApplication.shared.open(call, options: [:], completionHandler: nil)
                                }
                            }){
                                Text(currentSesstion.phone)
                            }
                        } //HStack_contact
                        HStack{
                            Text("Date and time :")
                                .font(.headline)
                            Text(currentSesstion.date)
                        }
                        HStack(alignment: .top){
                            Text("Address :")
                                .font(.headline)
                            Button(action: {
                                if let address = URL(string: "http://maps.apple.com/?address=\(currentSesstion.address)") {
                                    UIApplication.shared.open(address, options: [:], completionHandler: nil)
                                }
                            }){
                                Text(currentSesstion.address)
                            }
                        } //HStack address
                    }//Group
//                    .padding(.vertical, 2)
                    
                    HStack{
                        Spacer()
                        Button{
                            self.addToPurchase()
                        }label: {
                            HStack{
                                Image(systemName: "cart.badge.plus")
                                Text("Purchase")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isPurchased)
                        Spacer()
                    }//HStack
                    .padding(.vertical)
                    
                    ForEach(currentSesstion.photo, id: \.self) { url in
                        AsyncImage(url: URL(string: url)) { image in
                            image.image?.resizable()
                            .frame(maxWidth: .infinity, maxHeight: 240)
                        }
//                        .padding(.vertical)
                    }
                    
                }//VStack
                .padding()
            }//ScrollView
        }//NavigationStack
        .navigationTitle(Text("Session Detail"))
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                ShareLink(item: "\(currentSesstion.name), $\(String(currentSesstion.pricing))")
            }
        }
//        .shareToolbar()
        .sheet(isPresented: self.$showLogin){
            LoginView()
                .onDisappear{
                    checkIsFav()
                    checkIsPur()
                }
        }
        .onAppear{
            if isFavorites{
                currentSesstion =  self.fireDBHelper.favoritesList[selectedSessionIndex]
            } else if isPurchased{
                currentSesstion =  self.fireDBHelper.purchaseList[selectedSessionIndex]
            }else{
                currentSesstion =  self.fireDBHelper.sessionList[selectedSessionIndex]
            }
            checkIsFav()
            checkIsPur()
        }

    }//body
    
    private func addToFavorites(){
        guard Auth.auth().currentUser != nil else{
            showLogin = true
            return
        }
        
        let session = currentSesstion
        
        let newSession = Session(name: session.name, description: session.description, starRating: session.starRating, organizationName: session.organizationName, photo: session.photo, pricing: session.pricing, phone: session.phone, date: session.date, address: session.address)
        
        guard let uuid = session.id else{
            print(#function, "Session uuid is nil")
            return
        }
        
        self.fireDBHelper.insertToFavList(newSession: newSession, uuid: uuid)
        
        isFavorites = true
        favLabel = "star.circle.fill"
    }
    
    func checkIsFav(){
        guard Auth.auth().currentUser != nil else{
            favLabel = "star.circle"
            return
        }
        
        if fireDBHelper.favoritesList.contains(where: {$0.id == currentSesstion.id}){
            isFavorites = true
        } else{
            isFavorites = false
        }
        
        favLabel = isFavorites ? "star.circle.fill" : "star.circle"
    }
    
    private func addToPurchase(){
        guard Auth.auth().currentUser != nil else{
            showLogin = true
            return
        }
        let session = currentSesstion
        let newSession = Session(name: session.name, description: session.description, starRating: session.starRating, organizationName: session.organizationName, photo: session.photo, pricing: session.pricing, phone: session.phone, date: session.date, address: session.address)
        guard let uuid = session.id else{
            print(#function, "Session uuid is nil")
            return
        }
        self.fireDBHelper.insertToPurchaseList(newSession: newSession, uuid: uuid)

        isPurchased = true
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            let alert = UIAlertController(title: "Purchase Successful", message: "You have successfully purchased this session.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    func checkIsPur(){
        guard Auth.auth().currentUser != nil else{
            isPurchased = false
            return
        }
        if fireDBHelper.purchaseList.contains(where: {$0.id == currentSesstion.id}){
            isPurchased = true
        } else{
            isPurchased = false
        }
        
    }
    
    private func star(index : Int) -> some View {
        let rating = currentSesstion.starRating
        
        let halfStar = Image(systemName: "star.leadinghalf.filled")
            .resizable()
            .frame(width: 20, height: 20)
        
        let filledStar = Image(systemName: "star.fill")
            .resizable()
            .frame(width: 20, height: 20)
        
        let star = Image(systemName: "star")
            .resizable()
            .frame(width: 20, height: 20)
        
        if Double(index) + 0.5 == rating{
            return halfStar
        } else if Double(index) < rating{
            return filledStar
        } else {
            return star
        }
    }
}


