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
    
    func configureFilter(_ button: UIButton = UIButton(type: .custom), wardSource: WardSource) -> UIButton {
        button.setTitle(wardSource.name(), for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.blue.cgColor
        button.setBackgroundImage(UIImage(color: UIColor.blue.withAlphaComponent(0.3)), for: .normal)
        button.setBackgroundImage(UIImage(color: UIColor.blue.withAlphaComponent(0.3)), for: [.highlighted])
        button.setBackgroundImage(UIImage(color: .blue), for: [.selected])
        button.setBackgroundImage(UIImage(color: .blue), for: [.selected, .highlighted])

        return button
    }
}
