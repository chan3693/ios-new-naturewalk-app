//
//  PurchaseListView.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import SwiftUI

struct PurchaseListView: View {
    @State private var selectedIndex : Int = -1
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    var body: some View {
        NavigationStack{

            
            if (self.fireDBHelper.purchaseList.isEmpty){
                Text("No session in the purchase yet.")
                Spacer()
            }else{
                List{
                    ForEach(self.fireDBHelper.purchaseList.enumerated().map({$0}), id:\.element.self){index, currentSession in
                        
                        NavigationLink(destination: DetailView(selectedSessionIndex: index, isPurchased: true)
                            .environmentObject(self.fireDBHelper)
                            .environmentObject(self.fireAuthHelper)){
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Text("\(currentSession.name)")
                                        .fontWeight(.bold)
                                    Text("Date and time : \(currentSession.date)")
                                }
                                .onTapGesture {
                                    self.selectedIndex = index
                                    print(#function, "selected session index : \(self.selectedIndex) \(self.fireDBHelper.purchaseList[selectedIndex].name)")
                                }
                            }
                    }
                    .onDelete(perform: {indexSet in
                        for index in indexSet{
                            print(#function, "Session to delete : \(self.fireDBHelper.purchaseList[index].name)")
                            self.fireDBHelper.deleteFromPurchaseList(sessionToDelete: self.fireDBHelper.purchaseList[index])
                        }
                    })
                }
            }
        }
        .navigationTitle(Text("Purchase List"))
        .onAppear(){
            self.fireDBHelper.getAllPurchaseList()
            self.fireAuthHelper.checkLoggedIn()
        }
    }
}

#Preview {
    PurchaseListView()
}
