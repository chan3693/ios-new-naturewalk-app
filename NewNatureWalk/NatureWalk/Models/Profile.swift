//
//  Profile.swift
//  NatureWalk
//
//  Created by Jacob Lee on 2024-07-08.
//

import Foundation
import FirebaseFirestoreSwift

struct Profile : Hashable, Codable{
    @DocumentID var id : String? = UUID().uuidString
    
    var email: String = ""
    var name: String = ""
    var contact: String = ""
    var payment: String = ""
    var creditCardNum: String = ""
}
