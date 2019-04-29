//
//  Converter.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import Foundation
import CSV
import iCalKit

class Converter {
    
    static let shared = Converter()
    
    init() {
    }
    
    func launchConverter(path: String) {
        let fileManager = MyFileManager()
        
        let fileString = fileManager.readFile(path: path)
        let CSVString = fileManager.replaceWithCommas(string: fileString)
        let csv = try! CSVReader(string: CSVString)
        
        
        
        //parse CSV file
        while let row = csv.next() {
            let first = (row.first)?.uppercased()
            if monthDictionary.keys.contains(first!) {
                month = first
                for m in monthDictionary {
                    if m.key == month {
                        monthInNumber = Int(m.value)
                    }
                }
            }
            else {
                if row.count > 2 {
                    let second = (row[1]).uppercased()
                    let third = (row[2]).uppercased()
                    if dayNames.contains(second) || dayNames.contains(third) {
                        dayName = row
                        dayName.removeFirst()
                    }
                }
                if first != "" && first != "Casa gucci".capitalized {
                    nameAndHours = row
                    let events = createEventsForPerson(nameAndHours: nameAndHours)
                    
                    let dept = "servizi"
                    fileManager.createOrUpdateFile(events: events, name: "\((nameAndHours.first)!)", department: "\(dept)", path: path)
                }
                
                
            }
        }
        let originalFileURL = URL(fileURLWithPath: path)
        let pathWithoutLastComp = originalFileURL.deletingLastPathComponent()
        if let fileURL = IndexCreator.shared.createIndex(inFolder: pathWithoutLastComp) {
            let file = "index.html"
            let data = try! Data(contentsOf: fileURL)
            
            //        MyFileUploader.shared.upload(fileURL: fileURL)
            print(file)
            let uploadService = FTPUpload(baseUrl: "ftp.planning.altervista.org", userName: "planning", password: "pazpih-zetvUj-tymwu5", directoryPath: "")
            uploadService.send(data: data, with: file) { (success) in
                print(success)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "finish"), object: nil)
                
            }
        }
    }
    
    
    func createEventsForPerson(nameAndHours: [String]) -> [Event]{
        var events = [Event]()
        //parse Hours
        var h: Int!
        var min: Int!
        let y = Date().getCurrentYear()
        var name: String!
        var NAH = nameAndHours
        NAH.removeFirst()
        var day = 0
        for symbol in NAH {
            day = day + 1
            h = 0
            min = 0
            
            switch symbol {
            case "a":
                h = 9
                min = 0
                name = "Apertura"
            case "A":
                h = 8
                min = 0
                name  = "Apertura negozio"
            case "11":
                h = 11
                min = 0
                name = "Chiusura"
            case "":
                if dayName[day-1].capitalized != "D" {
                    h = 10
                    min = 0
                    name = "Normale"
                }
            case "P":
                h = 10
                min = 0
                name = "Normale"
            case "10":
                h = 10
                min = 0
                name = "Normale"
            case "X":
                h = 10
                min = 0
                name = "Normale"
            case "T  T":
                h = 10
                min = 0
                name = "Trasferta"
            case "$":
                if monthInNumber >= 6 && monthInNumber <= 8 {
                    h = 10
                    min = 30
                    name = "$"
                } else {
                    h = 10
                    min = 0
                    name = "Chiusura $"
                }
            case "C":
                h = 10
                min = 0
                name = "Chiusura negozio"
            case "12":
                h = 12
                min = 0
                name = "Mezzogiorno"
            case "13":
                h = 13
                min = 0
                name = "Tredici"
            case "15":
                h = 15
                min = 0
                name = "Quindici"
            case "16":
                h = 16
                min = 0
                name = "Sedici"
            case "14":
                h = 14
                min = 0
                name = "Quattordici"
            case "13$":
                h = 13
                min = 0
                name = "Tredici $"
            case "9.5":
                h = 9
                min = 30
                name = "Nove e mezzo"
            case "9.5X":
                h = 9
                min = 30
                name = "Nove e mezzo"
            case "15$":
                h = 15
                min = 0
                name = "15 Chiusura"
            case "11$":
                h = 11
                min = 0
                name = "11 Chiusura"
            case "12$":
                h = 12
                min = 0
                name = "12 Chiusura"
            case "inv":
                h = 10
                min = 0
                name = "inventario"
            default:
                h = 0
                min = 0
            }
            if h != 0 {
                var eh = h+9
                if eh > 20 {
                    eh = 20
                }
                let start = createDate(year: y, month: monthInNumber, day: day, hour: h, minute: min)
                let end = createDate(year: y, month: monthInNumber, day: day, hour: eh, minute: min)
                let event = createEvent(start: start, end: end, name: name)
                events.append(event)
            }
        }
        return events
    }
    
    func createEvent(start: Date, end: Date, name: String) -> Event{
        var event = Event()
        let startDate = start
        event.summary = name
        event.dtstart = startDate
        let endDate = end
        event.dtend = endDate
        return event
    }
    
    func createDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.timeZone = TimeZone.current
        
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        return date!
    }
}

extension Date {
    func getCurrentYear() -> Int {
        let calendar = Calendar.current
        
        
        let oneMonthFromNow = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        
        let year = calendar.component(.year, from: oneMonthFromNow! )        
        return year
    }
}
