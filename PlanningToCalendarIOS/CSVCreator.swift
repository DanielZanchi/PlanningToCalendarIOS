//
//  CSVCreator.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation
import CoreXLSX

class CSVCreator {
    
    static let shared = CSVCreator()
    
    private init() {}
    
    func create(path: String) -> String {
        guard let file = XLSXFile(filepath: path) else {
            fatalError("XLSX file corrupted or does not exist")
        }
        
        do {
            for path in try file.parseWorksheetPaths() {
                let ws = try file.parseWorksheet(at: path)
                for row in ws.data?.rows ?? [] {
                    
                }
            }
        } catch {
            print(error)
        }
        
        return path
    }
}
