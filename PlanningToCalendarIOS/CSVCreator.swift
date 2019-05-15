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
            let paths = try file.parseWorksheetPaths()
            var path = paths.first
            if paths.count > 1 {
                path = paths[1]
            }
            
            let sharedStrings = try file.parseSharedStrings()
            let ws = try file.parseWorksheet(at: path!)
            for row in 1...175 as ClosedRange<UInt>  {
                var count = 0
                for col in ColumnReference("A")!...ColumnReference("AJ")! {
                    if let cell = (ws.cells(atColumns: [col], rows: [row])).first {
                        if cell.type == "s" {
                            if let index = cell.value.flatMap({ Int($0) }) {
                                try csv.write(field: sharedStrings.items[index].text ?? " ")
                                count += 1
                            } else {
                                print("error")
                            }
                        }
                        else {
                            try csv.write(field: cell.value ?? " ")
                            count += 1
                        }
                    } else {
                        let s = ws.cells(atColumns: [col], rows: [row]).first?.value ?? " "
                        try csv.write(field: s)
                        count += 1
                    }
                }
                try csv.write(field: "end\(count)")
                csv.beginNewRow()
            }
            csv.stream.close()
            
            return pathToSave
        } catch {
            print("error: ")
            print(error.localizedDescription)
            print(error)
        }
        return nil
    }
}
