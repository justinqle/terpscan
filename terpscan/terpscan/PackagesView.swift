//
//  PackagesView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct PackagesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Package.timestamp, ascending: false)],
        animation: .default)
    var packages: FetchedResults<Package>
    
    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.editMode) var mode
    
    @State public var selectedPackages = Set<Package>()
    
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
        return PackagesView().environment(\.managedObjectContext, context)
    }
}
