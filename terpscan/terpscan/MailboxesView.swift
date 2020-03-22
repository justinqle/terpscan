//
//  MailboxesView.swift
//  terpscan
//
//  Created by Justin Le on 3/19/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct MailboxesView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mailbox.lastName, ascending: true)],
        animation: .default)
    var mailboxes: FetchedResults<Mailbox>
    
    @Environment(\.managedObjectContext)
    var viewContext
    
    // Group Mailboxes by first letter of last name
    private func groupby(_ result : FetchedResults<Mailbox>) -> [[Mailbox]] {
        return Dictionary(grouping: result) { (element : Mailbox) in
            element.lastName!.first!
        }.values.map{$0}.sorted(by: { c1, c2 in return c1[0].lastName! < c2[0].lastName! })
    }
    
    var body: some View {
        List {
            NavigationLink(
                destination: PackagesView(recipient: nil)
                    .navigationBarTitle(Text("All Inboxes"), displayMode: .large)
                    .navigationBarItems(
                        trailing: EditButton()
                )
            ) {
                HStack {
                    Image(systemName: "cube.box").imageScale(.large)
                    Text("All Inboxes").fontWeight(.bold)
                }
            }
            NavigationLink(
                destination: PackagesView(recipient: nil)
                    .navigationBarTitle(Text("Archive"), displayMode: .large)
            ) {
                HStack {
                    Image(systemName: "archivebox").imageScale(.large)
                    Text("Archive").fontWeight(.bold)
                }
            }
            ForEach(groupby(mailboxes), id: \.self) { (group: [Mailbox]) in
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
            }.id(mailboxes.count)
        }
    }
}

struct MailboxesView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return MailboxesView().environment(\.managedObjectContext, context)
    }
}
