//
//  AddContactView.swift
//  terpscan
//
//  Created by Justin Le on 3/18/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isPresented: Bool
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var roomNumber: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First name", text: $firstName).disableAutocorrection(true)
                    TextField("Last name", text: $lastName).disableAutocorrection(true)
                }
                Section {
                    TextField("Email", text: $email).disableAutocorrection(true).autocapitalization(.none)
                }
                Section {
                    // FIXME: Room number enforcement
                    TextField("Room number", text: $roomNumber).keyboardType(.numberPad)
                }
            }.navigationBarTitle("New Contact", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(
                        action: {
                            self.isPresented = false
                    }) {
                        Text("Cancel")
                    },
                    // FIXME: Disable until condition met
                    trailing: Button(
                        action: {
                            self.isPresented = false
                            withAnimation { Contact.create(in: self.viewContext,
                                                           firstName: self.firstName,
                                                           lastName: self.lastName,
                                                           email: self.email,
                                                           roomNumber: self.roomNumber,
                                                           packages: nil) }
                    }) {
                        Text("Done")
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView(isPresented: .constant(true))
    }
}
