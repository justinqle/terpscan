//
//  MailboxDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

extension String {
    // Pretty-print phone number
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
}

struct MailboxDetailView: View {
    @ObservedObject var mailbox: Mailbox
    
    @Environment(\.managedObjectContext)
    var viewContext
    @Environment(\.editMode)
    var mode
    
    @State var showingAddPackage = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("room").font(.subheadline).fontWeight(.light)
                Text("\(mailbox.buildingCode!) \(mailbox.roomNumber!)")
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                Text("phone").font(.subheadline).fontWeight(.light)
                Button(action: {
                    let tel = "tel://"
                    let formattedString = tel + self.mailbox.phoneNumber!
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("\(mailbox.phoneNumber!.toPhoneNumber())")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("email").font(.subheadline).fontWeight(.light)
                    Spacer()
                    Button(
                        action: {
                            // action
                    }) {
                        HStack {
                            Text("Renotify")
                            Image(systemName: "envelope")
                        }
                    }
                }
                Button(action: {
                    let tel = "mailto:"
                    let formattedString = tel + self.mailbox.email!
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("\(mailbox.email!)")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("packages").font(.subheadline).fontWeight(.light)
                    Text("(\(mailbox.packages?.count ?? 0))").font(.subheadline).fontWeight(.heavy)
                    Spacer()
                    Button(
                        action: {
                            // action
                    }) {
                        HStack {
                            Text("View History")
                            Image(systemName: "clock")
                        }
                    }
                }
                PackagesView(recipient: mailbox)
            }
            Spacer()
            HStack {
                if self.mode?.wrappedValue == .active {
                    Button(
                        action: {
                            // action
                    }) {
                        Text("Check Out").fontWeight(.bold)
                    }
                }
                Spacer()
                Button(
                    action: {
                        self.showingAddPackage.toggle()
                }) {
                    HStack {
                        Text("New Package")
                        Image(systemName: "plus")
                    }
                }
                .sheet(isPresented: $showingAddPackage) {
                    // FIXME: Workaround to package adding in modal with managedObjectContext
                    AddPackageView(isPresented: self.$showingAddPackage, recipient: self.mailbox).environment(\.managedObjectContext, self.viewContext)
                }
            }
        }.padding(15)
            .navigationBarTitle("\(mailbox.firstName!) \(mailbox.lastName!)")
            .navigationBarItems(
                trailing: EditButton()
        )
    }
}

struct MailboxDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = Mailbox.init(context: context)
        mailbox.firstName = "Justin"
        mailbox.lastName = "Le"
        mailbox.email = "justinqle@gmail.com"
        mailbox.phoneNumber = "2404472771"
        mailbox.buildingCode = "IRB"
        mailbox.roomNumber = "5109"
        return MailboxDetailView(mailbox: mailbox).environment(\.managedObjectContext, context)
    }
}