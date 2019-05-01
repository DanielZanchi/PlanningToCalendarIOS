//
//  ViewController.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, ProgressDelegate {

    

    @IBOutlet weak var selectCalendarButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var converter = Converter.shared
    
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
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        if let url = urls.first {
            converter.delegate = self
            progressBar.isHidden = false
            converter.launchConverter(path: url.path)
            
//            let url = CSVCreator.shared.create(path: url.path)
        }
    }
    
    
    func progressChanged(progress: Float) {
        progressBar.setProgress(progress, animated: true)
        
    }
    
    @IBAction func selectCalendarTapped(_ sender: UIButton) {
        let types: [String] = [(kUTTypeCommaSeparatedText as String), (kUTTypeCompositeContent as String)]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
}

