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
    // Allows substringing through two indices
    func subString(from: Int, to: Int) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: from)
        let endIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[startIndex...endIndex])
    }
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
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
    @State var selectedSize = 0
    @State var notes: String = ""
    
    var carriers = ["UPS", "FedEx", "USPS", "Amazon", "DHL", "Other"]
    var sizes = ["Small", "Medium", "Large"]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(
                        action: {
                            
                    }) {
                        HStack {
                            Text("Recipient")
                            Spacer()
                            Image(systemName: "person.crop.circle")
                        }
                    }
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
                        ForEach(0 ..< carriers.count, id: \.self) {
                            Text(self.carriers[$0])
                        }
                    }
                }
                Section {
                    Picker(selection: $selectedSize, label: Text("Size")) {
                        ForEach(0 ..< sizes.count, id: \.self) {
                            Text(self.sizes[$0])
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    TextField("Notes", text: $notes)
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
                            withAnimation { Package.create(in: self.viewContext, trackingNumber: self.trackingNumber) }
                    }) {
                        Text("Done")
                    }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
        switch result {
        case .success(var code):
            print(code)
            // Further parse barcode if needed
            code = code.filter { String($0).isAlphanumeric }
            if (code.hasPrefix("0102")) { // FedEx PDF417 barcode
                self.trackingNumber = code.subString(from: 14, to: 26)
            } else if code.hasPrefix("96")  { // Also FedEx
                self.trackingNumber = code.subString(from: code.count-12, to: code.count-1)
            } else if (code.hasPrefix("420") && code.count > 8) { // USPS
                self.trackingNumber = code.subString(from: 8, to: code.count-1)
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
            } else {
                selectedCarrier = 5
            }
        case .failure(let error):
            print("Scanning failed with \(error)")
        }
    }
}

struct AddPackageView_Previews: PreviewProvider {
    static var previews: some View {
        AddPackageView(isPresented: .constant(true))
    }
}
