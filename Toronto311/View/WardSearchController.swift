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
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = tableView
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
