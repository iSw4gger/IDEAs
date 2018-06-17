//
//  User.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/29/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth

class User{
    
    var emailAddress : String = ""
    var isAdmin : Bool = false
    var lastName : String = ""
    var firstName : String = ""
    var isActive : Bool = false
    
//    init() {
//        isAdmin = checkIfAdmin()
//    }

    func checkIfAdmin(completion: @escaping  (Bool)-> Void){

        var tempAdmin = false
        let currentUser = Auth.auth().currentUser

        DispatchQueue.main.async {

        
        if currentUser != nil{
            var email = (currentUser?.email)!
            if let dotRange = email.range(of: "@") {
                email.removeSubrange(dotRange.lowerBound..<email.endIndex)
            }
            
            let ideaDB = Database.database().reference().child("UsersDB").child(email)
            ideaDB.observe(.value) { (snapshot) in
                
                print(snapshot)
                if let snapShotValue = snapshot.value as? Dictionary<String, Any>{
                    let admin = snapShotValue["Admin"]!
                    
                    self.isAdmin = admin as! Bool

                    tempAdmin = self.isAdmin
            
                    print("this is from the User class, 'tempAdmin': \(tempAdmin)")
                    print("this is from the User class, global 'isAdmin': \(self.isAdmin)")
                    completion(tempAdmin)
                }
                }
            }
        }
    }
}
