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

    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    var truncatedEmail = ""
    let user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //functionality to let the user click away from keyboard and onto screen to dismiss keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)

        loginButton.layer.cornerRadius = 15
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func viewTapped(){
        //this is what calls the 'textFieldDidEndEditing'
        emailAddressTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
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
                isAdmin = self.user.checkIfAdmin()
            }
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToIdeas"{
//            let vc = segue.destination as! ActiveTableViewController
//            vc.isAdmin = isAdmin
//        }
//
//    }
    
}
