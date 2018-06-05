//
//  DashboardViewController.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/30/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Charts
import Firebase
import FirebaseDatabase
import Charts

class DashboardViewController: UIViewController {
    
    
    
    
    
//MARK: - SETUP VARIABLES
    
    @IBOutlet weak var graphView: BarChartView!
    
    var ideaDesc: String = ""
    var ideaID : Int = 0
    var ideaTitle : String = ""
    var approvedResultsArray = [Idea]()
    var deniedResultsArray = [Idea]()
    var approverArray = [String]()
    var denierArray = [String]()
    var numApproverArray = [String]()
    var numberDenied = 0
    var numberApproved = 0
    
    
    
    
    
    
//MARK: - STANDARD VIEW DID LOAD CODE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Total Volume"
        
        barChartUpdate()
        
        //pieChartUpdate()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
//MARK: - SETTING UP CHART
    
    func barChartUpdate(){
        //bar chart code
        
        let entry1 = BarChartDataEntry(x: 1.0, y: Double(numberApproved))//this value is gotten from # approved
        let entry2 = BarChartDataEntry(x: 2.0, y: Double(numberDenied)) //number denied
        print("barChartUpdate")
        let dataSet = BarChartDataSet(values: [entry1, entry2], label: "")
        let data = BarChartData(dataSets: [dataSet])
        graphView.data = data
        graphView.chartDescription?.text = ""
        let colors = [UIColor.flatMint(), UIColor.flatPurple()]
        dataSet.colors = colors as! [NSUIColor]
        
        graphView.drawGridBackgroundEnabled = false
        graphView.gridBackgroundColor = UIColor.white
        graphView.xAxis.labelTextColor = UIColor.white
        
        graphView.xAxis.drawAxisLineEnabled = false
        graphView.xAxis.axisLineColor = UIColor.white
        
        graphView.animate(xAxisDuration: 0.5)
        graphView.animate(yAxisDuration: 0.5)
        
        graphView.notifyDataSetChanged()
        
    }
    
    
    
    //    func pieChartUpdate(){
    //        //pie chart code
    //
    //        let entry1 = PieChartDataEntry(value: Double(3.0), label: "Approved")
    //        let entry2 = PieChartDataEntry(value: Double(5.0), label: "Denied")
    //        let dataSet = PieChartDataSet(values: [entry1, entry2], label: "Votes")
    //        let data = PieChartData(dataSet: dataSet)
    //        pieChartView.data = data
    //        pieChartView.chartDescription?.text = ""
    //        let colors = [UIColor.flatMint(), UIColor.flatPurple()]
    //        dataSet.colors = colors as! [NSUIColor]
    //        dataSet.label = ""
    //        pieChartView.legend.font = UIFont(name: "Futura", size: 8)!
    //        pieChartView.entryLabelFont = UIFont(name: "Futura", size: 8)
    //
    //        //All other additions to this function will go here
    //
    //        //This must stay at end of function
    //        pieChartView.notifyDataSetChanged()
    //
    //
    //    }
    
}
