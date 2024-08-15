//
//  Session.swift
//  NatureWalk
//
//  Created by Simon Chan on 2024-07-07.
//

import Foundation
import FirebaseFirestoreSwift

struct Session : Hashable, Codable{
    @DocumentID var id : String? = UUID().uuidString
    
    var name: String = ""
    var description: String = ""
    var starRating: Double = 0.0
    var organizationName: String = ""
    var photo: [String] = [String]()
    var pricing: Double = 0.0
    var phone: String = ""
    var date: String = ""
    var address: String = ""
    
//    init(name: String, description: String, starRating: Double, organizationName: String, photo: [String], pricing: Double, phone: String, date: String, address: String) {
//        self.name = name
//        self.description = description
//        self.starRating = starRating
//        self.organizationName = organizationName
//        self.photo = photo
//        self.pricing = pricing
//        self.phone = phone
//        self.date = date
//        self.address = address
//    }
}
