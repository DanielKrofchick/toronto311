//
//  UIImage.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-26.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = .one) {
        UIGraphicsBeginImageContext(size)
        color.setFill()
        UIBezierPath(rect: CGRect(origin: .zero, size: size)).fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}
