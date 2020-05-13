//
//  TestData.swift
//  terpscan
//
//  Created by Justin Le on 5/9/20.
//  Copyright © 2020 Justin Le. All rights reserved.
//

import CoreData
import PencilKit

public func initMailbox(in context: NSManagedObjectContext) -> Mailbox {
    let mailbox = Mailbox.init(context: context)
    mailbox.firstName = "Justin"
    mailbox.lastName = "Le"
    mailbox.email = "justinqle@gmail.com"
    mailbox.phoneNumber = "2404472771"
    mailbox.buildingCode = "IRB"
    mailbox.roomNumber = "5109"
    return mailbox
}

public func initPackage(in context: NSManagedObjectContext, for mailbox: Mailbox) -> Package {
    let package = Package.init(context: context)
    package.recipient = mailbox
    package.trackingNumber = "1Z12345E1512345676"
    package.carrier = "UPS"
    package.timestamp = Date()
    return package
}

extension UIImage {
    static func imageWithSize(size: CGSize, color: UIColor = UIColor.white) -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.addRect(CGRect(origin: CGPoint.zero, size: size));
            context.drawPath(using: .fill)
            image = UIGraphicsGetImageFromCurrentImageContext();
        }
        UIGraphicsEndImageContext()
        return image
    }
}

public func initReceipt(in context: NSManagedObjectContext, for packages: [Package]) -> Receipt {
    let receipt = Receipt.init(context: context)
    receipt.signer = "Regis Boykin"
    receipt.signature = UIImage.imageWithSize(size: CGSize(width: 400, height: 200))?.jpegData(compressionQuality: 1.0)
    receipt.timestamp = Date()
    receipt.packages = NSSet.init(array: packages)
    return receipt
}
