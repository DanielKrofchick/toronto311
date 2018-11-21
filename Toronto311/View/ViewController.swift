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

extension Optional {
    func onThrow(_ errorExpression: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            throw errorExpression()
        }
    }
}

enum DataError: Error {
    case wardSearchController
}

class ViewController: UIViewController {
    private let map = MKMapView()
    private var mapTap = UITapGestureRecognizer()
    private let wardViewModel = WardViewModel()
    private var sheet: WardSearchController!

    private let centerOffset: CLLocationDegrees = 0.08
    private let regionRadius: CLLocationDistance = 20000
    private let reuseIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            sheet = try (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WardSearchController") as? WardSearchController).onThrow(DataError.wardSearchController)
        } catch {
            fatalError("Unable to instantiate WardSearchController")
        }
        
        map.delegate = self
        view.addSubview(map)
        
        mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        map.addGestureRecognizer(mapTap)
        
        if DataController.shared.isLoaded {
            loadData()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .coreDataDidLoad, object: nil)
        }
        
        addAndConfigureChild(sheet)
        sheet.tableView.delegate = self
        sheet.tableView.dataSource = self
        sheet.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        sheet.sheetDelegate = self
        
        initConstraints()
    }
    
    private func sheetFrame(_ fraction: CGFloat) -> CGRect {
        return CGRect(x: 0, y: view.frame.height * fraction, width: view.frame.width, height: view.frame.height * (1.0 - fraction))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        centerMapOnLocation(location: .toronto)
    }
        
    func centerMapOnLocation(location: CLLocation) {
        var center = location.coordinate
        center.latitude += centerOffset
        
        let coordinateRegion = MKCoordinateRegion(center: center,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        map.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    private func initConstraints() {
        map.pin()
    }
}

extension ViewController {
    @objc func loadData() {
        DataController.shared.deleteAll()
        DataImporter.processGeo(source: .WARD_WGS84, forEach: {self.process($0)}, completion: {self.finishProcessing()})
        DataImporter.processGeo(source: .icitw_wgs84, forEach: {self.process($0)}, completion: {self.finishProcessing()})
//        DataImporter.processFirestations {print($0)}
//        DataImporter.processServiceRequests(.disk) {self.map.addAnnotation($0)}
//        DataImporter.processServiceList(.disk) {print($0)}
    }
    
    private func process(_ ward: Ward) {
        if
            let geometry = ward.features().first?.geometries?.first,
            let overlay = geometry.boundary()?.mapShape() as? MKPolyline
        {
            DispatchQueue.main.async {
                [weak self] in
                self?.map.addOverlay(overlay.polygon().wardPolygon(ward))
//                self?.map.addOverlay(overlay.wardPolyline(ward))
//                self?.map.addAnnotation(ward)
            }
        }
    }
    
    private func finishProcessing() {
        measure {
            DataController.shared.save()
            wardViewModel.wards = Ward.all()
            DispatchQueue.main.async {
                [weak self] in
                self?.sheet.tableView.reloadData()
            }
        }
    }
}

@discardableResult
func measure<A>(name: String = "", _ block: () -> A) -> A {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("Time: \(name) - \(timeElapsed)")
    return result
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
        
        if let overlay = overlay as? WardPolyline {
            renderer = overlay.overlayRenderer()
        } else if let overlay = overlay as? WardPolygon {
            renderer = overlay.overlayRenderer()
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
            selectPolygon(polygon)
            print(ward)
        }
    }

    private func nearest(_ tap: UITapGestureRecognizer) {
        if
            tap.state == .recognized,
            let polyline = map.polyline(for: tap.location(in: map)) as? WardPolyline,
            let ward = polyline.ward
        {
            polyline.isSelected.toggle()
            map.removeOverlay(polyline)
            map.addOverlay(polyline)
            print(ward)
        }
    }
    
    func selectPolygon(_ polygon: MKPolygon) {
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
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let ward = wardViewModel.wards[safe: indexPath.row],
            let polygon = map.overlays.first(where: {($0 as? WardPolygon)?.ward == ward}) as? MKPolygon
        {
            self.selectPolygon(polygon)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wardViewModel.wards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        if let ward = wardViewModel.wards[safe: indexPath.row] {
            cell.backgroundColor = .clear
            cell.textLabel?.font = .preferredFont(forTextStyle: .headline)
            cell.textLabel?.text = ward.areaName
        }
        
        return cell
    }
}

extension ViewController: SheetDelegate {
    func sheet(_ sheet: Sheet, didAnimateToHeight height: CGFloat) {
        if height == sheet.minHeight {
            sheet.view.endEditing(true)
        }
    }
}
