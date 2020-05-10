//
//  MailboxesView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

public let primaryColor = Color(#colorLiteral(red: 0.8884014487, green: 0.1081022099, blue: 0.1330436766, alpha: 1))

struct MailboxesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mailbox.lastName, ascending: true)],
        animation: .default)
    var mailboxes: FetchedResults<Mailbox>
    
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State private var showingAddMailbox = false
    
    // Group Mailboxes by first letter of last name
    private func groupby(_ result : FetchedResults<Mailbox>) -> [[Mailbox]] {
        return Dictionary(grouping: result) { (element : Mailbox) in
            element.lastName!.first!
        }.values.map{$0}.sorted(by: { c1, c2 in return c1[0].lastName! < c2[0].lastName! })
    }
    
    var body: some View {
        // FIXME: Workaround to force DoubleColumns in portrait mode for iPad
        GeometryReader { geo in
            NavigationView {
                List {
                    NavigationLink(
                        destination: AllInboxesView()
                    ) {
                        HStack {
                            Image(systemName: "cube.box").imageScale(.large)
                            Text("All Inboxes").fontWeight(.bold)
                        }
                    }
                    NavigationLink(
                        destination: ArchiveView(recipient: nil)
                    ) {
                        HStack {
                            Image(systemName: "archivebox").imageScale(.large)
                            Text("Archive").fontWeight(.bold)
                        }
                    }
                    ForEach(self.groupby(self.mailboxes), id: \.self) { (group: [Mailbox]) in
                        Section(header: Text(String(group[0].lastName!.first!))) {
                            ForEach(group, id: \.self) { mailbox in
                                NavigationLink(
                                    destination: MailboxDetailView(mailbox: mailbox)
                                ) {
                                    HStack(spacing: 4) {
                                        Text("\(mailbox.firstName!)")
                                        Text("\(mailbox.lastName!)").fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }.id(self.mailboxes.count)
                }
                    // FIXME: Workaround to add-cancel-add modal bug
                    //.navigationBarTitle(Text("Mailboxes"), displayMode: .inline)
                    .navigationBarTitle(Text("Mailboxes"), displayMode: .large)
                    .navigationBarItems(
                        trailing: Button(
                            action: {
                                self.showingAddMailbox.toggle()
                        }) {
                            HStack {
                                Text("New Mailbox")
                                Image(systemName: "plus")
                            }
                        }.sheet(isPresented: self.$showingAddMailbox) {
                            AddMailboxView(isPresented: self.$showingAddMailbox)
                                // FIXME: Workaround to package adding in modal with managedObjectContext
                                .environment(\.managedObjectContext, self.viewContext)
                                .accentColor(primaryColor)
                        }
                )
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
                .accentColor(primaryColor)
                .padding(.leading, geo.size.height > geo.size.width ? 1 : 0)
        }
    }
}

struct MailboxesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return MailboxesView().environment(\.managedObjectContext, context)
    }
}
