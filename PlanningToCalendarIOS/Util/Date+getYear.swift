//
//  Date+getYear.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 12/08/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation


extension Date {
    func getCurrentYear() -> Int {
        let calendar = Calendar.current
        
        
        let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        
        let year = calendar.component(.year, from: oneMonthFromNow! )        
        return year
    }
}
