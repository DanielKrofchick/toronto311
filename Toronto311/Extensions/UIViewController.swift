//
//  UIViewController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-17.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

extension UIViewController {
    func addAndConfigureChild(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
