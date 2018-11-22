//
//  Optional.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-21.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

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
