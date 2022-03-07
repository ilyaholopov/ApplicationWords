//
//  AddNewWordsViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 27.01.2022.
//

import UIKit
import CoreData

class AddNewWordsViewController: UIViewController {
    
    private var lanSelection: String = "en-ru"
    private var words: [Word] = []
    private var textArray = [String]()
    private var dublicate = [String]()
    private var networkTranslateManager = NetworkTranslateManager()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var outletLanSelection: UISegmentedControl!
    
    @IBAction func actionLanSelection(_ sender: UISegmentedControl) {
        switch outletLanSelection.selectedSegmentIndex {
        case 0:
            lanSelection = "en-ru"
        case 1:
            lanSelection = "ru-en"
        default:
            break
        }
    }
    @IBAction func actionDone(_ sender: UIBarButtonItem) {
        textView.resignFirstResponder()
        if textView.text == "" {
            print("View пуст")
            done.isEnabled = false
            done.tintColor = .clear
            return
        }
        let text = self.textView.text!
        textArray = text.components(separatedBy: "\n")
        addButton.backgroundColor = .orange
        addButton.isEnabled = true
        done.isEnabled = false
        done.tintColor = .clear
    }
    @IBAction func actionAddButton(_ sender: UIButton) {
//        for item in 0..<textArray.count {
//            for item2 in 0..<words.count {
//                if comparison(word1: textArray[item], word2: words[item2].title!) {
//                    textArray.remove(at: item)
//                }
//            }
//        }
        for item in 0..<textArray.count {
            self.addWord(withWord: textArray[item])
        }
        addButton.backgroundColor = .gray
        addButton.isEnabled = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButton()
        setupTextView()
        
        done.isEnabled = false
        done.tintColor = .clear
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            words = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func setupTextView(){
        textView.delegate = self
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 20
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    }
    
    private func setupButton(){
        addButton.layer.cornerRadius = 20
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOpacity = 0.6
        addButton.backgroundColor = .gray
        addButton.isEnabled = false
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func addWord(withWord word: String){
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Word", in: context) else { return }
        let wordObject = Word(entity: entity, insertInto: context)
        
        wordObject.title = word
        networkTranslateManager.fetchCurrentTranslation(for: lanSelection ,forWord: word) { answer in
            wordObject.translate = answer.translation
        }
        wordObject.progress = 0
        wordObject.pin = false
        
        do {
            try context.save()
            words.append(wordObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    

    
    private func comparison(word1: String, word2: String) -> Bool {
        if word1.lowercased() == word2.lowercased() {
            return true
        } else {
            return false
        }
    }

}

extension AddNewWordsViewController: UITextViewDelegate {
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        done.isEnabled = true
        done.tintColor = nil
    }
}
