//
//  SignView.swift
//  terpscan
//
//  Created by Justin Le on 5/9/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import PencilKit

struct SignView: View {
    @Environment(\.managedObjectContext)
    var viewContext
    @Binding
    var isPresented: Bool
    @Binding
    var packages: Set<Package>
    @State
    private var canvasView = PKCanvasView()
    @State
    var signer: String = ""
    
    var body: some View {
        VStack(spacing: 25) {
            TextField("Signer", text: $signer).padding(.all).background(Color(UIColor.secondarySystemBackground))
            SignatureView(canvasView: $canvasView).frame(height: 200).border(Color(UIColor.secondarySystemBackground), width: 5)
            Button("Clear") {
                self.canvasView.drawing = PKDrawing()
            }
        }
        .padding(.all)
        .navigationBarItems(
            trailing: Button(
                action: {
                    self.isPresented = false
                    let imgRect = CGRect(x: 0, y: 0, width: self.canvasView.frame.width, height: self.canvasView.frame.height)
                    let image = self.canvasView.drawing.image(from: imgRect, scale: 1.0)
                    Receipt.create(in: self.viewContext, signer: self.signer, signature: image, packages: self.packages)
            }) {
                Text("Finish")
            }
        )
    }
}

struct SignatureView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        self.canvasView.backgroundColor = UIColor.white
        self.canvasView.tool = PKInkingTool(.pen, color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), width: 10)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}

struct SignView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SignView(isPresented: .constant(true), packages: .constant(Set<Package>()))
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
