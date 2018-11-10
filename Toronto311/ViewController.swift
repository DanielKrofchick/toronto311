//
//  ViewController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit
import GEOSwift

class ViewController: UIViewController {
    let info = UIView()
    let map = MKMapView()
    var mapTap = UITapGestureRecognizer()

    private let centerOffset: CLLocationDegrees = 0.08
    private let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        info.backgroundColor = UIColor.red
        
        map.frame = view.bounds
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = self
        view.addSubview(map)
        
        mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        map.addGestureRecognizer(mapTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centerMapOnLocation(location: .toronto)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        info.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        info.center = view.center
    }
    
    func centerMapOnLocation(location: CLLocation) {
        var center = location.coordinate
        center.latitude += centerOffset
        
        let coordinateRegion = MKCoordinateRegion(center: center,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController {
    func loadData() {
        guard let dataController = (UIApplication.shared.delegate as? AppDelegate)?.dataController else {return}
        
        DataImporter.procesGeo { feature, geometry in
            if
                let overlay = geometry.boundary()?.mapShape() as? MKPolyline,
                let w: Ward? = (feature.properties as? [String: Any])?.decodeDecodable(userInfo: [.context: dataController.context]),
                let ward = w
            {
                dataController.save()
                let gotWards = dataController.read(areaID: ward.areaID)
                DispatchQueue.main.async {
//                    self.map.addOverlay(overlay.wardPolyline(ward))
                    self.map.addOverlay(overlay.polygon().wardPolygon(ward))
                    self.map.addAnnotation(ward)
                }
            }
        }
//        DataImporter.processFirestations {print($0)}
//        DataImporter.processServiceRequests(.disk) {self.map.addAnnotation($0)}
//        DataImporter.processServiceList(.disk) {print($0)}
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer: MKOverlayRenderer?
        
        if let overlay = overlay as? MKPolyline {
            let r = MKPolylineRenderer(polyline: overlay)
            r.strokeColor = .blue
            r.lineWidth = 1.5

            if let overlay = overlay as? WardPolyline {
                r.strokeColor = overlay.isSelected ? .red : .blue
            }

            renderer = r
        } else if let overlay = overlay as? MKPolygon {
            let r = MKPolygonRenderer(polygon: overlay)
            r.strokeColor = .green
            r.lineWidth = 1.5
            r.fillColor = UIColor.yellow.withAlphaComponent(0.1)
            
            if let overlay = overlay as? WardPolygon {
                r.fillColor = overlay.isSelected ? UIColor.blue.withAlphaComponent(0.1) : UIColor.yellow.withAlphaComponent(0.1)
            }
            
            renderer = r
        }
        
        return renderer ?? MKOverlayRenderer()
    }
}

extension ViewController {
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        inside(tap)
        nearest(tap)
    }

    private func inside(_ tap: UITapGestureRecognizer) {
        if
            tap.state == .recognized,
            let polygon = map.polygon(for: tap.location(in: map)) as? WardPolygon,
            let ward = polygon.ward
        {
            print(ward)
            select(polygon)
            info(selected()?.ward)
        }
    }

    private func nearest(_ tap: UITapGestureRecognizer) {
        if
            tap.state == .recognized,
            let polyline = map.polyline(for: tap.location(in: map)) as? WardPolyline,
            let ward = polyline.ward
        {
            print("Polyline: \(ward.areaName)")
            polyline.isSelected.toggle()
            map.removeOverlay(polyline)
            map.addOverlay(polyline)
        }
    }
    
    private func select(_ polygon: MKPolygon) {
        map.overlays.forEach { overlay in
            guard let overlay = overlay as? WardPolygon else {return}
            let v = overlay == polygon
            if v {
                overlay.isSelected.toggle()
                map.removeOverlay(overlay)
                map.addOverlay(overlay)
            } else if overlay.isSelected != v {
                overlay.isSelected = v
                map.removeOverlay(overlay)
                map.addOverlay(overlay)
            }
        }
    }
    
    private func selected() -> WardPolygon? {
        return map.overlays.first { (overlay) -> Bool in
            return (overlay as? WardPolygon)?.isSelected ?? false
        } as? WardPolygon
    }
    
    private func info(_ ward: Ward?) {
//        if let ward = ward {
//            view.addSubview(info)
//            view.setNeedsLayout()
//        } else {
//            info.removeFromSuperview()
//        }
    }
}
