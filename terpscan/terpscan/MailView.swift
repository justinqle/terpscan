//
//  MailView.swift
//  terpscan
//
//  Created by Justin Le on 5/7/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    
    @ObservedObject var mailbox: Mailbox
    
    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        
        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        // Message customization
        vc.setToRecipients([mailbox.email!])
        vc.setSubject("\(mailbox.packages!.count) package(s) ready for pickup")
        
        let body = """
        <p>Hi \(mailbox.firstName!) \(mailbox.lastName!),</p>
        <p>You have \(mailbox.packages!.count) package(s) ready for pickup in the Iribe Center Mailroom (IRB room 5109). Please come and pick it up at your earliest convenience.</p>
        <p><b>University of Maryland Department of Computer Science</b><br/>
        Paint Branch Dr. | Iribe Center Mailroom (IRB) Room 5109 | College Park MD | 20742<br/>
        Ext: 50425<br/>
        Hours of Operation<br/>
        M-F 8:30 AM - 5:00 PM<br/>
        Mailroomstaff@cs.umd.edu</p>
        """
        
        // \((mailbox.packages!.allObjects as! [Package]).map{$0.trackingNumber!}.joined(separator: "\n"))
        
        vc.setMessageBody(body, isHTML: true)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
        
    }
}
