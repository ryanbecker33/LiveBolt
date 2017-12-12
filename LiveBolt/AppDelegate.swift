//
//  AppDelegate.swift
//  LiveBolt
//
//  Created by Ryan Becker on 10/15/17.
//  Copyright © 2017 Becker. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import UserNotifications

fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
fileprivate let mlCategoryIdentifier = "ML_CATEGORY"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var manager = CLLocationManager()
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationSettings()
        }
    }
    
    func registerCategories()
    {
        let viewAction = UNNotificationAction(identifier: "Yes",
                                              title: "Yes",
                                              options: [])
        
        let cancel = UNNotificationAction(identifier:  "No",
                                          title: "No",
                                          options: [])
        
        // 2
        let mlCategory = UNNotificationCategory(identifier: mlCategoryIdentifier,
                                                actions: [viewAction, cancel],
                                                intentIdentifiers: [],
                                                options: [])
        // 3
        UNUserNotificationCenter.current().setNotificationCategories([mlCategory])
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async(execute: {
                UIApplication.shared.registerForRemoteNotifications()
            })
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "deviceToken")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //mapView.delegate = self
        //mapView.showsUserLocation = true
        //mapView.userTrackingMode = .follow
        manager.delegate = self
        // 1. status is not determined
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
            manager.requestWhenInUseAuthorization()
        }
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("Authorized Location")
        }
        
        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        registerCategories()
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        // Do something with the visit.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "LiveBolt")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
       /* if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }*/
    }

}

extension AppDelegate {
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            let request = ServerRequest(type: "POST", endpoint: "/account/UpdateLocation", postString: "isHome=\(true)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            if(request.statusCode! == 200)
            {
                print("Good")
            }
            else
            {
                print("Bad")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            let request = ServerRequest(type: "POST", endpoint: "/account/UpdateLocation", postString: "isHome=\(false)")
            let defaults = UserDefaults.standard
            request.makeRequest(cookie: defaults.string(forKey: "cookie"))
            if(request.statusCode! == 200)
            {
                print("Good")
            }
            else
            {
                print("Bad")
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        switch response.actionIdentifier {
            case "Yes":
                let request = ServerRequest(type: "POST", endpoint: "/home/MLResponse", postString: "lockDoors=\(true)")
                let defaults = UserDefaults.standard
                request.makeRequest(cookie: defaults.string(forKey: "cookie"))
                if(request.statusCode! == 200)
                {
                    print("Good alert")
                }
                else
                {
                    print("Bad alert")
            }
            default:
                let request = ServerRequest(type: "POST", endpoint: "/home/MLResponse", postString: "lockDoors=\(false)")
                let defaults = UserDefaults.standard
                request.makeRequest(cookie: defaults.string(forKey: "cookie"))
                if(request.statusCode! == 200)
                {
                    print("Good alert")
                }
                else
                {
                    print("Bad alert")
            }
        }
        
        
        // 4
        completionHandler()
    }
}



