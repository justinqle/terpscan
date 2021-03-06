//
//  AppDelegate.swift
//  terpscan
//
//  Created by Justin Le on 3/17/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    
    func isAppAlreadyLaunchedOnce() -> Bool {
        let defaults = UserDefaults.standard
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            return true
        } else {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            return false
        }
    }
    
    func populateWithUMDCSFaculty() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let asset = NSDataAsset(name: "Faculty", bundle: Bundle.main)
        do {
            if let json = try JSONSerialization.jsonObject(with: asset!.data, options: []) as? [String: Any] {
                if let faculty = json["faculty"] as? NSArray {
                    for staff in faculty {
                        if let staff = staff as? NSDictionary {
                            let mailbox = Mailbox.init(context: context)
                            mailbox.lastName = staff.object(forKey: "lastName") as? String
                            mailbox.firstName = staff.object(forKey: "firstName") as? String
                            if let room = (staff.object(forKey: "room") as? String)?.split(separator: " ").map({String($0)}) {
                                mailbox.buildingCode = room[0]
                                mailbox.roomNumber = room[1]
                            }
                            mailbox.phoneNumber = (staff.object(forKey: "phone") as? String)?.replacingOccurrences(of: "\\((\\d{3})\\) (\\d{3})-(\\d+)", with: "$1$2$3", options: .regularExpression, range: nil)
                            mailbox.email = staff.object(forKey: "email") as? String
                        }
                    }
                    try context.save()
                }
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !isAppAlreadyLaunchedOnce() {
//            populateWithUMDCSFaculty()
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentCloudKitContainer(name: "terpscan")
        
        // get the store description
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Could not retrieve a persistent store description.")
        }
        
        let publicStoreURL = description.url!.deletingLastPathComponent().appendingPathComponent("terpscan-public.sqlite")
        let identifier = description.cloudKitContainerOptions!.containerIdentifier
        
        let publicDescription = NSPersistentStoreDescription(url: publicStoreURL)
        publicDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        publicDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        var publicOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        publicOptions.databaseScope = .public
        
        publicDescription.cloudKitContainerOptions = publicOptions
        container.persistentStoreDescriptions = [publicDescription]
        
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
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
//        do {
//            try container.initializeCloudKitSchema()
//        } catch {
//            print("Unable to initialize CloudKit schema: \(error.localizedDescription)")
//        }
        
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

}

