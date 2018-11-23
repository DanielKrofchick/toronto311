//
//  WardViewModel.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-11.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

class WardViewModel {
    var wards = [Ward]()
    
    func configureFilter(_ button: UIButton = UIButton(type: .system), wardSource: WardSource) -> UIButton {
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 2
        button.setTitle(wardSource.name(), for: .normal)
        return button
    }
}
