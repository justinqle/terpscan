//
//  CheckOutView.swift
//  terpscan
//
//  Created by Justin Le on 5/8/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct CheckOutView: View {
    @Binding
    var isPresented: Bool
    
    var disableDone: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Text("PLACEHOLDER")
            }.navigationBarTitle("Check Out", displayMode: .inline)
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
                            // action
                    }) {
                        Text("Done")
                    }.disabled(disableDone)
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutView(isPresented: .constant(true))
    }
}
