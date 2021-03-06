//
//  MailboxDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import MessageUI

extension String {
    // Pretty-print phone number
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: nil)
    }
}

// FIXME: Better way to do this?
public func getUnarchived(from recipient: Mailbox?) -> [Package] {
    if let packages = recipient?.packages?.allObjects as? [Package] {
        return packages.filter({p in p.receipt == nil})
    } else {
        return []
    }
}

// FIXME: Better way to do this?
public func numOfUnarchived(from recipient: Mailbox?) -> Int {
    getUnarchived(from: recipient).count
}

struct MailboxDetailView: View {
    @ObservedObject var mailbox: Mailbox
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.editMode) var mode
    @Environment(\.presentationMode) var presentation
    
    @State var showingAddPackage = false
    
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                Text("room").font(.subheadline).fontWeight(.light)
                Text("\(mailbox.buildingCode ?? "") \(mailbox.roomNumber ?? "")")
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
                    Text("\(mailbox.phoneNumber?.toPhoneNumber() ?? "")")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("email").font(.subheadline).fontWeight(.light)
                    Spacer()
                    Button(
                        action: {
                            self.isShowingMailView.toggle()
                    }) {
                        HStack {
                            Text("Notify")
                            Image(systemName: "envelope")
                        }
                    }
                    .disabled(!MFMailComposeViewController.canSendMail() || mailbox.email == nil)
                    .sheet(isPresented: $isShowingMailView) {
                        MailView(mailbox: self.mailbox, result: self.$result)
                    }
                }
                Button(action: {
                    let tel = "mailto:"
                    let formattedString = tel + self.mailbox.email!
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("\(mailbox.email ?? "")")
                }
            }
            Divider()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("packages").font(.subheadline).fontWeight(.light)
                    Text("(\(numOfUnarchived(from: mailbox)))").font(.subheadline).fontWeight(.heavy)
                    Spacer()
                    NavigationLink(
                        destination: ArchiveView(recipient: mailbox).environment(\.managedObjectContext, viewContext)
                    ) {
                        HStack {
                            Text("View Archive")
                            Image(systemName: "archivebox")
                        }
                    }
                }
                EditCheckoutView(recipient: mailbox, packageType: .unarchived)
            }
        }.padding(15)
            .navigationBarTitle("\(mailbox.firstName!) \(mailbox.lastName!)")
            .navigationBarItems(
                trailing: Button(
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
        )
    }
}

struct MailboxDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = initMailbox(in: context)
        return NavigationView {
            MailboxDetailView(mailbox: mailbox).environment(\.managedObjectContext, context)
        }
    }
}
