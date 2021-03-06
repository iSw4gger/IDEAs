//
//  AppDelegate.swift
//  IDEAs
//
//  Created by Jared Boynton on 5/27/18.
//  Copyright © 2018 Jared Boynton. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainVC: UIViewController?
    let user = User()

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        //checks to see if the user is logged in, and if so it directs them right to the main screen.
        if Auth.auth().currentUser != nil {
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "MainIdeas") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
            
            user.checkIfAdmin(completion: completeAdminAccess)
            print("IN APP DELEGATE")

        } else if Auth.auth().currentUser == nil{
            let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "LoginVC") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = initialViewControlleripad
            self.window?.makeKeyAndVisible()
        }
        
        isActive()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        isInactive()

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        isActive()
        user.checkIfAdmin(completion: completeAdminAccess)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        isInactive()
    }
    
    
    
    
    
    func completeAdminAccess(isAdmin: Bool){
        let defaults = UserDefaults.standard
        defaults.set(isAdmin, forKey: "isAdmin")
    }
    

    func isActive(){
        
        let currentUser = Auth.auth().currentUser
        if currentUser != nil{
            var email = (currentUser?.email)!
            if let dotRange = email.range(of: "@") {
                email.removeSubrange(dotRange.lowerBound..<email.endIndex)
            }
            
            DispatchQueue.main.async {
                let ref = Database.database().reference().child("UsersDB/\(email)")
                ref.updateChildValues(["Is Active" : true])

                }
            }
        }
    
    func isInactive(){
        
        let currentUser = Auth.auth().currentUser
        if currentUser != nil{
            var email = (currentUser?.email)!
            if let dotRange = email.range(of: "@") {
                email.removeSubrange(dotRange.lowerBound..<email.endIndex)
            }
            
            DispatchQueue.main.async {
                let ref = Database.database().reference().child("UsersDB/\(email)")
                ref.updateChildValues(["Is Active" : false])
                
            }
        }
    }

}

