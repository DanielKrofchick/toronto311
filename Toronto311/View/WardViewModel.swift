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
    var items = [WardItem]() {
        willSet {
            cache.subtract(items)
            cache.formUnion(items)
        }
        didSet {
            items.forEach { (item) in
                if let old = cache.first(where: {$0.ward.areaID == item.ward.areaID}) {
                    item.isSelected = old.isSelected
                }
            }
        }
    }
    
    private var cache = Set<WardItem>()
    
    func numberOfRows(inSection section: Int) -> Int {
        return items.count
    }
    
    func configure(cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
        cell.selectionStyle = .blue
        cell.selectedBackgroundView = UIView(frame: cell.bounds)
        cell.selectedBackgroundView?.backgroundColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 0.4)
        
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
    
    func configureOverlays(map: MKMapView) {
        map.removeAnnotations(map.annotations)
        map.removeOverlays(map.overlays)
        items.forEach({
            [map = map] in
            if var overlay = $0.ward.shape() as? MKOverlay {
                if let o = overlay as? MKPolygon {
                    overlay = o.polyline()
                }
                
                $0.overlay = overlay
                addOverlays(item: $0, map: map)
            }
        })
    }
    
    func addOverlays(item: WardItem, map: MKMapView) {
        guard let overlay = item.overlay else {return}
        
        map.removeOverlay(overlay)
        if item.isSelected {
            map.addOverlay(overlay)
            map.addAnnotation(item.ward)
        } else {
            map.insertOverlay(overlay, at: 0)
            map.removeAnnotation(item.ward)
        }
    }
    
    func configureSelectedCells(tableView: UITableView) {
        items.forEach { (item) in
            if
                item.isSelected,
                let indexPath = indexPath(for: item)
            {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }
    
    func item(for indexPath: IndexPath) -> WardItem? {
        return items[safe: indexPath.row]
    }

    func item(for ward: Ward) -> WardItem? {
        return items.first{$0.ward.areaID == ward.areaID}
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
    
    func selectedItems() -> [WardItem] {
        return items.filter({$0.isSelected})
    }
}
