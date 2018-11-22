//
//  Misc.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-21.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

@discardableResult
func measure<A>(name: String = "", _ block: () -> A) -> A {
    let startTime = CACurrentMediaTime()
    let result = block()
    let timeElapsed = CACurrentMediaTime() - startTime
    print("Time: \(name) - \(timeElapsed)")
    return result
}
