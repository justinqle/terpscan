//
//  PackageDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct PackageDetailView: View {
    @ObservedObject var package: Package
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("recipient").font(.subheadline).fontWeight(.light)
                    Text("\(package.recipient!.firstName!) \(package.recipient!.lastName!)")
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text("tracking number").font(.subheadline).fontWeight(.light)
                    Text("\(package.trackingNumber!)")
                }
                Divider()
                
            }
            Text("Added \(package.timestamp!, formatter: dateFormatter)").font(.footnote)
            Spacer()
        }.padding(15)
            .navigationBarTitle("# \(package.trackingNumber!)")
            .navigationBarItems(
                trailing: EditButton()
        )
    }
}

struct PackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let package = Package.init(context: context)
        let contact = Contact.init(context: context)
        contact.firstName = "Justin"
        contact.lastName = "Le"
        contact.email = "justinqle@gmail.com"
        contact.phoneNumber = "2404472771"
        contact.buildingCode = "IRB"
        contact.roomNumber = "5109"
        package.recipient = contact
        package.trackingNumber = "1Z"
        package.timestamp = Date()
        return PackageDetailView(package: package).environment(\.managedObjectContext, context)
    }
}
