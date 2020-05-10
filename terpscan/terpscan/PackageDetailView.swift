//
//  PackageDetailView.swift
//  terpscan
//
//  Created by Justin Le on 3/21/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct PackageDetailView: View {
    @ObservedObject var package: Package
    
    private var showReceipt: Bool {
        if let _ = package.receipt {
            return true
        } else {
            return false
        }
    }
    
    public let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("recipient").font(.subheadline).fontWeight(.light)
                    Text("\(package.recipient!.firstName!) \(package.recipient!.lastName!)").fontWeight(.bold)
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text("tracking number").font(.subheadline).fontWeight(.light)
                    Text("\(package.trackingNumber!)").foregroundColor(primaryColor).onTapGesture {
                        let url = URL.init(string: "https://www.google.com/search?q=\(self.package.trackingNumber!)")
                        guard let searchURL = url, UIApplication.shared.canOpenURL(searchURL) else { return }
                        UIApplication.shared.open(searchURL)
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    Text("carrier").font(.subheadline).fontWeight(.light)
                    Text("\(package.carrier!)")
                }
                Divider()
            }
            if showReceipt {
                Image(uiImage: UIImage(data: (package.receipt?.signature!)!, scale: 1.0)!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .border(Color(UIColor.secondarySystemBackground), width: 5)
                Text("Checked out by \(package.receipt!.signer!) on \(package.receipt!.timestamp!, formatter: dateFormatter)").font(.footnote)
            }
            Text("Received on \(package.timestamp!, formatter: dateFormatter)").font(.footnote)
            Spacer()
        }
        .padding(15)
        .navigationBarTitle("# \(package.trackingNumber!)")
    }
}

struct PackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let mailbox = initMailbox(in: context)
        let package = initPackage(in: context, for: mailbox)
        let _ = initReceipt(in: context, for: [package])
        return NavigationView {
            PackageDetailView(package: package).environment(\.managedObjectContext, context)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
