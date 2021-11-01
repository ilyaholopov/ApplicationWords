//
//  CustomizationWordViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 29.10.2021.
//

import UIKit

class CustomizationWordViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    
    
    var titleWord = ""
    var translate = ""
    var progress: Int16 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        titleTextField.text = titleWord
        translateTextField.text = translate
        progressLabel.text = "Уровень усвоения слова - \(String(progress))"
        
    }
    

}
