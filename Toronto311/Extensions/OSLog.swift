//
//  OSLog.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-11.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import os.log

extension OSLog {
    static let app = OSLog(subsystem: "com.toronto", category: "app")
}
