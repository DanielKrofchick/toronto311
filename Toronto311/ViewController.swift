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
    let map = MKMapView()
    var mapTap = UITapGestureRecognizer()

    private let centerOffset: CLLocationDegrees = 0.08
    private let regionRadius: CLLocationDistance = 20000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        DataImporter.procesGeo { feature, geometry in
            var ward: Ward?
            
            if let dic = feature.properties {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                    let string = String(data: jsonData, encoding: String.Encoding.utf8)
                    if let data = string?.data(using: String.Encoding.utf8) {
                        ward = try JSONDecoder().decode(Ward.self, from: data)
                    }
                } catch {
                    print(error)
                }
            }
            
            print(ward ?? "")
            
            if let overlay = geometry.boundary()?.mapShape() as? MKOverlay {
                if
                    let overlay = overlay as? MKPolyline,
                    let ward = ward
                {
                    self.map.addOverlay(overlay.toWardPolygon(ward))
                } else {
                    self.map.addOverlay(overlay)
                }
            }
        }
//        DataImporter.processFirestations {print($0)}
//        DataImporter.processServiceRequests(.disk) {self.map.addAnnotation($0)}
//        DataImporter.processServiceList(.disk) {print($0)}
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

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        return point(mapView, viewFor: annotation)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer: MKOverlayRenderer?
        
        if let overlay = overlay as? MKPolyline {
            let r = MKPolylineRenderer(polyline: overlay)
            r.strokeColor = .blue
            r.lineWidth = 1
            renderer = r
        } else if let overlay = overlay as? MKPolygon {
            let r = MKPolygonRenderer(polygon: overlay)
            r.strokeColor = .blue
            r.lineWidth = 1.5
            r.fillColor = UIColor.yellow.withAlphaComponent(0.1)
            renderer = r
        }
        
        return renderer ?? MKOverlayRenderer()
    }
    
    func point(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
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
}

// https://stackoverflow.com/questions/11713788/how-to-detect-taps-on-mkpolylines-overlays-like-maps-app
extension ViewController {
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        inside(tap)
//        nearest(tap)
    }

    private func inside(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            let touchPt: CGPoint = tap.location(in: map)
            let coord: CLLocationCoordinate2D = map.convert(touchPt, toCoordinateFrom: map)
            var intersectPoly: MKPolygon?

            for overlay in map.overlays {
                if let overlay = overlay as? MKPolygon {
                    let renderer = MKPolygonRenderer(polygon: overlay)
                    if renderer.path.contains(renderer.point(for: MKMapPoint(coord))) {
                        intersectPoly = overlay
                        break
                    }
                }
            }
            
            if
                let intersectPoly = intersectPoly as? WardPolygon,
                let ward = intersectPoly.ward
            {
                print("Poly: \(ward.areaName)")
            }
        }
    }

    private func nearest(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            // Get map coordinate from touch point
            let touchPt: CGPoint = tap.location(in: map)
            let coord: CLLocationCoordinate2D = map.convert(touchPt, toCoordinateFrom: map)
            let maxMeters: Double = meters(fromPixel: 22, at: touchPt)
            var nearestDistance: Float = MAXFLOAT
            var nearestPoly: MKPolyline?
            // for every overlay ...
            for overlay: MKOverlay in map.overlays {
                // .. if MKPolyline ...
                if let overlay = overlay as? MKPolyline {
                    // ... get the distance ...
                    let distance: Float = Float(distanceOf(pt: MKMapPoint(coord), toPoly: overlay))
                    // ... and find the nearest one
                    if distance < nearestDistance {
                        nearestDistance = distance
                        nearestPoly = overlay
                    }
                }
            }
            
            if Double(nearestDistance) <= maxMeters {
                print("Touched poly: \(String(describing: nearestPoly)) distance: \(nearestDistance)")
                
            }
        }
    }
    
    func distanceOf(pt: MKMapPoint, toPoly poly: MKPolyline) -> Double {
        var distance: Double = Double(MAXFLOAT)
        for n in 0..<poly.pointCount - 1 {
            let ptA = poly.points()[n]
            let ptB = poly.points()[n + 1]
            let xDelta: Double = ptB.x - ptA.x
            let yDelta: Double = ptB.y - ptA.y
            if xDelta == 0.0 && yDelta == 0.0 {
                // Points must not be equal
                continue
            }
            let u: Double = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            var ptClosest: MKMapPoint
            if u < 0.0 {
                ptClosest = ptA
            } else if u > 1.0 {
                ptClosest = ptB
            } else {
                ptClosest = MKMapPoint(x: ptA.x + u * xDelta, y: ptA.y + u * yDelta)
            }
            
            distance = min(distance, ptClosest.distance(to: pt))
        }
        return distance
    }
    
    func meters(fromPixel px: Int, at pt: CGPoint) -> Double {
        let ptB = CGPoint(x: pt.x + CGFloat(px), y: pt.y)
        let coordA: CLLocationCoordinate2D = map.convert(pt, toCoordinateFrom: map)
        let coordB: CLLocationCoordinate2D = map.convert(ptB, toCoordinateFrom: map)
        return MKMapPoint(coordA).distance(to: MKMapPoint(coordB))
    }
}
