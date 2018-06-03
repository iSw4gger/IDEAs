//
//  ApprovedTableViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ApprovedTableViewController: UITableViewController {

    var approvedArray = [Idea]()
    var deniedArray = [Idea]()
    var ideaDesc : String = ""
    var ideaTitle : String = ""
    var ideaID : Int = 0
    var ideaArray = [Idea]()
    var numDenierArray = [String]()
    var numApproverArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Approved IDEAs"

        //method call to tap into database to get the values.
        retrieveData()
        updateDenierPerson()
        updateApproverPerson()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return approvedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "approvedTableViewCell", for: indexPath) as! ApprovedTableViewCell
        //assign array values to the cells.
        cell.approvedIdeaIDOutlet.text = approvedArray[indexPath.row].ideaID
        cell.approvedIdeaTitleOutlet.text = approvedArray[indexPath.row].ideaTitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //makes the cell unhighlighted after selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        ideaTitle = approvedArray[indexPath.row].ideaTitle
        ideaID = Int(approvedArray[indexPath.row].ideaID)!
        ideaDesc = approvedArray[indexPath.row].ideaDescription

        performSegue(withIdentifier: "segueToApprovedResults", sender: self)

    }
    
    func retrieveData(){
        let ideaDB = Database.database().reference().child("ActiveIdeaDB")
        ideaDB.observe(.childAdded) { (snapshot) in
            
            //.value sends back an object type of 'any', so we have to cast it to dictionary.
            let snapShotValue = snapshot.value as! Dictionary<String, Any>
            let iD = snapShotValue["ID"]!
            let description = snapShotValue["Idea Description"]!
            let active = snapShotValue["Active"]
            let approved = snapShotValue["Approved"]
            let title = snapShotValue["Idea Title"]
            
            let idea = Idea()
            idea.ideaTitle = title as! String
            idea.isApproved = approved as! Bool
            idea.isActive = active as! Bool
            idea.ideaID = iD as! String
            idea.ideaDescription = description as! String
            
            if idea.isApproved == true{
                self.approvedArray.append(idea)//approved IDEAs
            }else{
                self.deniedArray.append(idea)//denied IDEAs
            }

            //required for this table to populate with this data.
            self.tableView.reloadData()

        }
    }
    
    func updateDenierPerson(){
        //grabs number of denies per ideaID and sends them to 'prepareForSegue' and to Approval Results Controller.
        let ref = Database.database().reference().child("ActiveIdeaDB")
        ref.child("ActiveIdeaDB").child(String(self.ideaID)).child("Denier").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["Email"] as? String ?? ""
            
            self.numDenierArray.append(email)
            print("This is from updateDenierPerson in Approved class \(email)")
            
        }) { (error) in
            print("error")
        }
    }
    
    func updateApproverPerson(){
        //grabs number of approves per ideaID and sends them to 'prepareForSegue' and to Approval Results Controller.
        let ref = Database.database().reference().child("ActiveIdeaDB")
        ref.child("ActiveIdeaDB").child(String(self.ideaID)).child("Approver").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let email = value?["Email"] as? String ?? ""
            
            self.numApproverArray.append(email)
            
        }) { (error) in
            print("error")
        }
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //This method is necessary to set the class variables located here to the class variables in the VoteViewController. These class variable values were assigned in the 'didSelectRow' function.
        
        if segue.identifier == "segueToApprovedResults"{
            let vc = segue.destination as! ApprovedResultsViewController
            vc.ideaTitle = self.ideaTitle
            vc.ideaDesc = self.ideaDesc
            vc.ideaID = self.ideaID
            vc.numberDenied = numDenierArray.count
            vc.numberApproved = numApproverArray.count
        }
    }
}
