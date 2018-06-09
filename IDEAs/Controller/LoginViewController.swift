//
//  LoginViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/29/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase
import FirebaseAuth

var isAdmin = false

class LoginViewController: UIViewController {
    
    
    //MARK: - SETTING UP VARIABLES
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var truncatedEmail = ""
    let user = User()
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    
    
    
    
    //MARK: - STANDARD VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        //setup remember me functionality
        rememberMeSwitch.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
        
        //check if username and password exists as defaults.
        checkUserDefaults()
        
        //checkAdminUserDefault()
        
        //functionality to let the user click away from keyboard and onto screen to dismiss keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
    
        
        //checks to see if user is logged in. If so, goes straight to active ideas
        if Auth.auth().currentUser != nil {
            print("user is logged in")
            performSegue(withIdentifier: "goToIdeas", sender: self)
        } else {
            //User Not logged in
        }

        loginButton.layer.cornerRadius = 15
    }

    override func viewDidAppear(_ animated: Bool) {
        //checkAdminUserDefault()
        //removes the username and password when the user logs out.
        if logoutCheckIfUserDefaultsExists() == false{
            emailAddressTextField.text = ""
            passwordTextField.text = ""
        }
        
        //checks to see if user is logged in. If so, goes straight to active ideas
        if Auth.auth().currentUser != nil {
            print("user is logged in - did appear")
            performSegue(withIdentifier: "goToIdeas", sender: self)
        } else {
            //User Not logged in
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
//MARK: - SETUP USER DEFAULTS
    
    //save user info to the user defaults
    @objc func stateChanged(_ switchState: UISwitch){

        let defaults = UserDefaults.standard
        if switchState.isOn{
            defaults.set(true, forKey: "ISRemember")
            defaults.set(emailAddressTextField.text, forKey: "SavedUserName")
            defaults.set(passwordTextField.text, forKey: "SavedPassword")
        }else{
            defaults.set(false, forKey: "ISRemember")
            defaults.removeObject(forKey: "SavedUserName")
            defaults.removeObject(forKey: "SavedPassword")
        }
    }

    
    //check user default conditions
    
    func checkUserDefaults(){
        
        let defaults = UserDefaults.standard
        
        if let user = defaults.string(forKey: "SavedUserName"){
            emailAddressTextField.text = user
        }
        
        if let password = defaults.string(forKey: "SavedPassword"){
            passwordTextField.text = password
        }
        
        if defaults.bool(forKey: "ISRemember") == true{
            rememberMeSwitch.isOn = true
        }
        
        if defaults.bool(forKey: "ISRemember") == false{
            rememberMeSwitch.isOn = false
        }
    }
    
    func logoutCheckIfUserDefaultsExists() -> Bool{
    
        let defaults = UserDefaults.standard
        var doesExist = false
    
        if defaults.bool(forKey: "ISRemember") == true{
            doesExist = true
        }
        return doesExist
    }
    

    
    
    
//MARK: - SETUP WHEN TO REGISTER THE TAP GESTURE AFTER EDITING TEXT
    
    @objc func viewTapped(){
        //this is what calls the 'textFieldDidEndEditing'
        emailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    
    
    
    
    
    
    
//MARK: - SETUP BUTTONS
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        truncatedEmail = emailAddressTextField.text!
        if let dotRange = truncatedEmail.range(of: "@") {
            truncatedEmail.removeSubrange(dotRange.lowerBound..<truncatedEmail.endIndex)
        }
        
        SVProgressHUD.show()
        //checks the users authentification credentials.
        Auth.auth().signIn(withEmail: emailAddressTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil{
                print(error!)
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Invalid email & password combination")
                SVProgressHUD.dismiss(withDelay: 0.5)
                self.passwordTextField.text = ""
            }else{
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "goToIdeas", sender: self)
                //isAdmin = self.user.checkIfAdmin()
                print("This is from login class isAdmin \(isAdmin)")
            }
        }
    }

}
