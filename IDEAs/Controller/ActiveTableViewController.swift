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

class ActiveTableViewController: UITableViewController, UISearchResultsUpdating {
    
    
    
//MARK: - ADD VARIABLES

    @IBOutlet weak var addIdeaButton: UIBarButtonItem!
    @IBOutlet weak var approveButton: SpringButton!
    @IBOutlet weak var deniedButton: SpringButton!
    @IBOutlet weak var graphButton: SpringButton!
    @IBOutlet weak var logoutButtonOutlet: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)

    var allIdeasArray = [Idea]()
    var filteredIdeas = [Idea]()
    var prevID = ""
    var approvedArray = [Idea]()
    var deniedArray = [Idea]()
    var ideaArray : [Idea] = [Idea]()
    let user = User()
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
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        approvedArray.removeAll()
        deniedArray.removeAll()
        retrieveData()
        DispatchQueue.main.async {
            //self.retrieveData()
            self.user.checkIfAdmin(completion: self.completeAdminAccess)
            print("In dispatch section ActiveVC")

        }
        
        //setup search bar functionality.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        //searchController.searchBar.barStyle = .default
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.keyboardAppearance = .dark
        navigationItem.searchController = searchController

        definesPresentationContext = true
        
        
        let defaults = UserDefaults.standard

        print("This is from activevc \(defaults.bool(forKey: "isAdmin"))")
        
        approveButton.layer.cornerRadius = 15
        deniedButton.layer.cornerRadius = 15

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        approvedArray.removeAll()
//        deniedArray.removeAll()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.user.checkIfAdmin(completion: self.completeAdminAccess)
        }
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        DispatchQueue.main.async {
//            self.retrieveData()
//            self.tableView.reloadData()
//        }
//        approvedArray.removeAll()
//        deniedArray.removeAll()
//
//        DispatchQueue.main.async {
//            self.tableView.reloadData()
//            self.user.checkIfAdmin(completion: self.completeAdminAccess)
//        }
//
//        //NEED MORE TESTING TO SEE WHY ACTIVE IDEAS DUPLICATE
//
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    
//MARK: - SEARCH BAR FUNC
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            filteredIdeas = allIdeasArray.filter { idea in
                return idea.ideaID.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }else if let searchText2 = searchController.searchBar.text, !searchText2.isEmpty{
            filteredIdeas = allIdeasArray.filter {idea in
                return idea.ideaDescription.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }else{
            filteredIdeas = approvedArray
        }
        
        tableView.reloadData()
    }
    
    
    
    
    
//MARK: RETRIEVING AND STORING DATA
    
    @objc func retrieveData(){


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
            idea.addDate = date as! String

            //to be used for sections if i can
//            let sections: NSSet = NSSet(array: self.dateArray)
//            if !sections.contains(idea.addDate) {
//                self.dateArray.append(idea.addDate)
//            }
            
            //self.dateArray.append(self.stringDate)

            
            print("Printing prevID \(self.prevID)")
            
            self.allIdeasArray.append(idea)

            
            if idea.isActive == true && idea.ideaID != self.prevID{
                self.ideaArray.append(idea)
                self.prevID = idea.ideaID
            }else if idea.isApproved == true{
                self.approvedArray.append(idea)
            }else if idea.isApproved == false{
                self.deniedArray.append(idea)
            }
            self.activeIdeaTableView.reloadData()
            self.tableView.reloadData()
        }
//        self.activeIdeaTableView.reloadData()
//        self.tableView.reloadData()
    }
    
    
    //part of completion block in the User class.
    //retrieves data to determine if user is an admin or not.
    func completeAdminAccess(isAdmin: Bool){
        let defaults = UserDefaults.standard
        defaults.set(isAdmin, forKey: "isAdmin")
        if isAdmin == true{
            addIdeaButton.isEnabled = true
        }else{
            addIdeaButton.isEnabled = false
        }
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
        
        //changes the background color when selected.
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.flatPink()
        cell.selectedBackgroundView = backgroundView
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
        
        if segue.identifier == "approvedSegue"{
            let vc4 = segue.destination as! ApprovedTableViewController
            vc4.approvedIdeaCount = approvedArray.count
        }
    }
    
    
    
    
    
    
    
    
    
//MARK: - LOGOUT FUNCTIONALITY
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            //the view controllers are embedded in the navigation controller. This gives you the ability to go back, swipe to go back, etc.
            //takes you back to the welcome screen
            navigationController?.popToRootViewController(animated: true)
            self.performSegue(withIdentifier: "backToLogin", sender: self)
        }
        catch{
            print("error, there was a problem")
        }
    }
}
