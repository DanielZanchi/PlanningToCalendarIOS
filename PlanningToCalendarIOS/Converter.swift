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

protocol ProgressDelegate {
    func progressChanged(progress: Float)
}

class Converter {
    
    static let shared = Converter()
    
    var delegate: ProgressDelegate?
    var progress: Float = 0 {
        didSet {
            delegate?.progressChanged(progress: progress)
        }
    }
    
    var fileManager: MyFileManager!
    
    let monthDictionary: [String: String] = ["GIUGNO": "06", "LUGLIO": "07", "AGOSTO": "08", "SETTEMBRE": "09", "OTTOBRE": "10", "NOVEMBRE": "11", "DICEMBRE": "12", "GENNAIO": "01", "FEBBRAIO": "02", "MARZO": "03", "APRILE": "04", "MAGGIO": "05"]
    let dayNames = ["D","L","M","ME","G","V","S"]
    
    var content: String!
    var month: String!
    var monthInNumber: Int!
    var dayName: [String]!
    var nameAndHours: [String]!
    
    var dept = ["SERVIZI", "SILK", "SHOES", "LRTW", "MRTW", "BAGS", ]
    var symbolsWithName = ["LSILK", "MSILK", "P(M)", "HB", "SHOES", "LUG", "LRTW", "MRTW"]
    
    init() {
    }
    
    func launchConverter(path: String) {
        fileManager = MyFileManager()
        
        let fileString = fileManager.readFile(path: path)
        let fileStringNoCommas = fileManager.replaceCommasWithDots(string: fileString)
        let CSVString = fileManager.replaceWithCommas(string: fileStringNoCommas)
        
        let fraction: Float = 1.0 / Float(dept.count)
        DispatchQueue.global().async {
            
            for department in self.dept {            
                var dep = department
                if department == "SERVIZI" {
                    dep = "servizi"
                }
                let csv = try! CSVReader(string: CSVString)
                
                //parse CSV file
                csv.next()
                while let row = csv.next() {
                    let deptCellString = (row[0].uppercased())
                    guard var monthCellString = (row[safe: 3]) else {
                        continue
                    }
                    monthCellString = monthCellString.uppercased()
                    if self.monthDictionary.keys.contains(monthCellString) {
                        self.month = monthCellString
                        self.monthInNumber = self.getMonthInNumber(month: self.month)
                    }
                    else {
                        if row.count > 2 {
                            guard var firstDay = row[safe: 5] else {
                                continue
                            }
                            guard var secondDay = row[safe: 6] else {
                                continue
                            }

                            firstDay = firstDay.uppercased()
                            secondDay = secondDay.uppercased()
                            if self.dayNames.contains(firstDay) && self.dayNames.contains(secondDay) && firstDay != secondDay {
                                self.dayName = row
                                self.dayName.removeFirst(4)
                            }
                        }
                        if monthCellString != "" && monthCellString != "Casa gucci".capitalized && department == deptCellString {
                            self.nameAndHours = row
                            let events = self.createEventsForPerson(nameAndHours: self.nameAndHours)
                            if events.count > 0 {
                                self.fileManager.createOrUpdateFile(events: events, name: "\((self.nameAndHours[4]))", department: dep)
                            }
                        }
                        
                        
                    }
                }
                
                if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    if let fileURL = IndexCreator.shared.createIndex(inFolder: documentsFolder.appendingPathComponent(dep), department: dep) {
                        let file = "index.html"
                        do {
                            let data = try Data(contentsOf: fileURL)
                            
                            //        MyFileUploader.shared.upload(fileURL: fileURL)
                            let uploadService = FTPUpload(baseUrl: "ftp.planning.altervista.org", userName: "planning", password: "pazpih-zetvUj-tymwu5", directoryPath: dep)
                            uploadService.send(data: data, with: file) { (success) in
                                print(success)
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "finish"), object: nil)
                                
                                DispatchQueue.main.async { () -> Void in  
                                    self.progress = self.progress + fraction 
                                } 
                                
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
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
        NAH.removeFirst(5)
        var day = 0
        for symbol in NAH {
            day = day + 1
            h = 0
            min = 0
            
            let todayName = dayName[day-1].uppercased()
            if dayNames.contains(todayName) == false {
                break
            }
            switch symbol {
            case "a":
                h = 9
                min = 0
                name = "Apertura"
            case "A":
                h = 8
                min = 0
                name  = "Apertura negozio"
            case "11", "11X", "11x":
                h = 11
                min = 0
                name = "11"
            case "", " ":
                if todayName != "D" {
                    h = 10
                    min = 0
                    name = "Normale"
                }
            case "P", "p", "10", "X":
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
                name = "12"
            case "13", "13X", "13x":
                h = 13
                min = 0
                name = "13"
            case "15":
                h = 15
                min = 0
                name = "15"
            case "16":
                h = 16
                min = 0
                name = "16"
            case "14":
                h = 14
                min = 0
                name = "14"
            case "13$":
                h = 13
                min = 0
                name = "13 $"
            case "9.5", "9.5X":
                h = 9
                min = 30
                name = "9:30"
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
            case _ where symbolsWithName.contains(symbol):
                h = 10
                min = 0
                name = symbol
            default:
                h = 0
                min = 0
            }
            if h != 0 {
                var eh = h+9
                if eh > 19 {
                    eh = 19
                    if monthInNumber >= 6 && monthInNumber <= 8 {
                        eh = 20
                    }
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
    
    func getMonthInNumber(month: String) -> Int {
        for m in monthDictionary {
            if m.key == month {
                monthInNumber = Int(m.value)
                return monthInNumber
            }
        }
        return 0
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


extension Array {
    subscript(safe index: Index) -> Element? {
        let isValidIndex = index >= 0 && index < count
        return isValidIndex ? self[index] : nil
    }
}
