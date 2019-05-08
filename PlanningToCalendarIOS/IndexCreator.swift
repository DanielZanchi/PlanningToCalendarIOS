//
//  IndexCreator.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation

class IndexCreator {
    
    static let shared = IndexCreator()
    
    private init() {
        
    }
    
    func createIndex(inFolder: URL, department: String) -> URL? {
        let indexUrl = inFolder.appendingPathComponent("index.html")
        
        
        if let fileURLs = try? FileManager.default.contentsOfDirectory(at: inFolder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            var htmlLink = ""
            let sortedURLs = fileURLs.sorted {$0.lastPathComponent < $1.lastPathComponent}
            for file in sortedURLs where file.lastPathComponent != "index.html" {
                print(file.lastPathComponent)
                htmlLink = "\(htmlLink)<a href='webcal://planning.altervista.org/\(department)/\(file.lastPathComponent)'>\(file.deletingPathExtension().lastPathComponent)</a><br>"
            }
            
            
            let htmlContent = "<html><head><title>Planning \(department)</title><meta name='viewport' content='width=device-width, initial-scale=1.0'><body><h2>Planning \(department)</h2><br>\(htmlLink)</body></html>"
            do {
                try htmlContent.write(to: indexUrl, atomically: false, encoding: .utf8)
            } catch {
                print("error writing")
                print(error)
            }
        }
        return indexUrl
    }
    
}
