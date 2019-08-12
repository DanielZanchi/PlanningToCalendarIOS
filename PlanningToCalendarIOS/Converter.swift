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

protocol ErrorDelegate {
    func errorOccurred(error: String)
}

var counter = 0

class Converter {
    
    static let shared = Converter()
    
    var errorDelegate: ErrorDelegate?
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
    
    var dept = ["SERVIZI", "SILK", "SHOES", "LRTW", "MRTW", "BAGS"]
    var deptServizi = ["WELCOMIST", "MAGAZZINIERI", "INCARTO", "RUNNER", "CASSIERI", "CASSA", "MAGAZZINO", "SERVIZI"]
    var symbolsWithName1030 = ["LSILK10:30:00", "LSILK10:30", "MSILK10:30:00", "MSILK10:30", "P(M)", "HB10:30:00", "SHOES", "shoes10:30:00", "LUG10:30:00", "LRTW10:30:00", "MRTW10:30:00", "MSILK110:30", "HB  10:30", "SILK  10:30", "LRTW  10:30", "MRTW  10:30", "SHOES  10:30", "SILK  12:30", "LUG  10:30", "10:30", "\"10:30\"", "LRTW 10:30", "HB", "SILK", "LUG", "MRTW", "LRTW", ]
    var symbolsWithName1230 = ["shoes12:30:00", "MSILK12:30:00", "SHOES  12:30", "12:30", "LUG  12:30",  "\"12:30\""]
    var symbolsWithName1530 = ["MRTW15:30:00", "shoes15:30:00", "LUG15:30:00", "LSILK15:30:00", "LRTW15:30:00", "HB15:30:00", "MRTW  15:30", "HB  15:30", "SILK  15:30", "SHOES  15:30", "LUG  15:30", "LRTW  15:30", "15shoes", "15:30", "\"15:30\""]
    var symbolsWithName1330 = ["MRTW13:30:00", "LUG13:30:00", "LSILK13:30:00", "shoes13:30:00", "HB13:30:00", "HB  13:30", "LUG  13:30" , "MRTW  13:30", "SHOES  13:30", "SILK  13:30"]
    
    init() {
    }
    
    func launchConverter(path: String, departments: [String]) {
        fileManager = MyFileManager()
        
        self.dept = departments
        let fileString = fileManager.readFile(path: path)
        let fileStringNoCommas = fileManager.replaceCommasWithDots(string: fileString)
        let CSVString = fileManager.replaceWithCommas(string: fileStringNoCommas)
        
        let fraction: Float = 1.0 / Float(dept.count)
        counter = 0
        
        DispatchQueue.global().async {
            
            for department in self.dept {
                let department = department.uppercased()
                var dep = department
                if self.deptServizi.contains(department) {
                    dep = "servizi"
                }
                if department == "BAG" || department == "HB" {
                    dep = "BAGS"
                }
                let csv = try! CSVReader(string: CSVString)
                
                //parse CSV file
//                csv.next()
                while let row = csv.next() {
                    var deptCellString = (row[0].uppercased())
                    if self.deptServizi.contains(deptCellString) {
                        deptCellString = "SERVIZI"
                    }
                    if deptCellString == "HB" || deptCellString == "BAG" {
                        deptCellString = "BAGS"
                    }
                    if deptCellString == "VUOTO" {
                        continue
                    }
                    guard var monthCellString = (row[safe: 4]) else {
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
                                self.dayName.removeFirst(5)
                            }
                        }
                        if monthCellString != "" && monthCellString != "Casa gucci".capitalized && department == deptCellString {
                            self.nameAndHours = row
                            let name = self.nameAndHours[4]
                            if name.isNumber || name == "CASSIERI" || name == "MAGAZZINIERI" || name == "RUNNER" || name == "INCARTO" {
                                continue
                            }
                            let events = self.createEventsForPerson(nameAndHours: self.nameAndHours)
                            if events.count > 0 {
                                counter += 1
                                self.fileManager.createOrUpdateFile(events: events, name: name, department: dep)
                            }
                        }
                        
                        
                    }
                }
                
                if let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    _ = IndexCreator.shared.createIndex(inFolder: documentsFolder.appendingPathComponent(dep), department: dep) 
                    do {
                        let deptDir = documentsFolder.appendingPathComponent(dep)
                        let files = try FileManager.default.contentsOfDirectory(at: deptDir, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
                        for (index, file) in files.enumerated() {
                            let data = try Data(contentsOf: file)
                            
                            let uploadService = FTPUpload(baseUrl: "ftp.planning.altervista.org", userName: "planning", password: "pazpih-zetvUj-tymwu5", directoryPath: dep)
                            uploadService.send(data: data, with: file.lastPathComponent) { (success) in
                                print("\(file.lastPathComponent) \(success) in \(dep)")
                                
                                if index == files.count - 1{
                                    NotificationCenter.default.post(name: Notification.Name(rawValue: "finish"), object: nil)
                                    
                                    DispatchQueue.main.async { () -> Void in  
                                        self.progress = self.progress + fraction 
                                    } 
                                }
                            }
                        }
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
    
    
    func createEventsForPerson(nameAndHours: [String]) -> [Event]{
        var events = [Event]()
        //parse Hours
        let y = Date().getCurrentYear()
        var NAH = nameAndHours
        NAH.removeFirst(5)
        var day = 0
        
        for symbol in NAH {
            var time = Time(h: 0, min: 0, name: "")
            day = day + 1
            
            let todayName = dayName[day-1].uppercased()
            if dayNames.contains(todayName) == false {
                break
            }
            switch symbol {
            case "a":
                time = Time(h: 9, min: 0, name: "apertura")
            case "A":
                time = Time(h: 8, min: 0, name: "apertura negozio")
            case "11", "11X", "11x":
                time = Time(h: 11, min: 0, name: "11")
            case "", " ":
                if todayName != "D" {
                    time = Time(h: 10, min: 0, name: "normale")
                    if isSummer() {
                        time = Time(h: 9, min: 30, name: "normale (MB 9:15)")
                    }
                }
            case "P", "p", "10", "X":
                time = Time(h: 10, min: 0, name: "normale")
                if isSummer() {
                    time = Time(h: 9, min: 30, name: "normale (MB 9:15)")
                }
            case "T  T":
                time = Time(h: 10, min: 0, name: "trasferta")
            case "$":
                if isSummer() {
                    time = Time(h: 10, min: 0, name: "$")
                } else {
                    time = Time(h: 10, min: 0, name: "$")
                }
            case "C", "Cx", "CX":
                time = Time(h: 10, min: 0, name: "chiusura negozio")
            case "12":
                time = Time(h: 12, min: 0, name: "12")
                if isSummer() {
                    time = Time(h: 11, min: 30, name: "12 (11:30)")
                }
            case "13", "13X", "13x", "12:30", "0.52083333333333337":
                time = Time(h: 13, min: 0, name: "13")
                if isSummer() {
                    time = Time(h: 12, min: 30, name: "12:30")
                }
            case "15", "15:00":
                time = Time(h: 15, min: 0, name: "15")
                if isSummer() {
                    time = Time(h: 14, min: 30, name: "15 (14:30)")
                }
            case "16", "15:30", "0.64583333333333337":
                time = Time(h: 16, min: 0, name: "16")
                if isSummer() {
                    time = Time(h: 15, min: 30, name: "15:30")
                }
            case "14", "13:30", "0.5625", "x14":
                time = Time(h: 14, min: 0, name: "14")
                if isSummer() {
                    time = Time(h: 13, min: 30, name: "13:30")
                }
            case "13$":
                time = Time(h: 13, min: 0, name: "13 $")
            case "9.5", "9.5X":
                time = Time(h: 9, min: 30, name: "9:30")
            case "11:30", "0.47916666666666669":
                time = Time(h: 11, min: 30, name: "11:30")
            case "15$":
                time = Time(h: 15, min: 0, name: "15 $")
            case "11$":
                time = Time(h: 11, min: 0, name: "$")
            case "12$":
                time = Time(h: 12, min: 0, name: "12 $")
            case "inv":
                time = Time(h: 10, min: 0, name: "inventario")
            case "10:30", "10:30:00", "0.4375":
                time = Time(h: 10, min: 30, name: "10:30 (MB 10:30)")
            case _ where symbolsWithName1330.contains(symbol):
                if isSummer() {
                    time = Time(h: 13, min: 30, name: symbol)
                }
            case _ where symbolsWithName1530.contains(symbol):
                if isSummer() {
                    time = Time(h: 15, min: 30, name: symbol)
                }
            case _ where symbolsWithName1230.contains(symbol):
                time = Time(h: 12, min: 30, name: symbol)
            case _ where symbolsWithName1030.contains(symbol):
                if isSummer() {
                    time = Time(h: 10, min: 30, name: symbol)
                } else {
                    time = Time(h: 10, min: 0, name: symbol)
                }
            case "x17", "X17":
                time = Time(h: 10, min: 30, name: symbol)
            case "L", "FR", "F", "R", "As", "ROL", "B.R", "LM", "BR", "-", "fr", "MAL", "_", "OFF":
                // not working
                time = Time(h: 0, min: 0, name: "")
            default:
                print("symbol \(symbol)")
                errorDelegate?.errorOccurred(error: "Symbol not handled: \(symbol)")
                time = Time(h: 0, min: 0, name: "")
            }
            if time.h != 0 {
                var eh = time.h + 9
                if eh > 19 {
                    eh = 19
                    if isSummer() {
                        eh = 20
                    }
                }
                
                if monthInNumber == nil {
                    errorDelegate?.errorOccurred(error: "MonthInNumber NIL - Contact Daniel")    
                    break
                }
                let start = createDate(year: y, month: monthInNumber, day: day, hour: time.h, minute: time.min)
                let end = createDate(year: y, month: monthInNumber, day: day, hour: eh, minute: time.min)
                let event = createEvent(start: start, end: end, name: time.name)
                events.append(event)
            }
        }
        return events
    }
    
    func isSummer() -> Bool {
        if monthInNumber == nil {
            errorDelegate?.errorOccurred(error: "MonthInNumber NIL - Contact Daniel")
            return false
        }
        return monthInNumber >= 6 && monthInNumber <= 8
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
    
    struct Time {
        var h: Int
        var min: Int
        var name: String
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

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
