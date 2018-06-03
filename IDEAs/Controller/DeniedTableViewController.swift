//
//  DeniedTableViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase

class DeniedTableViewController: UITableViewController {

    var deniedArray = [Idea]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Denied IDEAs"
        
        //method call to tap into database to get the values.
        retrieveData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deniedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "deniedTableViewCell", for: indexPath) as! DeniedTableViewCell
        
        //assign array values to the cells.
        cell.deniedIDCellLabel.text = deniedArray[indexPath.row].ideaID
        cell.deniedTitleCellLabel.text = deniedArray[indexPath.row].ideaTitle
        
        return cell
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
            
            if idea.isApproved == false{
                self.deniedArray.append(idea)
            }
            
            //since we are getting new messages, we need to reformat the table view by calling configureTableView
            //reloads the idea table view with new data
            self.tableView.reloadData()
            
        }
        
    }
}
