//
//  PackagesView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct AllInboxesView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.editMode) var mode
    
    @State var showingAddPackage = false
    
    var body: some View {
        EditCheckoutView(recipient: nil)
            .navigationBarTitle(Text("All Inboxes"), displayMode: .large)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        self.showingAddPackage.toggle()
                }) {
                    HStack {
                        Text("New Package")
                        Image(systemName: "plus")
                    }
                }.sheet(isPresented: $showingAddPackage) {
                    // FIXME: Workaround to package adding in modal with managedObjectContext
                    AddPackageView(isPresented: self.$showingAddPackage, recipient: nil).environment(\.managedObjectContext, self.viewContext)
                }
        )
    }
}

struct ArchiveView: View {
    var body: some View {
        PackagesView(recipient: nil, archivedOnly: true)
            .navigationBarTitle(Text("Archive"), displayMode: .large)
    }
}

struct EditCheckoutView: View {
    @Environment(\.editMode) var mode
    
    @State var showingAddPackage = false
    
    private var recipient: Mailbox?
    
    init(recipient: Mailbox?) {
        self.recipient = recipient
    }
    
    var body: some View {
        VStack {
            PackagesView(recipient: recipient, archivedOnly: false)
            Spacer()
            HStack {
                if self.mode?.wrappedValue == .active {
                    Button(
                        action: {
                            // action
                    }) {
                        Text("Check Out").fontWeight(.bold)
                    }
                }
                Spacer()
                EditButton()
            }.padding(15)
        }
    }
}

struct PackageCellView: View {
    @ObservedObject var package: Package
    
    var body: some View {
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
}

struct PackagesView: View {
    var packagesRequest : FetchRequest<Package>
    var packages: FetchedResults<Package>{packagesRequest.wrappedValue}
    
    @State public var selectedPackages = Set<Package>()
    
    init(recipient: Mailbox?, archivedOnly: Bool) {
        let andPredicate: NSCompoundPredicate
        var subpredicates: [NSPredicate] = []
        if let recipient = recipient {
            subpredicates.append(NSPredicate(format: "%K == %@", #keyPath(Package.recipient), recipient))
        }
        if archivedOnly {
            subpredicates.append(NSPredicate(format: "%K != nil", #keyPath(Package.receipt)))
        }
        andPredicate = NSCompoundPredicate(type: .and, subpredicates: subpredicates)
        self.packagesRequest = FetchRequest<Package>(entity: Package.entity(),
                                                     sortDescriptors: [NSSortDescriptor(keyPath: \Package.timestamp, ascending: false)],
                                                     predicate: andPredicate,
                                                     animation: .default)
    }
    
    var body: some View {
        List(selection: $selectedPackages) {
            ForEach(packages, id: \.self) { package in
                NavigationLink(
                    destination: PackageDetailView(package: package)
                ) {
                    PackageCellView(package: package)
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
        return NavigationView {
            AllInboxesView().environment(\.managedObjectContext, context)
            //ArchiveView().environment(\.managedObjectContext, context)
            //EditCheckoutView(recipient: mailbox).environment(\.managedObjectContext, context)
        }
    }
}
