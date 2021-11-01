//
//  CustomizationWordViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 29.10.2021.
//

import UIKit
import CoreData

class CustomizationWordViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var translateTextField: UITextField!
    @IBOutlet weak var progressLabel: UILabel!
    
        
    var indexPathRow = 0
    
    var words3: [Word] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.returnKeyType = .done
        titleTextField.autocorrectionType = .no
        titleTextField.clearsOnBeginEditing = false
        titleTextField.clearButtonMode = .whileEditing
        titleTextField.delegate = self
        
        
        translateTextField.returnKeyType = .done
        translateTextField.autocorrectionType = .no
        translateTextField.clearsOnBeginEditing = false
        translateTextField.clearButtonMode = .whileEditing
        translateTextField.delegate = self
    }
    
    private func SaveContext() {
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            words3 = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        titleTextField.text = words3[indexPathRow].title
        translateTextField.text = words3[indexPathRow].translate
        progressLabel.text = "Уровень усвоения слова - \(String(words3[indexPathRow].progress))"
    }
    
    
    private func editWord() {
        words3[indexPathRow].title = titleTextField.text
        words3[indexPathRow].translate = translateTextField.text
        SaveContext()
    }
    

}

extension CustomizationWordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        editWord()
        return true
    }
}
