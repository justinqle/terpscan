//
//  Contact.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CoreData

extension Contact {
    static func create(in managedObjectContext: NSManagedObjectContext,
                       firstName: String,
                       lastName: String,
                       email: String,
                       roomNumber: String?,
                       packages: NSSet?) {
        let newContact = self.init(context: managedObjectContext)
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.email = email
        newContact.roomNumber = roomNumber
        if let packages = packages {
            newContact.packages = packages
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

extension Collection where Element == Contact, Index == Int {
    func deleteContact(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
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
