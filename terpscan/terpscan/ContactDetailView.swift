//
//  ContactDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct ContactDetailView: View {
    @ObservedObject var contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("email").font(.subheadline)
            Button(action: {
                let tel = "mailto:"
                let formattedString = tel + self.contact.email!
                guard let url = URL(string: formattedString) else { return }
                UIApplication.shared.open(url)
            }) {
                Text("\(contact.email!)")
            }
            Divider()
            Text("room number").font(.subheadline)
            Text("\(contact.roomNumber!)")
            Divider()
            Text("packages (\(contact.packages?.count ?? 0))").font(.subheadline)
            ForEach(Array(contact.packages as! Set<Package>), id: \.self) { package in
                Text("\u{2022} \(package.timestamp!, formatter: dateFormatter): \(package.trackingNumber!)").lineLimit(1)
            }
            Spacer()
        }.padding(15)
            .navigationBarTitle("\(contact.firstName!) \(contact.lastName!)")
            .navigationBarItems(
                trailing: EditButton()
        )
    }
}


struct ContactDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let contact = Contact.init(context: context)
        contact.firstName = "Justin"
        contact.lastName = "Le"
        contact.email = "justinqle@gmail.com"
        contact.roomNumber = "5120"
        return ContactDetailView(contact: contact)
    }
}
