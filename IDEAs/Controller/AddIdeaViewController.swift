//
//  AddIdeaViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/27/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase
import Spring
import SVProgressHUD
import FirebaseDatabase

class AddIdeaViewController: UIViewController {
    
    //hook up all outlets.
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var submitButtonOutlet: SpringButton!
    @IBOutlet weak var ideaIDTextField: UITextField!
    @IBOutlet weak var ideaTitleTextField: UITextField!
    @IBOutlet weak var briefIdeaDescription: SpringTextField!
    
    //images that display if text field is edited.
    @IBOutlet weak var ideaIDCheckIfTextOutlet: SpringImageView!
    @IBOutlet weak var ideaTitleCheckIfTextOutlet: SpringImageView!
    @IBOutlet weak var ideaDescCheckIfTextOutlet: SpringImageView!
    
    //global variable to store the time stamp
    var dateString = ""
    let idea = Idea()
    var ideaID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //changes the nav bar title
        self.title = "Add an IDEA"
        
        if ideaID != 0{
            ideaIDTextField.text = String(ideaID)
        }
    
        //make submit button with rounded corners.
        submitButtonOutlet.layer.cornerRadius = 15
        
        //erases the border of the text fields for a more clean look.
        ideaTitleTextField.borderStyle = UITextBorderStyle.none
        ideaIDTextField.borderStyle = UITextBorderStyle.none
        briefIdeaDescription.borderStyle = UITextBorderStyle.none
        
        //will initially hide the submit button until the ideaID text field is written to.
        submitButtonOutlet.isHidden = true
        
        
        //set the color of the image views.
        ideaIDCheckIfTextOutlet.image = ideaIDCheckIfTextOutlet.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        ideaIDCheckIfTextOutlet.tintColor = UIColor.flatMint()

        ideaTitleCheckIfTextOutlet.image = ideaTitleCheckIfTextOutlet.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        ideaTitleCheckIfTextOutlet.tintColor = UIColor.flatMint()
        
        ideaDescCheckIfTextOutlet.image = ideaDescCheckIfTextOutlet.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        ideaDescCheckIfTextOutlet.tintColor = UIColor.flatMint()
        
        //hide the image views initially.
        ideaIDCheckIfTextOutlet.isHidden = true
        ideaTitleCheckIfTextOutlet.isHidden = true
        ideaDescCheckIfTextOutlet.isHidden = true
        
        //functionality to let the user click away from keyboard and onto screen to dismiss keyboard.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func viewTapped(){
        //this is what calls the 'textFieldDidEndEditing'
        ideaIDTextField.endEditing(true)
        ideaTitleTextField.endEditing(true)
        briefIdeaDescription.endEditing(true)
    }
    
    @IBAction func ideaIDTextFieldEdited(_ sender: Any) {
        
        //function makes the submit button appear after user enters ID
        if (ideaIDTextField.text?.isEmpty)!{
            print("Empty")
        }else{
            print("not empty")
            submitButtonOutlet.isHidden = false
            ideaIDCheckIfTextOutlet.isHidden = false
            //used the animate function of the Spring class. Assigned the animation within the button properties.
            ideaIDCheckIfTextOutlet.animate()
            submitButtonOutlet.animate()
        }
    }

    @IBAction func ideaTitleFieldEdited(_ sender: Any) {
        
        //function makes the submit button appear after user enters ID
        if (ideaTitleTextField.text?.isEmpty)!{
            print("Empty")
        }else{
            print("not empty")
            ideaTitleCheckIfTextOutlet.isHidden = false
            submitButtonOutlet.isHidden = false

            //used the animate function of the Spring class. Assigned the animation within the button properties.
            ideaTitleCheckIfTextOutlet.animate()
        }
        
    }
    
    @IBAction func ideaDescFieldEdited(_ sender: Any) {
        //function makes the submit button appear after user enters ID
        if (briefIdeaDescription.text?.isEmpty)!{
            print("Empty")
        }else{
            print("not empty")
            ideaDescCheckIfTextOutlet.isHidden = false
            
            //used the animate function of the Spring class. Assigned the animation within the button properties.
            ideaDescCheckIfTextOutlet.animate()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        self.getTimeStamp()
        ideaIDTextField.endEditing(true)
        submitButtonOutlet.isEnabled = false

        ideaDescCheckIfTextOutlet.isHidden = true
        ideaIDCheckIfTextOutlet.isHidden = true
        ideaTitleCheckIfTextOutlet.isHidden = true
        
        //here we are grabbing a reference of our active database.
        let ideaDB = Database.database().reference().child("ActiveIdeaDB")
        
        //created a dictionary to store the values in the database. Each of these will be separate data points. They come from what the user typed in, plus the original values stored in the Idea class.
        let ideaDictionary: [String:Any] = ["ID": ideaIDTextField.text!, "Idea Title": ideaTitleTextField.text!, "Idea Description": briefIdeaDescription.text!, "Active": true, "Approved": false, "Number Approved": 0, "Number Denied": 0, "IDEA Added Date": dateString]
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ideaDB.child(ideaIDTextField.text!).setValue(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                self.submitButtonOutlet.isEnabled = true
                self.ideaIDTextField.text = ""
                self.briefIdeaDescription.text = ""
                self.ideaTitleTextField.text = ""
                SVProgressHUD.showSuccess(withStatus: "IDEA successfully added!")
                SVProgressHUD.dismiss(withDelay: 0.5)
            }
        }
    }
    
    //when creating a new idea, this grabs th current date and puts it into the defined format.
    func getTimeStamp(){
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MM-dd-yyyy"
        dateString = formatter.string(from: now)
        print(dateString)
    }
}
    


