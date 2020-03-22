//
//  ContentView.swift
//  terpscan
//
//  Created by Justin Le on 3/17/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CodeScanner

public let primaryColor = Color(#colorLiteral(red: 0.8884014487, green: 0.1081022099, blue: 0.1330436766, alpha: 1))

public let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State private var showingAddMailbox = false
    
    var body: some View {
        // FIXME: Workaround to force DoubleColumns in portrait mode for iPad
        GeometryReader { geo in
            NavigationView {
                VStack {
                    MailboxesView()
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
                }
            }.navigationViewStyle(DoubleColumnNavigationViewStyle())
                .accentColor(primaryColor)
                .padding(.leading, geo.size.height > geo.size.width ? 1 : 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
