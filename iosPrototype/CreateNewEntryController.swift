//
//  CreateNewEntryController.swift
//  iosPrototype
//
//  Created by Dane on 12.12.17.
//  Copyright © 2017 jerry. All rights reserved.
//

import UIKit

class CreateNewEntryController: UIViewController {
    @IBOutlet weak var DescriptionInput: UITextView!
    @IBOutlet weak var DateInformation: UILabel!
    @IBAction func backWithoutSaving(segue: UIStoryboardSegue) {
    }
    
    var myDescription : String? = nil
    
    @IBAction func saveClicked(_ sender: Any) {
        self.setValue(DescriptionInput.text, forKey: "description")
        self.setValue(Date.init(), forKey: "date")
        DescriptionInput.resignFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        DateInformation.text = Date.init().description(with: Locale.current)
        DescriptionInput.becomeFirstResponder()
    }
}
