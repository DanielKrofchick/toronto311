//
//  WardSearchController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-18.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

class WardSearchController: Sheet {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filters: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var wardSource1: UIButton!
    @IBOutlet weak var wardSource2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filters.layoutMargins = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
        filters.isLayoutMarginsRelativeArrangement = true
                
        scrollView = tableView
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        layoutSheet()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        layoutSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        layoutSheet()
    }
    
    private func layoutSheet() {
        let p = progress()
        minHeight = filters.frame.maxY
        maxHeight = 0.6 * (view.superview?.frame.size.height ?? 0)
        resize(toHeight: p < 0.5 ? minHeight : maxHeight)
    }
}

extension WardSearchController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resize(toHeight: maxHeight)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resize(toHeight: minHeight)
    }
}
