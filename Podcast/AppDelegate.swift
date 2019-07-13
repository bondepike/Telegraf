//
//  AppDelegate.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 2/14/18.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let masterController = MasterController()
        window?.rootViewController = masterController

        setupAppearance()

        setupJWT()
        getNotificationSettings()
        print("Launched YYY")

        return true
    }
    
    fileprivate func setupJWT() {        
        if let jwt = UserDefaults.standard.string(forKey: "jwt") {
            print("JWT: \(jwt)")
            NetworkAPI.shared.checkJWTValidation { (valid) in
                if !valid {
                    print("is not valid")
                    NetworkAPI.shared.fetchJWT { (jwt) in
                        UserDefaults.standard.set(jwt, forKey: "jwt")
                    }
                } else {
                    //self.saveToICloud(jwt)
                }
            }
            return
        }
        NetworkAPI.shared.fetchJWT { (jwt) in
            UserDefaults.standard.set(jwt, forKey: "jwt")
            self.saveToICloud(jwt)
        }
    }
    
    func saveToICloud(_ jwt: String) {
        let jwtRecord = CKRecord(recordType: "details")
        jwtRecord["jwt"] = jwt as CKRecordValue
        CKContainer.default().privateCloudDatabase.save(jwtRecord) { (record, err) in
            if let err = err {
                print("Failed to save to iCloud: ", err)
                return
            }
        }
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().tintColor = .kindaBlack
        //UIColor(red:0.57, green:0.60, blue:0.64, alpha:1.00)//.applePink
        UINavigationBar.appearance().backgroundColor = .white

        UINavigationBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().shadowImage = UIImage()
        
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        //UINavigationBar.appearance().backgroundColor = .white
        //UINavigationBar.appearance().isTranslucent = false
        //UINavigationBar.appearance().layer.borderColor = UIColor.white.cgColor
        
        UISearchBar.appearance().backgroundImage = UIImage()
        UISearchBar.appearance().layer.borderColor = UIColor.white.cgColor

        //UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = .applePink//.ibmBlue
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "IBMPlexSans", size: 18) as Any,
            NSAttributedStringKey.foregroundColor : UIColor.kindaBlack,
            ], for: .normal)
        UISearchBar.appearance().tintColor = UIColor.applePink
    }

    fileprivate func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    fileprivate func uploadDeviceToken(token: String) {
        print("Uploading device token")
        NetworkAPI.shared.uploadDeviceToken(deviceToken: token)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        print("Handle events for: ", identifier)
        
        completionHandler()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Token: ", token)
        uploadDeviceToken(token: token)
    }
    

}

