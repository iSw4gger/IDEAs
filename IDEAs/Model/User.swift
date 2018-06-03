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
    
    init() {
        isAdmin = checkIfAdmin()
    }

    func checkIfAdmin() -> Bool{

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
                
                
                //.value sends back an object type of 'any', so we have to cast it to dictionary.
                let snapShotValue = snapshot.value as! Dictionary<String, Any>
                //let email = snapShotValue["Email"]!
                let admin = snapShotValue["Admin"]!
                //let firstName = snapShotValue["First Name"]
                //let lastName = snapShotValue["Last Name"]
                
                //self.emailAddress = email as! String
                self.isAdmin = admin as! Bool
                //self.firstName = firstName as! String
                //self.lastName = lastName as! String
                
                tempAdmin = self.isAdmin
                
                print("this is from the User class, 'tempAdmin': \(tempAdmin)")
                print("this is from the User class, global 'isAdmin': \(self.isAdmin)")
                    }
                }
            }
        return isAdmin
        
    }
    
}
