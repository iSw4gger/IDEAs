//
//  RegisterViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/29/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class RegisterViewController: UIViewController {
    
    
//MARK: - SETTING UP VARIABLES
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerEmailAddressTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var backToLoginButton: UIButton!
    var domainCheck = ""
    
    
    
    
    
//MARK: - STANDARD VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.layer.cornerRadius = 15
        
        //functionality to let the user click away from keyboard and onto screen to dismiss keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
//MARK: - SETTING UP THE REGISTER WHEN TAPPED TO DISMISS KEYBOARD
    
    @objc func viewTapped(){
        //this is what calls the 'textFieldDidEndEditing'
        registerEmailAddressTextField.endEditing(true)
        registerPasswordTextField.endEditing(true)
        confirmPasswordTextField.endEditing(true)
        firstNameTextField.endEditing(true)
        lastNameTextField.endEditing(true)
    }
    
    
    
    
    
    
    
//MARK: - SETTING UP BUTTONS
    
    @IBAction func backToLoginButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func registerButtonPressed(_ sender: Any) {
        
        SVProgressHUD.show()
        
        if let email = registerEmailAddressTextField.text{
            if let dotRange = email.range(of: "@") {
                domainCheck = String(email[dotRange.upperBound...])
            }
        }
        
        
        if domainCheck != "stlukeshealth.org"{
            SVProgressHUD.showError(withStatus: "You must use an stlukeshealth.org email address")
            SVProgressHUD.dismiss(withDelay: 2.0)
            registerEmailAddressTextField.text = ""
            print(domainCheck)
            return
        }

 
        Auth.auth().createUser(withEmail: registerEmailAddressTextField.text!, password: registerPasswordTextField.text!) { (user, error) in
            //once authentification is completed and callback completed. This is referred to as a 'completion handler', because once the process of authentication the user, it notifies the user that the process is 'completed'
            if error != nil{
                //ex. will contain error if didn't adhere to rules of ".com" - email
                //error is not null, therefore error exists
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Cannot leave the fields blank.")
                SVProgressHUD.dismiss(withDelay: 0.5)
                print(error!)
            }
            else{
                //success
                SVProgressHUD.dismiss()
                //if in a closure, must use the 'self' keyword. Remember 'in' means closure
                self.performSegue(withIdentifier: "goToIdeas", sender: self)
                self.assignUserDetails()
            }
        }
    }
    
    
    
    
    
    
    
//MARK: - UPDATING DATABASE WITH USER DETAILS
    
    func assignUserDetails(){
        //here we are grabbing a reference of our active database.
        let ideaDB = Database.database().reference().child("UsersDB")
        
        //created a dictionary to store the values in the database. Each of these will be separate data points. They come from what the user typed in, plus the original values stored in the Idea class.
        let ideaDictionary: [String:Any] = ["Email": registerEmailAddressTextField.text!, "First Name": firstNameTextField.text!, "Last Name": lastNameTextField.text!, "Admin": false]
        
        var email = registerEmailAddressTextField.text!
        if let dotRange = email.range(of: "@") {
            email.removeSubrange(dotRange.lowerBound..<email.endIndex)
        }
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ideaDB.child(email).setValue(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
            }
        }
    }
}
    
