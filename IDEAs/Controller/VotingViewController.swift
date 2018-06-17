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

//MARK: - SETTING UP VARIABLES
    
    //setup outlets
    @IBOutlet weak var voteIdeaTitle: UILabel!
    @IBOutlet weak var voteIdeaDescription: UILabel!
    @IBOutlet weak var approvedBar: UIView!
    @IBOutlet weak var deniedBar: UIView!
    @IBOutlet weak var approveButton: SpringButton!
    @IBOutlet weak var denyButton: SpringButton!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var resetButton: UIButton!
    
    
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

    
    

//MARK: - STANDARD VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()

        //setup bar button and button pressed to go to active users
        let testUIBarButtonItem = UIBarButtonItem(image: UIImage(named: "businessman"), style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem  = testUIBarButtonItem
        testUIBarButtonItem.action = #selector(goToUsers)
        
        //grabs the current email and erases everything past the @ symbol so it can be added to DB as child
        email = (currentUser?.email)!
        if let dotRange = email.range(of: "@") {
            email.removeSubrange(dotRange.lowerBound..<email.endIndex)
        }
        //set the title of the NavBar to the ideaID
        self.title = "IDEA # \(ideaID)"
        
        barChartView.noDataText = "No Data Available"
        
        barChartUpdate()
        
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
        
        //dont want a description as it's ugly.
        //pieChartView.chartDescription?.text = ""
        
        //sets the label in the chart and on the legend.
        approvedDataEntry.label = "Approved"
        deniedDataEntry.label = "Denied"
        
        //storing the entries in an array that was established above.
        numberOfVotesDataEntries = [approvedDataEntry, deniedDataEntry]
        
        //these two methods are causing app to crash if you go to vote, then go back and try to delete the IDEA.
        updateApproveData()
        updateDenialData()
        updateApprovalPerson()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func goToUsers(){
        performSegue(withIdentifier: "goToUsers", sender: self)
    }
    
    
//MARK: - SETTING UP THE VOTING BUTTONS
    
    @IBAction func approveButtonPressed(_ sender: Any) {

//        // grab a reference of the master DB + child DB and update those points within the ideaID
        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")


        approvedDataEntry.value = approvedDataEntry.value + 1.0
        ref.updateChildValues(["Number Approved" : approvedDataEntry.value])

        
        //created a dictionary to store the values in the database. Each of these will be separate data points. They come from what the user typed in, plus the original values stored in the Idea class.
        let ideaDictionary: [String:String] = [email : email]
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ref.child("Approver").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                //self.updateChartData()
                self.barChartUpdate()
                self.updateApproveData()
                self.updateApprovalPerson()
            }
        }
    }
    
    
    @IBAction func denyButtonPressed(_ sender: Any) {
        
        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")
        ref.updateChildValues(["Approved" : false])
        
        ref.updateChildValues(["Active" : false])
        ref.updateChildValues(["Number Denied" : self.deniedDataEntry.value + 1])
        
        let ideaDictionary: [String:String] = [email : email]
        
        //we use the 'ActiveIdeaDB' database and insert a child with the ideaID so that all the values above can be stored within each ID. Must use closure for error checking.
        ref.child("Denier").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                //self.updateChartData()
                self.barChartUpdate()
                self.updateDenialData()
                self.updateDenierPerson()
            }
        }
    }
    
    
    
    
    
    
    
    
    //MARK: - GRABBING AND UPDATING DATA FROM DATABASE

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
    
    func updateApproveData(){
        //calling it on the main thread so it appears on the other persons screen.
        DispatchQueue.main.async {
            let ref = Database.database().reference().child("ActiveIdeaDB/\(self.ideaID)")
            ref.observe(DataEventType.value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let appNum = value?["Number Approved"] as! Double
                self.approvedDataEntry.value = appNum
                print("This is in updateApproveData" + String(self.approvedDataEntry.value))
                self.barChartUpdate()
                
                //logic that makes the idea approved.
                if self.approvedDataEntry.value == 7.0{
                    SVProgressHUD.showSuccess(withStatus: "This IDEA was approved.")
                    ref.updateChildValues(["Approved" : true])
                    //switching to active. May need to update logic here.
                    ref.updateChildValues(["Active" : false])
                }
                if self.deniedDataEntry.value >= 1{
                    SVProgressHUD.showError(withStatus: "This IDEA was denied.")
                    ref.updateChildValues(["Approved" : false])
                    //switching to active. May need to update logic here.
                    ref.updateChildValues(["Active" : false])
                    self.approveButton.isEnabled = false
                    self.denyButton.isEnabled = false
                }
                //self.updateChartData()
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
                //self.updateChartData()
                self.barChartUpdate()
            })
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
//MARK: - CHART BUILD & UPDATING DATA FOR CHART
    
    func updateChartData(){
        
        if approvedDataEntry.value != 0 && deniedDataEntry.value != 0{
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
    
    func barChartUpdate(){
        //bar chart code
        
        let entry1 = BarChartDataEntry(x: 1.0, y: Double(approvedDataEntry.value))//this value is gotten from # approved
        let entry2 = BarChartDataEntry(x: 2.0, y: Double(deniedDataEntry.value)) //number denied
        print("barChartUpdate")
        let dataSet = BarChartDataSet(values: [entry1, entry2], label: "")
        let data = BarChartData(dataSets: [dataSet])
        data.addEntry(entry1, dataSetIndex: 1)
        barChartView.data = data
        barChartView.chartDescription?.text = ""
        let colors = [UIColor.flatMint(), UIColor.flatPurple()]
        dataSet.colors = colors as! [NSUIColor]
        
        barChartView.drawGridBackgroundEnabled = false
        barChartView.gridBackgroundColor = UIColor.white
        barChartView.xAxis.labelTextColor = UIColor.clear

        
        
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.labelFont = UIFont.boldSystemFont(ofSize: 12)
        barChartView.leftAxis.labelTextColor = UIColor.flatPink()
        
        barChartView.animate(xAxisDuration: 0.5)
        barChartView.animate(yAxisDuration: 0.5)
        barChartView.notifyDataSetChanged()
        
        //set y axis min and max
        barChartView.rightAxis.axisMinimum = 0
        barChartView.rightAxis.axisMaximum = 10
        barChartView.leftAxis.axisMinimum = 0
        barChartView.leftAxis.axisMaximum = 10
        
        
    }
    
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        approvedDataEntry.value = 0
        deniedDataEntry.value = 0
        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")
        
        //updates the bar chart data points and switches the status'
        ref.updateChildValues(["Number Approved" : approvedDataEntry.value])
        ref.updateChildValues(["Number Denied" : approvedDataEntry.value])
        ref.updateChildValues(["Approved" : false])
        ref.updateChildValues(["Active" : true])
        let ideaDictionary: [String:String] = [email : ""]
        

        //replaces the email value with an empty string.
        ref.child("Denier").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                //self.updateChartData()
                self.barChartUpdate()
                self.updateDenialData()
                self.updateDenierPerson()
            }
        }
        ref.child("Approver").updateChildValues(ideaDictionary){
            (error, reference) in
            if error != nil{
                print(error!)
            }else{
                print("success")
                //self.updateChartData()
                self.barChartUpdate()
                self.updateDenialData()
                self.updateDenierPerson()
            }
        }
        
        //standard updating of the chart and values
        self.barChartUpdate()
        self.updateDenialData()
        self.updateDenierPerson()
        approverArray.removeAll()
        updateApproveData()
        approveButton.isEnabled = true
        denyButton.isEnabled = true

    }
    
    
    func checkApprovalStatus(){
        print(approvedDataEntry.value)
        let ref = Database.database().reference().child("ActiveIdeaDB/\(ideaID)")
        if approvedDataEntry.value >= 7{
            print("inside loop")
            //switching it to approved. May need to update logic
            ref.updateChildValues(["Approved" : true])
            
            //switching to active. May need to update logic here.
            ref.updateChildValues(["Active" : false])
            
            //TODO: - may need to get rid of this
            SVProgressHUD.showSuccess(withStatus: "This IDEA has been approved.")

        }
        ref.updateChildValues(["Number Approved" : approvedDataEntry.value])
        updateApproveData()
    }
    
    
    
    
    //MARK: - PREPARING DATA TO BE TRANSFERRED TO ANOTHER VC
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //this is necessary to remove the rows that were switched from active to inactive. Otherwise, still appears in the active VC
        if segue.identifier == "segueToVote"{
            let vc = segue.destination as! ActiveTableViewController
            vc.ideaArray.removeAll()
            //vc.retrieveData()
            vc.activeIdeaTableView.reloadData()
            vc.tableView.reloadData()
        }
    }
    
}
