//
//  ViewController.swift
//  PlanningToCalendarIOS
//
//  Created by Daniel Zanchi on 29/04/2019.
//  Copyright © 2019 Daniel Zanchi. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIDocumentPickerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var selectCalendarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func loadView() {
        super.loadView()
        
        selectCalendarButton.layer.cornerRadius = selectCalendarButton.frame.height / 2
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // you get from the urls parameter the urls from the files selected
        if let url = urls.first {
            Converter.shared.launchConverter(path: url.path)
            
//            let url = CSVCreator.shared.create(path: url.path)
        }
    }
    
    @IBAction func selectCalendarTapped(_ sender: UIButton) {
        let types: [String] = [(kUTTypeCommaSeparatedText as String), (kUTTypeCompositeContent as String)]
        let documentPicker = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        self.present(documentPicker, animated: true, completion: nil)
    }
    
}

