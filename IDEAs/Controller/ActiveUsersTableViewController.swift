

import UIKit
import Firebase
import FirebaseAuth
import Spring

class ActiveUsersTableViewController: UITableViewController {
    
    var usersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveUsers()

        self.title = "Users"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //default functions to setup table view. Use this to set the values of the labels from the cell.
        let cell = tableView.dequeueReusableCell(withIdentifier: "activeUsersTableViewCell", for: indexPath) as! ActiveUserTableViewCell
        //assign array values to the cells. I did this to prevent out of bounds index problems.
        if usersArray.isEmpty{
            print("array is empty in ActiveVC")
        }else{
            cell.userNameTextField.text = "\(usersArray[indexPath.row].firstName) \(usersArray[indexPath.row].lastName)"
            if usersArray[indexPath.row].isActive == true{
                cell.onlineStatusIndicator.backgroundColor = UIColor.flatGreen()
                //rounds corners of indicators
                cell.onlineStatusIndicator.layer.cornerRadius = 10
                cell.onlineStatusIndicator.clipsToBounds = true
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.flatGreen()
                cell.selectedBackgroundView = backgroundView
            }else{
                cell.onlineStatusIndicator.backgroundColor = UIColor.flatGray()
                //rounds corners of indicator
                cell.onlineStatusIndicator.layer.cornerRadius = 10
                cell.onlineStatusIndicator.clipsToBounds = true
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.flatGray()
                cell.selectedBackgroundView = backgroundView

            }
        }
        
        //changes the background color when selected.

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
    func retrieveUsers(){
        
        let usersDB = Database.database().reference().child("UsersDB")
        usersDB.observe(.childAdded) { (snapshot) in
            
            //.value sends back an object type of 'any', so we have to cast it to dictionary.
            let snapShotValue = snapshot.value as! Dictionary<String, Any>
            let firstNameSnap = snapShotValue["First Name"]
            let lastNameSnap = snapShotValue["Last Name"]
            let emailSnap = snapShotValue["Email"]
            let activeSnap = snapShotValue["Is Active"]

            
            let users = User()
            users.firstName = firstNameSnap as! String
            users.lastName = lastNameSnap as! String
            users.emailAddress = emailSnap as! String
            users.isActive = activeSnap as! Bool
            
            print("In Active Users \(users.firstName)")
            
            self.usersArray.append(users)
            self.tableView.reloadData()
        }
    }
    
}
