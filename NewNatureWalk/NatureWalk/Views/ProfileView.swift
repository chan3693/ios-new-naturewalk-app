//
//  ProfileView.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var email : String = "NA"
    @State private var name : String = "NA"
    @State private var contact : String = "NA"
    @State private var payment : String = "NA"
    @State private var creditCardNum : String = "NA"
    
    @State private var isEdit = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @EnvironmentObject var fireDBHelper : FireDBHelper
    @EnvironmentObject var fireAuthHelper : FireAuthHelper
    
    private let paymentOptions = ["Visa", "Paypal", "Apple Pay"]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Form{
                if isEdit{
                    HStack {
                        Text("Email:")
                            .bold()
                        Spacer()
                        Text(self.email)
                    }
                    
                    HStack {
                        Text("Name:")
                            .bold()
                        TextField("Enter name", text: self.$name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Contact:")
                            .bold()
                        TextField("Enter contact", text: self.$contact)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    HStack {
                        Text("Payment:")
                            .bold()
                        Picker("Payment", selection: $payment) {
                            ForEach(paymentOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    HStack{
                        Text("Credit Card Number")
                            .bold()
                        TextField("Enter credit Card Number", text: self.$creditCardNum)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onChange(of: creditCardNum) { newValue in
                                let filtered = newValue.filter {$0.isNumber}
                                if filtered.count > 16 {
                                    creditCardNum = String(filtered.prefix(16))
                                }else{
                                    creditCardNum = filtered
                                }
                            }
                    }
                }else{
                    HStack {
                        Text("Email:")
                            .bold()
                        Spacer()
                        Text(self.email)
                    }
                    
                    HStack {
                        Text("Name:")
                            .bold()
                        Spacer()
                        Text(self.fireDBHelper.userProfile.name)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Contact:")
                            .bold()
                        Spacer()
                        Text(self.fireDBHelper.userProfile.contact)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Payment:")
                            .bold()
                        Spacer()
                        Text(self.fireDBHelper.userProfile.payment)
                    }
                    HStack {
                        Text("Credit Card Number")
                            .bold()
                        Spacer()
                        Text(self.fireDBHelper.userProfile.creditCardNum)
                    }
                }
      
                
            }//Form ends
            
            Button(action: {
                if isEdit{
                    self.updateProfile()
                }
                isEdit = true
                self.email = (Auth.auth().currentUser?.email)!
                self.name = fireDBHelper.userProfile.name
                self.contact = fireDBHelper.userProfile.contact
                self.payment = fireDBHelper.userProfile.payment
                self.creditCardNum = fireDBHelper.userProfile.creditCardNum
            }){
                Text(isEdit ? "Update" : "Profile information Change ")
            }
            .buttonStyle(.borderedProminent)
            .alert(isPresented: self.$showAlert){
                Alert(
                    title: Text("Tips"),
                    message: Text(self.alertMessage),
                    dismissButton: .default(Text("Sure"))
                    )//Alert ends
            }// .alert ends
        }
        .onAppear{
            self.email = (Auth.auth().currentUser?.email)!
        }
        .navigationTitle(Text("Profile View"))
    }
    
    private func updateProfile(){
        fireDBHelper.userProfile.email = self.email
        fireDBHelper.userProfile.name = self.name
        fireDBHelper.userProfile.contact = self.contact
        fireDBHelper.userProfile.payment = self.payment
        fireDBHelper.userProfile.creditCardNum = self.creditCardNum
        fireDBHelper.updateProfile( self.fireDBHelper.userProfile) { result in
            if result == true {
//                alertMessage = "SuccessFul Changed!"
                isEdit = false
            } else {
                alertMessage = "Error! Unable to Change Profile!"
                self.email = fireDBHelper.userProfile.email
                self.name = fireDBHelper.userProfile.name
                self.contact = fireDBHelper.userProfile.contact
                self.payment = fireDBHelper.userProfile.payment
                self.creditCardNum = fireDBHelper.userProfile.creditCardNum
            }
            showAlert = true
            
        }
        
    }
}

//#Preview {
//    ProfileView()
//}
