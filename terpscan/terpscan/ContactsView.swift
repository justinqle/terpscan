//
//  ContactsView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct ContactsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contact.lastName, ascending: true)],
        animation: .default)
    var contacts: FetchedResults<Contact>
    
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State var selectKeeper = Set<Contact>()
    
    var body: some View {
        List(selection: $selectKeeper) {
            ForEach(contacts, id: \.self) { contact in
                NavigationLink(
                    destination: ContactDetailView(contact: contact)
                ) {
                    HStack(spacing: 4) {
                        Text("\(contact.firstName!)")
                        Text("\(contact.lastName!)").fontWeight(.bold)
                    }
                }
            }.onDelete { indices in
                self.contacts.deleteContact(at: indices, from: self.viewContext)
            }
        }
    }
}

struct ContactDetailView: View {
    @ObservedObject var contact: Contact
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("First name", text: Binding($contact.firstName)!)
                TextField("Last name", text: Binding($contact.lastName)!)
            }
            Section(header: Text("Email")) {
                TextField("Email", text: Binding($contact.email)!)
            }
            Section(header: Text("Room number")) {
                TextField("Room number", text: Binding($contact.roomNumber)!)
            }
        }.disabled(true)
            .navigationBarTitle("\(contact.firstName!) \(contact.lastName!)")
            .navigationBarItems(
                trailing: EditButton()
        )
    }
}


struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContactsView().environment(\.managedObjectContext, context)
    }
}
