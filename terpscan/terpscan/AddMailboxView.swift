//
//  AddMailboxView.swift
//  terpscan
//
//  Created by Justin Le on 3/18/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

extension String {
    var isValidEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}

struct AddMailboxView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isPresented: Bool
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    @State var selectedBuilding = 1
    @State var roomNumber: String = ""
    
    @State var phoneNumber: String = ""
    @State var email: String = ""
    
    var buildings = ["None", "IRB", "AVW"]
    
    var disableForm: Bool {
        firstName.isEmpty || lastName.isEmpty || !email.isValidEmail || (selectedBuilding != 0 && roomNumber.isEmpty)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }.disableAutocorrection(true)
                Section {
                    Picker(selection: $selectedBuilding, label: Text("Building")) {
                        ForEach(0 ..< buildings.count, id: \.self) {
                            Text(self.buildings[$0])
                        }
                    }
                    TextField("Room number", text: $roomNumber).keyboardType(.numberPad).disabled(selectedBuilding == 0)
                }
                Section {
                    TextField("Phone", text: $phoneNumber).keyboardType(.numberPad)
                    TextField("Email", text: $email).disableAutocorrection(true).autocapitalization(.none).keyboardType(.emailAddress)
                }
            }.navigationBarTitle("New Mailbox", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(
                        action: {
                            self.isPresented = false
                    }) {
                        Text("Cancel")
                    },
                    trailing: Button(
                        action: {
                            self.isPresented = false
                            let buildingCode = Optional(self.buildings[self.selectedBuilding])
                            withAnimation { Mailbox.create(in: self.viewContext,
                                                           firstName: self.firstName,
                                                           lastName: self.lastName,
                                                           email: self.email,
                                                           phoneNumber: self.phoneNumber.isEmpty ? nil : self.phoneNumber,
                                                           buildingCode: buildingCode == "None" ? nil : buildingCode,
                                                           roomNumber: buildingCode == "None" ? nil: self.roomNumber,
                                                           packages: nil) }
                    }) {
                        Text("Done")
                    }.disabled(disableForm)
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct AddMailboxView_Previews: PreviewProvider {
    static var previews: some View {
        AddMailboxView(isPresented: .constant(true))
    }
}
