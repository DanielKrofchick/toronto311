//
//  MapController.swift
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

class MapController: UIViewController {
    private let map = MKMapView()
    private var mapTap = UITapGestureRecognizer()
    private let viewModel = WardViewModel()
    private var sheet: WardSearchController!
    private var wardButtons = [WardButton]()

    private let reuseIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initSheet()
        initMap()
        initData()
        initConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        map.setRegion(.toronto, animated: true)
    }
}

// MARK: - Init -
extension MapController {
    private func initMap() {
        map.delegate = self
        view.insertSubview(map, belowSubview: sheet.view)
        
        mapTap = UITapGestureRecognizer(target: self, action: #selector(mapTapped(_:)))
        map.addGestureRecognizer(mapTap)
    }
    
    private func initData() {
        if DataController.shared.isLoaded {
            loadData()
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: .coreDataDidLoad, object: nil)
        }
    }
    
    private func initSheet() {
        do {
            sheet = try (UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "WardSearchController") as? WardSearchController)
                .onThrow(DataError.wardSearchController)
        } catch {
            fatalError("Unable to instantiate WardSearchController")
        }
        
        sheet.loadViewIfNeeded()
        sheet.textDidChange = {[weak self] in self?.load()}
        sheet.tableView.allowsMultipleSelection = true
        sheet.tableView.delegate = self
        sheet.tableView.dataSource = self
        sheet.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        sheet.sheetDelegate = self
        addChildController(sheet)
    }
    
    private func initWardFilterButtons() {
        WardSource.allCases.sorted().forEach { (wardSource) in
            let button = viewModel.configureFilter(wardSource: wardSource)
            button.addTarget(self, action: #selector(sourceTap(button:)), for: .touchUpInside)
            wardButtons.append(WardButton(wardSource: wardSource, button: button))
            sheet.filters.addArrangedSubview(button)
        }
    }
    
    private func initConstraints() {
        map.pin()
    }
}

// MARK: - Delegates -
extension MapController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = viewModel.item(for: indexPath) {
            toggleMapSelect(item)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let item = viewModel.item(for: indexPath) {
            toggleMapSelect(item)
        }
    }
}

extension MapController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        viewModel.configure(cell: cell, forRowAt: indexPath)
        
        return cell
    }
}

extension MapController: MKMapViewDelegate {
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

extension MapController: SheetDelegate {
    func sheet(_ sheet: Sheet, didAnimateToHeight height: CGFloat) {
        if height == sheet.minHeight {
            sheet.view.endEditing(true)
        }
    }
}

// MARK: - Data -
extension MapController {
    @objc func loadData() {
        initWardFilterButtons()
        DataController.shared.deleteAll()
        DataImporter.processGeos(completion: {self.finishProcessing()})
        DataImporter.processServiceRequests(.disk) {self.map.addAnnotation($0)}
    }
    
    private func finishProcessing() {
        measure(name: "save-data") {
            DataController.shared.save()
            wardButtons.forEach{$0.button.isSelected = true}
            load()
        }
    }
}

// MARK: - Selection -
extension MapController {
    // MARK: - Ward -
    @objc func mapTapped(_ tap: UITapGestureRecognizer) {
        if tap.state == .recognized {
            toggleOverlays(at: tap)
        }
    }
    
    // Finds polygons contianing tap
    private func toggleOverlays(at tap: UITapGestureRecognizer) {
        map.overlays(for: tap.location(in: map)).forEach { (overlay) in
            if let item = viewModel.item(for: overlay) {
                toggleTableSelect(for: item)
                toggleMapSelect(item)
            }
        }
    }
    
    // Finds polylines nearest tap
    private func toggleOverlays(nearest tap: UITapGestureRecognizer) {
        if
            let overlay = map.polyline(for: tap.location(in: map)),
            let item = viewModel.item(for: overlay)
        {
            toggleTableSelect(for: item)
            toggleMapSelect(item)
        }
    }
    
    func toggleMapSelect(_ item: WardItem) {
        item.isSelected.toggle()
        viewModel.addOverlays(item: item, map: map)
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
        loadModel()
        loadInterface()
    }
    
    private func loadModel() {
        measure(name: "fetch") {
            if let wards = try? Ward.objects(
                context: DataController.shared.context,
                predicate: loadPredicate(),
                ascending: true)
            {
                viewModel.items = wards.map{WardItem(ward: $0)}
            }
        }
    }
    
    private func loadPredicate() -> NSPredicate {
        let selected = wardButtons.filter({ $0.button.isSelected })
        let wardPredicates = selected.map({NSPredicate(format: "source = %@", $0.wardSource.rawValue)})
        var predicate = NSCompoundPredicate(orPredicateWithSubpredicates: wardPredicates)
        if
            let text = sheet.searchBar.text,
            !text.isEmpty
        {
            let searchPredicate = NSPredicate(format: "areaName CONTAINS[cd] %@", text)
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                predicate,
                searchPredicate
                ])
        }
        
        return predicate
    }
    
    private func loadInterface() {
        DispatchQueue.main.async {
            [weak self, map = map] in
            guard let self = self else {return}
            self.viewModel.configureOverlays(map: map)
            self.sheet.tableView.reloadData()
            self.viewModel.configureSelectedCells(tableView: self.sheet.tableView)
        }
    }
}
