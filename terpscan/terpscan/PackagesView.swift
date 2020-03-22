//
//  PackagesView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct PackagesView: View {
    var packagesRequest : FetchRequest<Package>
    var packages: FetchedResults<Package>{packagesRequest.wrappedValue}
    
    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.editMode) var mode
    
    @State public var selectedPackages = Set<Package>()
    
    init(recipient: Mailbox?) {
        var predicate: NSPredicate? = nil
        if let recipient = recipient {
            predicate = NSPredicate(format: "%K == %@", #keyPath(Package.recipient), recipient)
        }
        self.packagesRequest = FetchRequest<Package>(entity: Package.entity(),
                                                     sortDescriptors: [NSSortDescriptor(keyPath: \Package.timestamp, ascending: false)],
                                                     predicate: predicate,
                                                     animation: .default)
    }
    
    var body: some View {
        VStack {
            List(selection: $selectedPackages) {
                ForEach(packages, id: \.self) { package in
                    NavigationLink(
                        destination: PackageDetailView(package: package)
                    ) {
                        VStack(alignment: .leading) {
                            Text("\(package.recipient!.firstName!) \(package.recipient!.lastName!)").font(.headline)
                            HStack {
                                Text("TRK#:").font(.caption)
                                Text("\(package.trackingNumber!)")
                            }
                            HStack {
                                Text("Received:").font(.caption)
                                Text("\(package.timestamp!, formatter: dateFormatter)")
                            }
                        }
                    }
                }.onDelete { indices in
                    self.packages.deletePackage(at: indices, from: self.viewContext)
                }
            }
        }
    }
}

struct PackagesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = Mailbox.init(context: context)
        mailbox.firstName = "Justin"
        mailbox.lastName = "Le"
        mailbox.email = "justinqle@gmail.com"
        mailbox.phoneNumber = "2404472771"
        mailbox.buildingCode = "IRB"
        mailbox.roomNumber = "5109"
        return PackagesView(recipient: mailbox).environment(\.managedObjectContext, context)
    }
}
