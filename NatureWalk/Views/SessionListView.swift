//
//  SessionListView.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import SwiftUI

struct SessionListView: View {
    
    @State private var selectedIndex : Int = -1
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(self.fireDBHelper.sessionList.enumerated().map({$0}), id: \.element.self){index, currentSession in
                    
                    NavigationLink(destination: DetailView(selectedSessionIndex: index)
                        .environmentObject(self.fireDBHelper)
                        .environmentObject(self.fireAuthHelper)){
                        HStack(alignment: .center, spacing: 10){
                            VStack(alignment: .leading, spacing: 10){
                                Text("\(currentSession.name)")
                                    .fontWeight(.bold)
                                Text("Price : $\(String(currentSession.pricing)) / person")
                            }//VStack
                            Spacer()
                            VStack{
                                ForEach(currentSession.photo.prefix(2), id: \.self) { photoURL in
                                    if let url = URL(string: photoURL){
                                        AsyncImage(url: url) { image in
                                            image.image?.resizable()
                                            .frame(width: 70, height: 70)}
                                    }
                                }
                            }//VStack
                            
                        }//HStack
                        
                        .onTapGesture {
                            self.selectedIndex = index
                            print(#function, "selected session index : \(self.selectedIndex) \(self.fireDBHelper.sessionList[selectedIndex].name)")
                        }
                    }//NavigationLink
                }//ForEach
            }//List end
            Spacer()
            
        }//NavigationStack
        .navigationTitle(Text("Sessions List"))
//        .shareToolbar()
        .onAppear(){
            self.fireDBHelper.getAllPublishedSessions()
            self.fireAuthHelper.checkLoggedIn()
            FireDBHelper.getInstance().getUserProfile()
        }
    }//body
}//SessionListView
//
//#Preview {
//    SessionListView()
//}
