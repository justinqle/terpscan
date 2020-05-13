//
//  Receipt.swift
//  terpscan
//
//  Created by Justin Le on 5/9/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CoreData

extension Receipt {
    static func create(in managedObjectContext: NSManagedObjectContext, signer: String, signature: UIImage, packages: Set<Package>){
        let newReceipt = self.init(context: managedObjectContext)
        newReceipt.timestamp = Date()
        newReceipt.signer = signer
        newReceipt.signature = signature.jpegData(compressionQuality: 1.0)
        newReceipt.packages = packages as NSSet
        
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

extension Collection where Element == Receipt, Index == Int {
    func deleteReceipt(at indices: IndexSet, from managedObjectContext: NSManagedObjectContext) {
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
