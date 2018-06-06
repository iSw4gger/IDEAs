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
    
//    init() {
//        isAdmin = checkIfAdmin()
//    }

    func checkIfAdmin(){

        let defaults = UserDefaults.standard
        
        DispatchQueue.main.async {
            
        
        var tempAdmin = false
        let currentUser = Auth.auth().currentUser
        
        if currentUser != nil{
            var email = (currentUser?.email)!
            if let dotRange = email.range(of: "@") {
                email.removeSubrange(dotRange.lowerBound..<email.endIndex)
            }
            
            let ideaDB = Database.database().reference().child("UsersDB")
            ideaDB.observe(.childAdded) { (snapshot) in
                
                
                let snapShotValue = snapshot.value as! Dictionary<String, Any>
                let admin = snapShotValue["Admin"]!
                
                self.isAdmin = admin as! Bool
                
                tempAdmin = self.isAdmin
                
                if tempAdmin == true{
                    defaults.set(true, forKey: "isAdmin")
                }
                
                print("this is from the User class, 'tempAdmin': \(tempAdmin)")
                print("this is from the User class, global 'isAdmin': \(self.isAdmin)")
                }
            }
            if self.isAdmin == true{
                defaults.set(true, forKey: "isAdmin")
            }
            
            if self.isAdmin == true{
                defaults.set(true, forKey: "isAdmin")
            }
        }
        if isAdmin == true{
            defaults.set(true, forKey: "isAdmin")
        }
    }

}

