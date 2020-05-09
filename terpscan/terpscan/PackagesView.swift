//
//  PackagesView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct AllInboxesView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var showingAddPackage = false
    
    var body: some View {
        EditCheckoutView(recipient: nil)
            .navigationBarTitle(Text("All Inboxes"), displayMode: .large)
            .navigationBarItems(
                trailing: Button(
                    action: {
                        self.showingAddPackage = true
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
        PackagesView(recipient: nil, archivedOnly: true, selectedPackages: nil)
            .navigationBarTitle(Text("Archive"), displayMode: .large)
    }
}

struct EditCheckoutView: View {
    @Environment(\.editMode) var mode
    
    @State private var showingCheckOutPackage = false
    @State private var selectedPackages = Set<Package>()
    
    private var recipient: Mailbox?
    
    init(recipient: Mailbox?) {
        self.recipient = recipient
    }
    
    var body: some View {
        VStack {
            PackagesView(recipient: recipient, archivedOnly: false, selectedPackages: $selectedPackages)
            Spacer()
            HStack {
                if self.mode?.wrappedValue == .active {
                    Button(
                        action: {
                            self.showingCheckOutPackage = true
                    }) {
                        Text("Check Out").fontWeight(.bold)
                    }
                    .disabled(selectedPackages.isEmpty)
                    .sheet(isPresented: $showingCheckOutPackage) {
                        CheckOutView(isPresented: self.$showingCheckOutPackage)
                            .accentColor(primaryColor)
                    }
                }
                Spacer()
                EditButton()
            }.padding(15)
        }
    }
}

extension Date {
    func formatRelativeString() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        dateFormatter.doesRelativeDateFormatting = true
        
        if calendar.isDateInToday(self) {
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
        } else if calendar.isDateInYesterday(self){
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .medium
        } else if calendar.compare(Date(), to: self, toGranularity: .weekOfYear) == .orderedSame {
            let weekday = calendar.dateComponents([.weekday], from: self).weekday ?? 0
            return dateFormatter.weekdaySymbols[weekday-1]
        } else {
            dateFormatter.timeStyle = .none
            dateFormatter.dateStyle = .short
        }
        return dateFormatter.string(from: self)
    }
}

struct PackageCellView: View {
    @ObservedObject var package: Package
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("\(package.recipient!.firstName!) \(package.recipient!.lastName!)").font(.headline)
                Spacer()
                Text("\(package.timestamp!.formatRelativeString())").font(.subheadline)
            }
            Text("# \(package.trackingNumber!)")
        }
    }
}

struct PackagesView: View {
    private var packagesRequest : FetchRequest<Package>
    private var packages: FetchedResults<Package>{packagesRequest.wrappedValue}
    
    private var selectedPackages: Binding<Set<Package>>?
    
    init(recipient: Mailbox?, archivedOnly: Bool, selectedPackages: Binding<Set<Package>>?) {
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
        self.selectedPackages = selectedPackages
    }
    
    var body: some View {
        List(selection: selectedPackages) {
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
