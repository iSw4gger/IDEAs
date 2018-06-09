//
//  DeniedTableViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase

class DeniedTableViewController: UITableViewController, UISearchResultsUpdating {

    var deniedArray = [Idea]()
    var filteredIdeas = [Idea]()
    let searchController = UISearchController(searchResultsController: nil)
    
    var ideaDesc : String = ""
    var ideaTitle : String = ""
    var ideaID : Int = 0
    var ideaArray = [Idea]()
    var numberApproved: Int = 0
    var numberDenied: Int = 0
    var currentIdeaArray = [Idea]()
    var approvedIdeaCount = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Denied IDEAs"
        
        
        //setup search bar func.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        searchController.searchBar.barStyle = .default
        searchController.searchBar.searchBarStyle = .minimal
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        //method call to tap into database to get the values.
        retrieveData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIdeas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "deniedTableViewCell", for: indexPath) as! DeniedTableViewCell
        
        //assign array values to the cells.
        cell.deniedIDCellLabel.text = filteredIdeas[indexPath.row].ideaID
        cell.deniedTitleCellLabel.text = filteredIdeas[indexPath.row].ideaTitle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //makes the cell unhighlighted after selected
        tableView.deselectRow(at: indexPath, animated: true)
        
        ideaTitle = filteredIdeas[indexPath.row].ideaTitle
        ideaID = Int(filteredIdeas[indexPath.row].ideaID)!
        ideaDesc = filteredIdeas[indexPath.row].ideaDescription
        numberApproved = filteredIdeas[indexPath.row].numberApproved
        numberDenied = filteredIdeas[indexPath.row].numberDenied
        
        performSegue(withIdentifier: "segueToApprovedResults", sender: self)
        
    }
    
    
    
    
    //setup search bar
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty{
            filteredIdeas = deniedArray.filter { idea in
                return idea.ideaID.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }else if let searchText2 = searchController.searchBar.text, !searchText2.isEmpty{
            filteredIdeas = deniedArray.filter {idea in
                return idea.ideaDescription.lowercased().contains(searchController.searchBar.text!.lowercased())
            }
        }else{
            filteredIdeas = deniedArray
        }
        
        tableView.reloadData()
        
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
            let numberApp = snapShotValue["Number Approved"]
            let numberDen = snapShotValue["Number Denied"]
            
            let idea = Idea()
            idea.ideaTitle = title as! String
            idea.isApproved = approved as! Bool
            idea.isActive = active as! Bool
            idea.ideaID = iD as! String
            idea.ideaDescription = description as! String
            idea.numberApproved = numberApp as! Int
            idea.numberDenied = numberDen as! Int
            
            if idea.isApproved == false{
                self.deniedArray.append(idea)
                self.filteredIdeas.append(idea)
            }
            self.filteredIdeas = self.deniedArray
            //since we are getting new messages, we need to reformat the table view by calling configureTableView
            //reloads the idea table view with new data
            self.tableView.reloadData()
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToApprovedResults"{
            let vc = segue.destination as! ApprovedResultsViewController
            vc.ideaTitle = self.ideaTitle
            vc.ideaDesc = self.ideaDesc
            vc.ideaID = self.ideaID
            vc.numberDenied = self.numberDenied
            vc.numberApproved = self.numberApproved
        }
    }
}
