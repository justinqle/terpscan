//
//  AddContactView.swift
//  terpscan
//
//  Created by Justin Le on 3/18/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI

struct AddContactView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("Add Contact page")
    }
}

struct AddContactView_Previews: PreviewProvider {
    static var previews: some View {
        AddContactView(isPresented: .constant(true))
    }
}
