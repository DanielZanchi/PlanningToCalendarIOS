//
//  ViewController.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import UIKit
import MobileCoreServices
//import CoreXLSXx

class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, ProgressDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var selectCalendarButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var converter = Converter.shared
    let types = [(kUTTypeCommaSeparatedText as String),
                 (kUTTypeCompositeContent as String)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        
        selectCalendarButton.layer.cornerRadius = selectCalendarButton.frame.height / 2
        
        if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            versionLabel.text = "v. \(appVersion)"
        } else {
            versionLabel.text = ""
        }
        
//        progressBar.isHidden = true
        progressBar.progress = 0.0

        progressBar.isHidden = true
        progressBar.tintColor = .green
        progressBar.layer.cornerRadius = 10
        progressBar.clipsToBounds = true
        progressBar.layer.sublayers![1].cornerRadius = 10
        progressBar.subviews[1].clipsToBounds = true
        
        completedLabel.alpha = 0.0
        
        activityIndicator.alpha = 0.0
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        if let url = urls.first {
            converter.delegate = self
            progressBar.isHidden = false
            activityIndicator.alpha = 1.0
            activityIndicator.startAnimating()
            converter.launchConverter(path: url.path)
            
            
//            guard let file = XLSXFile(filepath: url.path) else {
//                fatalError("xlsx file corrupted")
//            }
//            do {
//                for path in try file.parseWorksheetPaths() {
//                    let ws = try file.parseWorksheet(at: path)
//                    for row in ws.data?.rows ?? [] {
//                        for c in row.cells {
//                            print(c)
//                        }
//                    }
//                }
//            } catch {
//                print("error: ")
//                print(error.localizedDescription)
//                print(error)
//            }
        }
    }
    
    
    func progressChanged(progress: Float) {
        progressBar.setProgress(progress, animated: true)
        
        if progress == 1.0 {
            UIView.animate(withDuration: 0.8, delay: 1.0, options: .curveEaseInOut, animations: { 
                self.progressBar.alpha = 0.0
                self.completedLabel.alpha = 1.0
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
                self.view.layoutIfNeeded()
            }) { (_) in
                self.progressBar.isHidden = true
                self.progressBar.alpha = 1.0
            }
        }
        
    }
    
    @IBAction func selectCalendarTapped(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
}

