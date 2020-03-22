//
//  Mailbox.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CoreData

extension Mailbox {
    static func create(in managedObjectContext: NSManagedObjectContext,
                       firstName: String,
                       lastName: String,
                       email: String,
                       phoneNumber: String?,
                       buildingCode: String?,
                       roomNumber: String?,
                       packages: NSSet?) {
        let newMailbox = self.init(context: managedObjectContext)
        newMailbox.firstName = firstName
        newMailbox.lastName = lastName
        newMailbox.email = email
        if let phoneNumber = phoneNumber {
            newMailbox.phoneNumber = phoneNumber
        }
        if let buildingCode = buildingCode {
            newMailbox.buildingCode = buildingCode
        }
        if let roomNumber = roomNumber {
            newMailbox.roomNumber = roomNumber
        }
        if let packages = packages {
            newMailbox.packages = packages
        }
        
        do {
            try  managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

extension Collection where Element == Mailbox, Index == Int {
    func deleteMailbox(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
        indices.forEach { managedObjectContext.delete(self[$0]) }
        
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
