//
//  String+isNumber.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 12/08/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
