//
//  AddPackageView.swift
//  terpscan
//
//  Created by Justin Le on 3/18/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import CodeScanner

extension String {
    // Allows substringing through two indices (inclusive:exclusive)
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex..<endIndex])
    }
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

struct AddPackageView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Mailbox.lastName, ascending: true)],
        animation: .default)
    var mailboxes: FetchedResults<Mailbox>
    
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var isPresented: Bool
    
    @State var selectedRecipient: Mailbox?
    @State var trackingNumber: String = ""
    @State var isShowingScanner = false
    @State var selectedCarrier = 0
    
    var carriers = ["UPS", "FedEx", "USPS", "Amazon", "DHL", "Other"]
    
    var disableDone: Bool {
        selectedRecipient == nil || trackingNumber.isEmpty
    }
    
    init(isPresented: Binding<Bool>, recipient: Mailbox?) {
        _isPresented = isPresented
        _selectedRecipient = State.init(initialValue: recipient)
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedRecipient, label: Text("Recipient")) {
                        ForEach(mailboxes, id: \.self) { mailbox in
                            HStack(spacing: 4) {
                                Text("\(mailbox.firstName!)")
                                Text("\(mailbox.lastName!)").fontWeight(.bold)
                            }.tag(mailbox as Mailbox?)
                        }
                    }
                }
                Section {
                    HStack {
                        TextField("Tracking number", text: $trackingNumber)
                        Spacer()
                        Button(
                            action: {
                                self.isShowingScanner = true
                        }) {
                            Image(systemName: "barcode.viewfinder").imageScale(.large)
                        }.sheet(isPresented: $isShowingScanner) {
                            CodeScannerView(codeTypes: [.code128], simulatedData: "1Z12345E1512345676", completion: self.handleScan)
                        }
                    }
                    Picker(selection: $selectedCarrier, label: Text("Carrier")) {
                        ForEach(0 ..< carriers.count, id: \.self) {
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
                            withAnimation { Package.create(in: self.viewContext,
                                                           for: self.selectedRecipient!,
                                                           trackingNumber: self.trackingNumber,
                                                           carrier: self.carriers[self.selectedCarrier]) }
                    }) {
                        Text("Done")
                    }.disabled(disableDone)
            )
        }.navigationViewStyle(StackNavigationViewStyle())
            .accentColor(ACCENT_COLOR)
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(var code): // Possible carriers: UPS, FedEx, USPS, Amazon, DHL, Other
            code = code.filter { String($0).isAlphanumeric } // Filter out weird chars
            // Parse barcode for tracking number if necessary
            if (code.hasPrefix("420")) { // UPS
                self.trackingNumber = code.subString(from: 8, to: code.count)
            } else if (code.count == 34) { // FedEx
                self.trackingNumber = code.subString(from: 22, to: code.count)
                selectedCarrier = 1
                return
            } else { // Other
                self.trackingNumber = code
            }
            // Set carrier picker
            if self.trackingNumber.hasPrefix("1Z") { // UPS
                selectedCarrier = 0
            } else if self.trackingNumber.hasPrefix("9") { // USPS
                selectedCarrier = 2
            } else if self.trackingNumber.hasPrefix("TBA") { // Amazon
                selectedCarrier = 3
            } else { // Other
                selectedCarrier = 5
            }
        case .failure(let error):
            print("Scanning failed with \(error)")
        }
    }
}

struct AddPackageView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = initMailbox(in: context)
        return AddPackageView(isPresented: .constant(true), recipient: mailbox).environment(\.managedObjectContext, context)
    }
}
