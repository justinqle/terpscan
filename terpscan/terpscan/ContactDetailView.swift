//
//  ContactDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

extension String {
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
}

struct ContactDetailView: View {
    @ObservedObject var contact: Contact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("email").font(.subheadline)
                Button(action: {
                    let tel = "mailto:"
                    let formattedString = tel + self.contact.email!
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("\(contact.email!)")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                Text("phone").font(.subheadline)
                Button(action: {
                    let tel = "tel://"
                    let formattedString = tel + self.contact.phoneNumber!
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("\(contact.phoneNumber!.toPhoneNumber())")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                Text("room").font(.subheadline)
                Text("\(contact.buildingCode!) \(contact.roomNumber!)")
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                Text("packages (\(contact.packages?.count ?? 0))").font(.subheadline)
                ForEach(Array(contact.packages as! Set<Package>), id: \.self) { package in
                    Text("\u{2022} \(package.timestamp!, formatter: dateFormatter): \(package.trackingNumber!)").lineLimit(1)
                }
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
        contact.phoneNumber = "2404472771"
        contact.buildingCode = "IRB"
        contact.roomNumber = "5120"
        return ContactDetailView(contact: contact)
    }
}
