//
//  UIView.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-17.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

extension UIView {
    func pin(to view: UIView? = nil, with insets: UIEdgeInsets = .zero, edges: UIRectEdge = .all) {
        guard let view = view ?? superview else {return}
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if edges.contains(.top) {
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top).isActive = true
        }
        if edges.contains(.bottom) {
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom).isActive = true
        }
        if edges.contains(.left) {
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left).isActive = true
        }
        if edges.contains(.right) {
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right).isActive = true
        }
    }
}
