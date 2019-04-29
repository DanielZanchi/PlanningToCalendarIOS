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
    
    func createIndex(inFolder: URL) -> URL? {
        let indexUrl = inFolder.appendingPathComponent("index.html")
        
        let folderURL = inFolder.appendingPathComponent("servizi")
        
        if let fileURLs = try? FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            var htmlLink = ""
            let sortedURLs = fileURLs.sorted {$0.lastPathComponent < $1.lastPathComponent}
            for file in sortedURLs {
                print(file.lastPathComponent)
                htmlLink = "\(htmlLink)<a href='webcal://planning.altervista.org/servizi/\(file.lastPathComponent)'>\(file.deletingPathExtension().lastPathComponent)</a><br>"
            }
            
            
            let htmlContent = "<html><head><title>Gucci Leccio Planning></title><body><h2>GUCCI LECCIO PLANNING</h2><br>\(htmlLink)</body></html>"
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
