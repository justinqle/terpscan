//
//  ContentView.swift
//  terpscan
//
//  Created by Justin Le on 3/17/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CodeScanner

public let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State var showingAddPackage = false
    @State var showingAddContact = false
    
    var body: some View {
        TabView {
            NavigationView {
                MasterView()
                    // FIXME: Workaround to add-cancel-add modal bug
                    //.navigationBarTitle(Text("Packages"), displayMode: .inline)
                    .navigationBarTitle(Text("Packages"), displayMode: .large)
                    .navigationBarItems(
                        leading: EditButton(),
                        trailing: Button(
                            action: {
                                self.showingAddPackage.toggle()
                        }) {
                            HStack {
                                Text("New Package")
                                Image(systemName: "plus")
                            }
                        }.sheet(isPresented: $showingAddPackage) {
                            // FIXME: Workaround to package adding in modal with managedObjectContext
                            AddPackageView(isPresented: self.$showingAddPackage).environment(\.managedObjectContext, self.viewContext)
                        }
                )
                Text("Detail view content goes here")
                    .navigationBarTitle(Text("Detail"))
            }.navigationViewStyle(StackNavigationViewStyle()) // FIXME: Compatability with iPads
                .tabItem {
                    Image(systemName: "cube.box.fill")
                    Text("Packages")
            }
            NavigationView {
                ContactsView()
                    // FIXME: Workaround to add-cancel-add modal bug
                    //.navigationBarTitle(Text("Contacts"), displayMode: .inline)
                    .navigationBarTitle(Text("Contacts"), displayMode: .large)
                    .navigationBarItems(
                        leading: EditButton(),
                        trailing: Button(
                            action: {
                                self.showingAddContact.toggle()
                        }) {
                            HStack {
                                Text("New Contact")
                                Image(systemName: "plus")
                            }
                        }.sheet(isPresented: $showingAddContact) {
                            // FIXME: Workaround to package adding in modal with managedObjectContext
                            AddContactView(isPresented: self.$showingAddContact).environment(\.managedObjectContext, self.viewContext)
                        }
                )
                Text("Detail view content goes here")
                    .navigationBarTitle(Text("Detail"))
            }.navigationViewStyle(StackNavigationViewStyle()) // FIXME: Compatability with iPads
                .tabItem {
                    Image(systemName: "person.crop.circle.fill")
                    Text("Contacts")
            }
        }
    }
}

struct MasterView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Package.timestamp, ascending: false)],
        animation: .default)
    var packages: FetchedResults<Package>
    
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State var selectKeeper = Set<Package>()
    
    var body: some View {
        List(selection: $selectKeeper) {
            ForEach(packages, id: \.self) { package in
                NavigationLink(
                    destination: DetailView(package: package)
                ) {
                    VStack(alignment: .leading) {
                        Text("Justin Le").font(.headline)
                        HStack {
                            Text("TRK#:").font(.caption)
                            Text("\(package.trackingNumber!)")
                        }
                        HStack {
                            Text("Received:").font(.caption)
                            Text("\(package.timestamp!, formatter: dateFormatter)")
                        }
                    }
                }
            }.onDelete { indices in
                self.packages.deletePackage(at: indices, from: self.viewContext)
            }
        }
    }
}

struct DetailView: View {
    @ObservedObject var package: Package
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("recipient").font(.subheadline)
                Text("\(package.recipient!.firstName!) \(package.recipient!.lastName!)")
                Divider()
                Text("tracking number").font(.subheadline)
                Text("\(package.trackingNumber!)")
                Divider()
                
            }
            Text("Added \(package.timestamp!, formatter: dateFormatter)").font(.footnote)
            Spacer()
        }.padding(15)
            .navigationBarTitle("\(package.trackingNumber!)")
            .navigationBarItems(
                trailing: EditButton()
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
