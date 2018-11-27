//
//  WardViewModel.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-11.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

class WardViewModel {
    var items = [WardItem]()
    
    func numberOfRows(inSection section: Int) -> Int {
        return items.count
    }
    
    func configure(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        
        guard let item = items[safe: indexPath.row] else {return}
        
        cell.textLabel?.text = item.ward.areaName
    }
    
    func configureFilter(_ button: UIButton = UIButton(type: .custom), wardSource: WardSource) -> UIButton {
        button.setTitle(wardSource.name(), for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.blue.cgColor
        button.setBackgroundImage(UIImage(color: UIColor.blue.withAlphaComponent(0.3)), for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor.blue.withAlphaComponent(0.3)), for: [.highlighted])
        button.setBackgroundImage(UIImage(color: .blue), for: [.selected])
        button.setBackgroundImage(UIImage(color: .blue), for: [.selected, .highlighted])
        
        return button
    }
    
    func item(for indexPath: IndexPath) -> WardItem? {
        return items[safe: indexPath.row]
    }

    func item(for ward: Ward) -> WardItem? {
        return items.first{$0.ward == ward}
    }

    func item(for overlay: MKOverlay) -> WardItem? {
        return items.first { (item) -> Bool in
            var result = false
            
            if
                let o = item.overlay as? MKShape,
                let overlay = overlay as? MKShape
            {
                result = overlay == o
            }
            
            return result
        }
    }
    
    func indexPath(for item: WardItem) -> IndexPath? {
        var result: IndexPath?
        
        if let row = items.firstIndex(of: item) {
            result = IndexPath(row: row, section: 0)
        }
        
        return result
    }
}
