//
//  ViewController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

extension CLLocation {
    static let toronto = CLLocation(latitude: 43.6532, longitude: -79.3832)
}

class ViewController: UIViewController {
    let map = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.frame = view.bounds
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = self
        view.addSubview(map)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centerMapOnLocation(location: .toronto)
        
//        annotateFirestations()
//        annotateServiceRequestsCached()
//        annotateServiceRequestsAPI()
        getServiceListCached()
//        getServiceListAPI()
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
}

extension ViewController {
    func annotateFirestations() {
        FireStation.importCSV().forEach({ (fireStation) in
            print(fireStation)
            map.addAnnotation(fireStation)
        })
    }
    
    func annotateServiceRequestsCached() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            let data = DataImporter.importJSON("ServiceRequests")
            self?.annotateServiceRequests(data)
        }
    }
    
    func annotateServiceRequestsAPI() {
        API.getServiceRequests { [weak self] (data, response, error) in
            if error != nil {
                print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
            } else if let data = data {
                self?.annotateServiceRequests(data)
            }
        }
    }
    
    private func annotateServiceRequests(_ data: Data) {
        do {
            let requests = try JSONDecoder()
                .decode(ServiceRequestContainer.self, from: data)
                .service_requests
            DispatchQueue.main.async {
                requests.forEach {self.map.addAnnotation($0)}
            }
        } catch {
            print(error)
        }
    }
    
    func getServiceListCached() {
        let data = DataImporter.importJSON("ServiceList")
        getServiceList(data)
    }
    
    func getServiceListAPI() {
        API.getServiceList { [weak self] (data, response, error) in
            if error != nil {
                print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
            } else if let data = data {
                self?.getServiceList(data)
            }
        }
    }
    
    func getServiceList(_ data: Data) {
        do {
            let types = try JSONDecoder()
                .decode([ServiceType].self, from: data)
            DispatchQueue.main.async {
                types.forEach {print($0)}
            }
        } catch {
            print(error)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        if let annotationView = annotationView as? MKPinAnnotationView {
            annotationView.canShowCallout = true
            annotationView.annotation = annotation
            
            if let request = annotation as Any as? ServiceRequest {
                annotationView.pinTintColor = request.service_code?.color()
            }
        }
        
        return annotationView
    }
}
