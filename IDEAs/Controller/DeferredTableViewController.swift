//
//  DeferredTableViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 6/11/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class DeferredTableViewController: UITableViewController, UISearchResultsUpdating {

    
    let searchController = UISearchController(searchResultsController: nil)
    var deferredIdeas = [Idea]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Deferred IDEAs"
        retrieveData()
        //setup search bar func.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        //searchController.searchBar.barStyle = .default
        searchController.searchBar.tintColor = UIColor.lightGray
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.keyboardAppearance = .dark
        tableView.tableHeaderView = searchController.searchBar
        //navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deferredIdeas.count
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let ref = Database.database().reference().child("ActiveIdeaDB/\(self.deferredIdeas[indexPath.row].ideaID)")
            ref.removeValue { error, _ in
            }
            self.deferredIdeas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        let activate = UITableViewRowAction(style: .normal, title: "Activate") { (action, indexPath) in
            let ideaID = Int(self.deferredIdeas[indexPath.row].ideaID)!
            let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")
            ref.updateChildValues(["Deferred" : false])
            ref.updateChildValues(["Active" : true])
            self.deferredIdeas.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        activate.backgroundColor = UIColor.flatMint()
        

        return [delete, activate]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "deferredTableViewCell", for: indexPath) as! DeferredTableViewCell
        //assign array values to the cells. I did this to prevent out of bounds index problems.
        if deferredIdeas.isEmpty{
            print("array is empty in ActiveVC")
        }else{
            cell.deferredIdeaIDOutlet.text = deferredIdeas[indexPath.row].ideaID
            cell.deferredIdeaTitleOutlet.text = deferredIdeas[indexPath.row].ideaTitle
            cell.deferredDescriptionLabel.text = deferredIdeas[indexPath.row].ideaDescription
            cell.deferredDateLabel.text = deferredIdeas[indexPath.row].addDate
        }
        return cell
    }

    
    
//MARK: - SEARCH BAR FUNC
    func updateSearchResults(for searchController: UISearchController) {
        print("search")
    }
    
    
    
    
//MARK: - RETRIEVE DATA
    
    func retrieveData(){
        
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
            let deferred = snapShotValue["Deferred"]
            
            let idea = Idea()
            idea.isActive = active as! Bool
            idea.isApproved = approved as! Bool
            idea.ideaDescription = description as! String
            idea.ideaID = iD! as! String
            idea.ideaTitle = title as! String
            idea.addDate = date as! String
            idea.deferred = deferred as! Bool
            
            if idea.deferred == true{
                self.deferredIdeas.append(idea)
            }
            
            self.tableView.reloadData()
        }
    }
}

