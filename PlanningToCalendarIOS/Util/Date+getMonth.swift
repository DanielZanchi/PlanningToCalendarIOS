//
//  Date+getMonth.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 12/08/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation

extension Date {
    func getMonth() -> Int? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: self)
        
        let month = components.month
        
        return month
    }
}
