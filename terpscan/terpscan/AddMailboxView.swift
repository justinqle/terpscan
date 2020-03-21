//
//  AddMailboxView.swift
//  terpscan
//
//  Created by Justin Le on 3/18/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct AddMailboxView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isPresented: Bool
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    @State var email: String = ""
    @State var phoneNumber: String = ""
    
    @State var selectedBuilding = 0
    @State var roomNumber: String = ""
    
    var buildings = ["IRB", "AVW", "None"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }.disableAutocorrection(true)
                Section {
                    TextField("Email", text: $email).disableAutocorrection(true).autocapitalization(.none)
                    TextField("Phone", text: $phoneNumber).textContentType(.telephoneNumber).keyboardType(.numberPad)
                }
                Section {
                    Picker(selection: $selectedBuilding, label: Text("Building")) {
                        ForEach(0 ..< buildings.count, id: \.self) {
                            Text(self.buildings[$0])
                        }
                    }
                    // FIXME: Room number enforcement
                    TextField("Room number", text: $roomNumber).keyboardType(.numberPad)
                }
            }.navigationBarTitle("New Mailbox", displayMode: .inline)
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
                            var buildingCode = Optional(self.buildings[self.selectedBuilding])
                            if buildingCode == "None" {
                                buildingCode = nil
                            }
                            withAnimation { Contact.create(in: self.viewContext,
                                                           firstName: self.firstName,
                                                           lastName: self.lastName,
                                                           email: self.email,
                                                           phoneNumber: self.phoneNumber,
                                                           buildingCode: buildingCode,
                                                           roomNumber: self.roomNumber,
                                                           packages: nil) }
                    }) {
                        Text("Done")
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddMailboxView_Previews: PreviewProvider {
    static var previews: some View {
        AddMailboxView(isPresented: .constant(true))
    }
}
