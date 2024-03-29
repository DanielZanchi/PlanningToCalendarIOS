//
//  ViewController.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreXLSX

class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate, ProgressDelegate, ErrorDelegate {    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var selectCalendarButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var serviziSwitch: UISwitch!
    
    var converter = Converter.shared
    let types = [
        //        (kUTTypeCommaSeparatedText as String),
        (kUTTypeCompositeContent as String)
    ]
    
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
        
        errorLabel.isHidden = true
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        if let url = urls.first {
            converter.delegate = self
            converter.errorDelegate = self
            progressBar.isHidden = false
            activityIndicator.alpha = 1.0
            activityIndicator.startAnimating()
            errorLabel.isHidden = true
            progressBar.setProgress(0.0, animated: true)
            completedLabel.text = ""

            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            var dept = ["SILK", "SHOES", "LRTW", "MRTW", "BAGS"]
            if serviziSwitch.isOn {
                dept.append("SERVIZI")
            } 
            
            if let csvURL = CSVCreator.shared.create(path: url.path) {
                converter.launchConverter(path: csvURL.path, departments: dept)
            } else {
                print("csv not created correctly")
            }
            
        }
    }
    
    
    func progressChanged(progress: Float) {
        progressBar.setProgress(progress, animated: true)
        
        if progress == 1.0 {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            completedLabel.text = "Updated \(counter) employee events"
            
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
    
    func errorOccurred(error: String) {
        DispatchQueue.main.async {
            self.errorLabel.isHidden = false            
            self.errorLabel.text = "Error! \(error)" 
            print("error \(error)")
        }
    }
    
    @IBAction func selectCalendarTapped(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
}

