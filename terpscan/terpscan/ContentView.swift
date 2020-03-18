//
//  ContentView.swift
//  terpscan
//
//  Created by Justin Le on 3/17/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CodeScanner

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State var showingAddPackage = false
    
    var body: some View {
        NavigationView {
            MasterView()
                // FIXME: Workaround to add-cancel-add modal bug
                .navigationBarTitle(Text("Packages"), displayMode: .inline)
                //.navigationBarTitle(Text("Packages"), displayMode: .large)
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button(
                        action: {
                            self.showingAddPackage.toggle()
                            //withAnimation { Event.create(in: self.viewContext) }
                    }) {
                        Image(systemName: "plus")
                    }.sheet(isPresented: $showingAddPackage) {
                        // FIXME: Workaround to package adding in modal with managedObjectContext
                        AddPackageView(isPresented: self.$showingAddPackage).environment(\.managedObjectContext, self.viewContext)
                    }
            )
            Text("Detail view content goes here")
                .navigationBarTitle(Text("Detail"))
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct AddPackageView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isPresented: Bool
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var trackingNumber: String = ""
    @State var isShowingScanner = false
    @State var selectedCarrier = 0
    
    var carriers = ["UPS", "FedEx", "USPS", "Amazon", "DHL", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }
                Section {
                    HStack {
                        TextField("Tracking number", text: $trackingNumber)
                        Button(
                            action: {
                                self.isShowingScanner = true
                        }) {
                            Image(systemName: "barcode.viewfinder")
                        }.sheet(isPresented: $isShowingScanner) {
                            CodeScannerView(codeTypes: [.code128], simulatedData: "-1", completion: self.handleScan)
                        }
                    }
                    Picker(selection: $selectedCarrier, label: Text("Carrier")) {
                        ForEach(0 ..< carriers.count) {
                            Text(self.carriers[$0])
                        }
                    }
                }
            }.navigationBarTitle("New Package", displayMode: .inline)
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
                            withAnimation { Event.create(in: self.viewContext) }
                    }) {
                        Text("Done")
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(let code):
            self.trackingNumber = code
        case .failure(let error):
            print("Scanning failed")
        }
    }
}

struct MasterView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Event.timestamp, ascending: true)], 
        animation: .default)
    var events: FetchedResults<Event>
    
    @Environment(\.managedObjectContext)
    var viewContext
    
    @State var selectKeeper = Set<Event>()
    
    var body: some View {
        List(selection: $selectKeeper) {
            ForEach(events, id: \.self) { event in
                NavigationLink(
                    destination: DetailView(event: event)
                ) {
                    Text("\(event.timestamp!, formatter: dateFormatter)")
                }
            }.onDelete { indices in
                self.events.delete(at: indices, from: self.viewContext)
            }
        }
    }
}

struct DetailView: View {
    @ObservedObject var event: Event
    
    var body: some View {
        Text("\(event.timestamp!, formatter: dateFormatter)")
            .navigationBarTitle(Text("Detail"))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
