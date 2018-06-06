//
//  ViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/27/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase
import Spring
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class ActiveTableViewController: UITableViewController {
    
//MARK: - ADD VARIABLES

    @IBOutlet weak var addIdeaButton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var approveButton: SpringButton!
    @IBOutlet weak var deniedButton: SpringButton!
    @IBOutlet weak var graphButton: SpringButton!
    @IBOutlet weak var logoutButtonOutlet: UIBarButtonItem!
    
    var approvedArray = [Idea]()
    var deniedArray = [Idea]()
    var ideaArray : [Idea] = [Idea]()
    
    //Global variables to store the date and create the sections
    var dateArray = [String]()
    var stringDate : String = ""
    
    //variables used to hold the data that will send data to the 'VotingViewController'
    var ideaTitle = ""
    var ideaDesc = ""
    var ideaID = 0
    
    @IBOutlet var activeIdeaTableView: UITableView!
    
    
    
    
    
    
    
//MARK: - STANDARD VIEW CODE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        //admin determined in the login VC. will need to add to the register VC??
        addIdeaButton.isEnabled = false
        if isAdmin == true{
            addIdeaButton.isEnabled = true
        }
        approveButton.layer.cornerRadius = 15
        deniedButton.layer.cornerRadius = 15
        approvedArray.removeAll()
        deniedArray.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveData()
        approvedArray.removeAll()
        deniedArray.removeAll()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

        //NEED MORE TESTING TO SEE WHY ACTIVE IDEAS DUPLICATE
        tableView.reloadData()
        activeIdeaTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
//MARK: RETRIEVING AND STORING DATA
    
    func retrieveData(){
        ideaArray.removeAll()

        let ideaDB = Database.database().reference().child("ActiveIdeaDB")
        ideaDB.observe(.childAdded) { (snapshot) in
            //.value sends back an object type of 'any', so we have to cast it to dictionary.
            let snapShotValue = snapshot.value as! Dictionary<String, Any>
            let iD = snapShotValue["ID"]
            let description = snapShotValue["Idea Description"]
            let title = snapShotValue["Idea Title"]
            let active = snapShotValue["Active"]
            let approved = snapShotValue["Approved"]
            let date = snapShotValue["IDEA Added Date"]

            let idea = Idea()
            idea.isActive = active as! Bool
            idea.isApproved = approved as! Bool
            idea.ideaDescription = description as! String
            idea.ideaID = iD! as! String
            idea.ideaTitle = title as! String
            self.stringDate = date as! String

            //to be used for sections if i can
            self.dateArray.append(self.stringDate)

            if idea.isActive == true{
                self.ideaArray.append(idea)
            }else if idea.isApproved == true{
                self.approvedArray.append(idea)
            }else if idea.isApproved == false{
                self.deniedArray.append(idea)
            }
            self.activeIdeaTableView.reloadData()
            self.tableView.reloadData()
        }
        self.activeIdeaTableView.reloadData()
        self.tableView.reloadData()
    }
    
    
    
    
    
    
    
    
    
//MARK: -  SET UP TABLE VIEW
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ideaArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "activeTableViewCell", for: indexPath) as! ActiveTableViewCell
        //assign array values to the cells. I did this to prevent out of bounds index problems.
        if ideaArray.isEmpty{
            print("array is empty in ActiveVC")
        }else{
            cell.ideaIDCellLabel.text = ideaArray[indexPath.row].ideaID
            cell.ideaTitleCellLabel.text = ideaArray[indexPath.row].ideaTitle
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //assigns the class variables to the values of the row that was clicked on. This is so we can send it to the VoteViewController so it can be displayed over there.
        ideaTitle = ideaArray[indexPath.row].ideaTitle
        ideaID = Int(ideaArray[indexPath.row].ideaID)!
        ideaDesc = ideaArray[indexPath.row].ideaDescription
        
        performSegue(withIdentifier: "segueToVote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let ref = Database.database().reference().child("ActiveIdeaDB/\(self.ideaArray[indexPath.row].ideaID)")
            ref.removeValue { error, _ in
            }
            self.ideaArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.ideaID = Int(self.ideaArray[indexPath.row].ideaID)!
            self.performSegue(withIdentifier: "goToAdd", sender: self)
        }
        
        edit.backgroundColor = UIColor.flatSkyBlue()
        return [delete, edit]
    }
    
    
    
    
    
    
    
    
    
//MARK: - PREPARE THE DATA FOR MOVEMENT TO ANOTHER VC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //This method is necessary to set the class variables located here to the class variables in the VoteViewController. These class variable values were assigned in the 'didSelectRow' function.
        
        if segue.identifier == "segueToVote"{
            let vc = segue.destination as! VotingViewController
            vc.ideaTitle = self.ideaTitle
            vc.ideaDesc = self.ideaDesc
            vc.ideaID = self.ideaID
        }
        
        //pre-populates the ID field so can be edited.
        if segue.identifier == "goToAdd"{
            let vc2 = segue.destination as! AddIdeaViewController
            vc2.ideaID = self.ideaID
        }
        
        if segue.identifier == "segueToDashboard"{
            let vc3 = segue.destination as! DashboardViewController
            vc3.numberApproved = approvedArray.count
            vc3.numberDenied = deniedArray.count
            print("This is from active prepare for segue \(approvedArray.count) and \(deniedArray.count)")
        }
    }
    
    
    
    
    
    
    
    
    
//MARK: - LOGOUT FUNCTIONALITY
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        do{
            try Auth.auth().signOut()
            //the view controllers are embedded in the navigation controller. This gives you the ability to go back, swipe to go back, etc.
            //takes you back to the welcome screen
            navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
        catch{
            print("error, there was a problem")
        }
    }
}
