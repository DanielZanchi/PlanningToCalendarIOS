//
//  CSVCreator.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation
import CoreXLSX
import CSV

class CSVCreator {
    
    static let shared = CSVCreator()
    
    private init() {}
    
    func create(path: String) -> URL? {
        let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let pathToSave = documentsFolder?.appendingPathComponent("file.csv") else {
            return nil
        }
        guard let stream = OutputStream(toFileAtPath: pathToSave.path, append: false) else {
            return nil
        }
        
        
        guard let file = XLSXFile(filepath: path) else {
            fatalError("xlsx file corrupted")
        }
        do {
            let csv = try  CSVWriter(stream: stream, codecType: UTF8.self, delimiter: ";", newline: .lf)
            for path in try file.parseWorksheetPaths() {
                let sharedStrings = try file.parseSharedStrings()
                let ws = try file.parseWorksheet(at: path)
                for row in ws.data?.rows ?? [] {
                    
                    for cell in row.cells {
                        if cell.type == "s" {
                            if let index = cell.value.flatMap({ Int($0) }) {
                                try csv.write(field: sharedStrings.items[index].text ?? " ")
                            } else {
                            }
                        }
                        else {
                            try csv.write(field: cell.value ?? " ")
                        }
                    }
                    csv.beginNewRow()
                }
                csv.stream.close()
            
                return pathToSave
            }
        } catch {
            print("error: ")
            print(error.localizedDescription)
            print(error)
        }
        return nil
    }
}
