//
//  VotingViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/28/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Spring
import Firebase
import SVProgressHUD
import Charts
import ChameleonFramework
import FirebaseDatabase
import FirebaseAuth

class VotingViewController: UIViewController {

    //setup outlets
    @IBOutlet weak var voteIdeaTitle: UILabel!
    @IBOutlet weak var voteIdeaDescription: UILabel!
    @IBOutlet weak var approvedBar: UIView!
    @IBOutlet weak var deniedBar: UIView!
    @IBOutlet weak var approveButton: SpringButton!
    @IBOutlet weak var denyButton: SpringButton!
    @IBOutlet weak var pieChartView: PieChartView!
    
    
    //grab an Idea object
    let idea = Idea()
    
    //voting array to temp store data
    var votingArray = [Idea]()
    var approverArray = [""]
    
    //these are the values that come from the 'Active Table View Controller'. These change based on the 'prepareForSegue' in the Active VC
    var ideaTitle = ""
    var ideaDesc = ""
    var ideaID = 0
    
    //user variables
    let currentUser = Auth.auth().currentUser
    var email : String = ""
    var approver : String = ""
    
    //value to store original graph data.
    var approvedDataEntry = PieChartDataEntry(value: 0)
    var deniedDataEntry = PieChartDataEntry(value: 0)
    var numberOfApproved = 0
    
    @IBOutlet weak var approveUserLabel: UILabel!
    //must use an array of 'entries'. This time it's PieChartDataEntry
    var numberOfVotesDataEntries = [PieChartDataEntry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()
  
        //grabs the current email and erases everything past the @ symbol so it can be added to DB as child
        email = (currentUser?.email)!
        if let dotRange = email.range(of: "@") {
            email.removeSubrange(dotRange.lowerBound..<email.endIndex)
        }
        //set the title of the NavBar to the ideaID
        self.title = "IDEA # \(ideaID)"
        
        //set the text labels in this class to the values that were segued over from the Active VC
        voteIdeaTitle.text = ideaTitle.uppercased()
        voteIdeaDescription.text = ideaDesc
        
        //had to do this to change the button's color to a custom color. Wouldn't let me do it in the properties.
        let checkedImage = UIImage(named: "checked")?.withRenderingMode(.alwaysTemplate)
        approveButton.setBackgroundImage(checkedImage, for: .normal)
        approveButton.tintColor = UIColor.flatMint()
        
        //had to do this to change the button's color to a custom color. Wouldn't let me do it in the properties.
        let deniedImage = UIImage(named: "cancel")?.withRenderingMode(.alwaysTemplate)
        denyButton.setBackgroundImage(deniedImage, for: .normal)
        denyButton.tintColor = UIColor.flatPurple()
        
        //MARK: - INITIAL PIE CHART DETAILS
        
        //dont want a description as it's ugly.
        pieChartView.chartDescription?.text = ""
        
        //sets the label in the chart and on the legend.
        approvedDataEntry.label = "Approved"
        deniedDataEntry.label = "Denied"
        
        //storing the entries in an array that was established above.
        numberOfVotesDataEntries = [approvedDataEntry, deniedDataEntry]
        updateApproveData()
        updateDenialData()
        updateApprovalPerson()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //this is necessary to remove the rows that were switched from active to inactive. Otherwise, still appears in the active VC
        if segue.identifier == "segueToVote"{
            let vc = segue.destination as! ActiveTableViewController
            vc.retrieveData()
            
        }
    }
    
    @IBAction func approveButtonPressed(_ sender: Any) {
        
        
        //pop up that dismisses after a short delay.
        SVProgressHUD.showSuccess(withStatus: "You approved this IDEA.")
        SVProgressHUD.dismiss(withDelay: 0.4)
        SVProgressHUD.setDefaultAnimationType(.flat)
        // grab a reference of the master DB + child DB and update those points within the ideaID
        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")

        //switching it to approved. May need to update logic
        ref.updateChildValues(["Approved" : true])
        
        //switching to active. May need to update logic here.
        ref.updateChildValues(["Active" : false])
        
        //TODO: - may need to get rid of this
        approvedDataEntry.value = approvedDataEntry.value + 1.0
        ref.updateChildValues(["Number Approved" : approvedDataEntry.value])
        
        
        //created a dictionary to store the values in the database. Each of these will be separate data points. They come from what the user typed in, plus the original values stored in the Idea class.
        let ideaDictionary: [String:String] = ["Email" : email]
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ref.child("Approver").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                self.updateChartData()
                self.updateApproveData()
                self.updateApprovalPerson()
            }
        }
    }
    
    
    @IBAction func denyButtonPressed(_ sender: Any) {
        
        SVProgressHUD.showError(withStatus: "You denied this IDEA.")
        SVProgressHUD.dismiss(withDelay: 0.4)

        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")
        ref.updateChildValues(["Approved" : false])
        
        ref.updateChildValues(["Active" : false])
        ref.updateChildValues(["Number Denied" : self.deniedDataEntry.value + 1])
        
        let ideaDictionary: [String:String] = ["Email" : email]
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ref.child("Denier").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                self.updateChartData()
                self.updateDenialData()
                self.updateDenierPerson()
            }
        }
    }

    func retrieveData(){
        
        let ideaDB = Database.database().reference().child("ActiveIdeaDB/\(idea.ideaID)")
        ideaDB.observe(.childAdded) { (snapshot) in
            //.value sends back an object type of 'any', so we have to cast it to dictionary.
            let snapShotValue = snapshot.value as! Dictionary<String, Any>
            let iD = snapShotValue["ID"]
            let description = snapShotValue["Idea Description"]!
            let title = snapShotValue["Idea Title"]
            let active = snapShotValue["Active"]
            let approved = snapShotValue["Approved"]
            //let approvedNumber = snapShotValue["Number Approved"]
            
            self.idea.isActive = active as! Bool
            self.idea.isApproved = approved as! Bool
            self.idea.ideaDescription = description as! String
            self.idea.ideaID = iD! as! String
            self.idea.ideaTitle = title as! String
            //self.idea.numberApproved = approvedNumber as! Int
            
            self.votingArray.append(self.idea)
        }
    }
    
    //MARK: - CHART BUILD & UPDATING DATA FOR CHART
    
    func updateChartData(){
        
        if approvedDataEntry.value == 0 && deniedDataEntry.value == 0{
            pieChartView.noDataText = "No votes casted"
        }else{
            //gotta create a data set using our array.
            let chartDataSet = PieChartDataSet(values: numberOfVotesDataEntries, label: nil)
            //add the data set to chart data.
            let chartData = PieChartData(dataSet: chartDataSet)
            //change colors of the entries.
            let colors = [UIColor.flatMint(), UIColor.flatPurple()]
            chartDataSet.colors = colors as! [NSUIColor]
        
            //assign values out.
            pieChartView.data = chartData
        
            //animate a change.
            pieChartView.animate(xAxisDuration: 0.5)
            pieChartView.animate(yAxisDuration: 0.5)
            pieChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInCirc)
        
        }
    }
    
    func updateApproveData(){
        //calling it on the main thread so it appears on the other persons screen.
        DispatchQueue.main.async {
            let ref = Database.database().reference().child("ActiveIdeaDB/\(self.ideaID)")
            ref.observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let appNum = value?["Number Approved"] as! Double
                self.approvedDataEntry.value = appNum
                print("This is in updateApproveData" + String(self.approvedDataEntry.value))
                self.updateChartData()
            })
        }
    }
    
    func updateApprovalPerson(){
        DispatchQueue.main.async {
            let ref2 = Database.database().reference().child("ActiveIdeaDB/\(self.ideaID)/Approver")
            //ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            ref2.observe(DataEventType.value, with: { (snapshot) in
                
                //get rid of all data in array so we don't have duplicates. The data will be restored via database
                self.approverArray.removeAll()
        
                //cycle through all snapshot values and assign it to the array.
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key // retrieves both email addresses
                    let value = snap.value as! String
                    print("key = \(key)  value = \(value)") //test successful
                    self.approverArray.append(value)
                    let people = self.approverArray.joined(separator: ", ")
                    self.approveUserLabel.text = "Voted: " + people
                    for p in self.approverArray{
                        print(p)
                    }
                }
            })
        }
    }
    
    func updateDenierPerson(){
        DispatchQueue.main.async {
            let ref2 = Database.database().reference().child("ActiveIdeaDB/\(self.ideaID)/Denier")
            //ref2.observeSingleEvent(of: .value, with: { (snapshot) in
            ref2.observe(DataEventType.value, with: { (snapshot) in
                
                //get rid of all data in array so we don't have duplicates. The data will be restored via database
                self.approverArray.removeAll()
                
                //cycle through all snapshot values and assign it to the array.
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let key = snap.key // retrieves both email addresses
                    let value = snap.value as! String
                    print("key = \(key)  value = \(value)") //test successful
                    self.approverArray.append(value)
                    let people = self.approverArray.joined(separator: ", ")
                    self.approveUserLabel.text = "Voted: " + people
                }
            })
        }
    }
    
    func updateDenialData(){
        
        DispatchQueue.main.async {
            let ref = Database.database().reference().child("ActiveIdeaDB/\(self.ideaID)")
            ref.observe(DataEventType.value, with: { (snapshot) in
                
                let value = snapshot.value as? NSDictionary
                let appNum = value?["Number Denied"] as! Double
                self.deniedDataEntry.value = appNum
                print("This is in deniedData" + String(self.approvedDataEntry.value))
                self.updateChartData()
            })
        }
        
    }
}