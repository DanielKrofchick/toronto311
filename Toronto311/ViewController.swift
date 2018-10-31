//
//  ViewController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-10-28.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit
import MapKit

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
        
        let initialLocation = CLLocation(latitude: 43.6532, longitude: -79.3832)
        centerMapOnLocation(location: initialLocation)
        
//        FireStation.importCSV().forEach({ (fireStation) in
//            print(fireStation)
//            map.addAnnotation(fireStation)
//        })
        
        let data = DataImporter.importJSON("ServiceRequests")
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            print(string)
        }

        do {
            try JSONDecoder()
                .decode(ServiceRequestContainer.self, from: data)
                .service_requests
                .forEach({ (serviceRequest) in
                self.map.addAnnotation(serviceRequest)
            })
        } catch {
            print(error)
        }
        
//        api.getServiceRequests { (data, response, error) in
//            if error != nil {
//                print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
//            } else if
//                let data = data,
//                let json = try? JSONSerialization.jsonObject(with: data, options: []),
//                let dictioary = json as? [String: Any]
//            {
//                if let container = try? JSONDecoder().decode(ServiceRequestContainer.self, from: data) {
//                    container.serviceRequests.forEach({ (serviceRequest) in
//                        self.map.addAnnotation(serviceRequest)
//                    })
//                }
//
//                    print(dictioary.json() ?? "")
//            }
//        }
        
//                api.getServiceList { (data, response, error) in
//                    if error != nil {
//                        print("error", (response as? HTTPURLResponse)?.statusCode ?? "")
//                    } else if
//                        let data = data,
//                        let json = try? JSONSerialization.jsonObject(with: data, options: []),
//                        let array = json as? [[AnyHashable: Any]]
//                    {
//                        array.forEach({ (dictionary) in
//                            print(dictionary.json() ?? "")
//                        })
//                    }
//                }
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
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
