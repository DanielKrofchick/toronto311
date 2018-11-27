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

enum DataError: Error {
    case wardSearchController
}

private struct WardButton {
    let wardSource: WardSource
    let button: UIButton
}

class ViewController: UIViewController {
    private let map = MKMapView()
    private var mapTap = UITapGestureRecognizer()
    private let viewModel = WardViewModel()
    private var sheet: WardSearchController!
    
    private var wardButtons = [WardButton]()

    private let reuseIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            sheet = try (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "WardSearchController") as? WardSearchController)
                .onThrow(DataError.wardSearchController)
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
        
        doAddChild(sheet)
        sheet.tableView.allowsMultipleSelection = true
        sheet.tableView.delegate = self
        sheet.tableView.dataSource = self
        sheet.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        sheet.sheetDelegate = self
        
        WardSource.allCases.sorted().forEach { (wardSource) in
            let button = viewModel.configureFilter(wardSource: wardSource)
            button.addTarget(self, action: #selector(sourceTap(button:)), for: .touchUpInside)
            wardButtons.append(WardButton(wardSource: wardSource, button: button))
            sheet.filters.addArrangedSubview(button)
        }
        
        initConstraints()
    }
    
    private func sheetFrame(_ fraction: CGFloat) -> CGRect {
        return CGRect(x: 0, y: view.frame.height * fraction, width: view.frame.width, height: view.frame.height * (1.0 - fraction))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        map.setRegion(torontoRegion(), animated: true)
    }
    
    private func torontoRegion() -> MKCoordinateRegion {
        let radius: CLLocationDistance = 20000
        let location = CLLocation.toronto + CLLocation(latitude: 0.08, longitude: 0)
        return MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
    }
    
    private func initConstraints() {
        map.pin()
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = viewModel.item(for: indexPath) {
            toggle(item, withTableSelect: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let item = viewModel.item(for: indexPath) {
            toggle(item, withTableSelect: false)
        }
    }
    
    func toggle(_ item: WardItem, withTableSelect: Bool) {
        if let overlay = item.overlay {
            item.isSelected.toggle()
            if withTableSelect {
                toggleTableSelect(for: item)
            }
            map.removeOverlay(overlay)
            map.addOverlay(overlay)
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        viewModel.configure(cell: cell, forRowAt: indexPath)
        
        return cell
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
//        ward.addPolygon(to: map)
//        ward.addPolyline(to: map)
//        ward.addAnnotation(to: map)
    }
    
    private func finishProcessing() {
        measure(name: "save-data") {
            DataController.shared.save()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var result: MKAnnotationView?
        
        if
            let annotation = annotation as? Ward,
            let item = viewModel.item(for: annotation)
        {
            result = item.annotationView(mapView)
        }
        
        return result
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return viewModel.item(for: overlay)?.overlayRenderer() ?? MKOverlayRenderer()
    }
}

extension ViewController: SheetDelegate {
    func sheet(_ sheet: Sheet, didAnimateToHeight height: CGFloat) {
        if height == sheet.minHeight {
            sheet.view.endEditing(true)
        }
    }
}

// MARK: - Selection -

extension ViewController {
    
    // MARK: - Ward -
    
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            toggleOverlays(at: tap)
//            toggleOverlays(nearest: tap)
        }
    }
    
    private func toggleOverlays(at tap: UITapGestureRecognizer) {
        map.overlays(for: tap.location(in: map)).forEach { (overlay) in
            if let item = viewModel.item(for: overlay) {
                toggle(item, withTableSelect: true)
            }
        }
    }
    
    private func toggleOverlays(nearest tap: UITapGestureRecognizer) {
        if let overlay = map.polyline(for: tap.location(in: map)) {
            if let item = viewModel.item(for: overlay) {
                toggle(item, withTableSelect: true)
            }
        }
    }
    
    private func toggleTableSelect(for item: WardItem) {
        guard let indexPath = viewModel.indexPath(for: item) else {return}
        
        if
            let selectedIndexPaths = sheet.tableView.indexPathsForSelectedRows,
            selectedIndexPaths.contains(indexPath)
        {
            sheet.tableView.deselectRow(at: indexPath, animated: true)
        } else {
            sheet.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    // MARK: - WardSource -
    
    @objc func sourceTap(button: UIButton) {
        button.isSelected = !button.isSelected
        load()
    }
    
    private func load() {
        let selected = wardButtons.filter({ $0.button.isSelected })
        let arguments = selected.map({ $0.wardSource.rawValue })
        let format = selected.reduce("") { (result, _) -> String in
            return result + (result.isEmpty ? "" : " OR ") + "source = %@"
        }
        
        if format.isEmpty {
            viewModel.items = []
        } else {
            measure(name: "fetch-\(arguments)") {
                if let wards = try? Ward.objects(
                    context: DataController.shared.context,
                    predicate: NSPredicate(format: format, argumentArray: arguments),
                    ascending: true)
                {
                    viewModel.items = wards.map({WardItem(ward: $0)})
                }
            }
        }
        
        DispatchQueue.main.async {
            [weak self, map = map] in
            map.removeAnnotations(map.annotations)
            map.removeOverlays(map.overlays)
            self?.viewModel.items.forEach({
                [map = map] in
                if var overlay = $0.ward.shape() as? MKOverlay {
                    if let o = overlay as? MKPolygon {
                        overlay = o.polyline()
                    }
                    $0.overlay = overlay
                    map.addOverlay(overlay)
                    map.addAnnotation($0.ward)
                }
            })
            self?.sheet.tableView.reloadData()
        }
    }
}
