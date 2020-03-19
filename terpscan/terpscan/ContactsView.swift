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
    
    var body: some View {
        List {
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


struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContactsView().environment(\.managedObjectContext, context)
    }
}
