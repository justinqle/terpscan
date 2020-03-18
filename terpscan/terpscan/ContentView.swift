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
                            CodeScannerView(codeTypes: [.code128, .pdf417], simulatedData: "-1", completion: self.handleScan)
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
            print(code)
            // Further parse barcode if needed
            if (code.hasPrefix("[)>")) { // FedEx PDF417 barcode
                self.trackingNumber = (code.filter { !$0.isNewline && !$0.isWhitespace }).subString(from: 22, to: 34)
            } else if code.hasPrefix("96")  { // Also FedEx
                self.trackingNumber = code.subString(from: code.count-12, to: code.count-1)
            } else {
                self.trackingNumber = code
            }
            // Set carrier picker
            if self.trackingNumber.hasPrefix("1Z") { // UPS
                selectedCarrier = 0
            } else if self.trackingNumber.hasPrefix("7") { // FedEx
                selectedCarrier = 1
            } else if self.trackingNumber.hasPrefix("9") { // USPS
                selectedCarrier = 2
            } else if self.trackingNumber.hasPrefix("FBA") { // Amazon
                selectedCarrier = 3
            }
        case .failure(let error):
            print("Scanning failed with \(error)")
        }
    }
}

extension String {
    // Allows substringing through two indices
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex...endIndex])
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
