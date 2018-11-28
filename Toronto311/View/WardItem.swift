//
//  WardItem.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-26.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import MapKit

class WardItem {
    let ward: Ward
    var isSelected: Bool = false
    var overlay: MKOverlay?
    
    init(ward: Ward) {
        self.ward = ward
    }
    
    func overlayRenderer() -> MKOverlayRenderer {
        var result: MKOverlayRenderer?
        
        if let overlay = overlay as? MKPolyline {
            result = polyLineRenderer(overlay)
        } else if let overlay = overlay as? MKPolygon {
            result = polygonRenderer(overlay)
        }
        
        return result ?? MKOverlayRenderer()
    }
    
    func polyLineRenderer(_ overlay: MKPolyline) -> MKOverlayRenderer {
        let r = MKPolylineRenderer(polyline: overlay)
        
        r.lineWidth = 1.5
        
        switch ward.wardSource {
        case .icitw_wgs84:
            r.strokeColor = isSelected ? .red : .blue
        case .WARD_WGS84:
            r.strokeColor = isSelected ? .brown : .orange
        }
        
        return r
    }
    
    func polygonRenderer(_ overlay: MKPolygon) -> MKOverlayRenderer {
        let r = MKPolygonRenderer(polygon: overlay)
        
        r.lineWidth = 1.5
        
        switch ward.wardSource {
        case .icitw_wgs84:
            r.strokeColor = .red
            r.fillColor = isSelected ? UIColor.red.withAlphaComponent(0.2) : UIColor.clear
        case .WARD_WGS84:
            r.strokeColor = .brown
            r.fillColor = isSelected ? UIColor.brown.withAlphaComponent(0.2) : UIColor.clear
        }
        
        return r
    }
    
    func annotationView(_ mapView: MKMapView) -> MKAnnotationView? {
        let identifier = "Annotation"
        let annotation = ward
        
        let view =
            mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ??
                MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
        if let view = view as? MKPinAnnotationView {
            view.canShowCallout = true
            view.annotation = annotation
            
            if let request = annotation as Any as? ServiceRequest {
                view.pinTintColor = request.service_code?.color()
            }
        }
        
        return view
    }
}

extension WardItem: Equatable {
    static func == (lhs: WardItem, rhs: WardItem) -> Bool {
        return lhs.ward == rhs.ward
    }
}

extension WardItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ward)
    }
}
