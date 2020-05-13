//
//  CheckOutView.swift
//  terpscan
//
//  Created by Justin Le on 5/8/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct CheckOutView: View {
    @Binding var isPresented: Bool
    @Binding var packages: Set<Package>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(Array(packages), id: \.self) { package in
                    NavigationLink(
                        destination: PackageDetailView(package: package)
                    ) {
                        PackageCellView(package: package)
                    }
                }
            }
            .padding(.all)
            .navigationBarTitle("Check Out \(packages.count) Package(s)", displayMode: .inline)
            .navigationBarItems(
                leading: Button(
                    action: {
                        self.isPresented = false
                }) {
                    Text("Cancel")
                },
                trailing:
                
                NavigationLink(
                    destination: SignView(isPresented: $isPresented, packages: $packages)
                ) {
                    Text("Sign")
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = initMailbox(in: context)
        var packages = Set<Package>()
        for _ in 1...3 {
            let package = initPackage(in: context, for: mailbox)
            packages.insert(package)
        }
        return CheckOutView(isPresented: .constant(true), packages: .constant(packages)).environment(\.managedObjectContext, context)
    }
}
