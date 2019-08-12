//
//  Array+Safe.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 12/08/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}
