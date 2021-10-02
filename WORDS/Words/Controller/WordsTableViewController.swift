//
//  WordsTableViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import UIKit
import CoreData
import AVKit

class WordsTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var choices = ["100 words", "100 verbs", "Манеры поведения"]
    var pickerView = UIPickerView()
    var typeValue = String()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choices[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            typeValue = "text100words"
        } else if row == 1 {
            typeValue = "100intermediateverbs"
        } else if row == 2 {
            typeValue = "demeanor"
        }
    }
    
    var words: [Word] = []
    var networkTranslateManager = NetworkTranslateManager() 
    
    private var filtersWords: [Word] = []
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    private func selectAddMode() {
        let alertController = UIAlertController(title: "Add new Word", message: "Please select the word add mode", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        let userWordAction = UIAlertAction(title: "My word", style: .default) { (action) in
            self.addUserWord()
        }
        let readyListAction = UIAlertAction(title: "Ready Lists", style: .default) { (action) in
            self.readyList()
        }
        alertController.addAction(userWordAction)
        alertController.addAction(readyListAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private  func readyList(){
        let alertController = UIAlertController(title: "Please select list", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
        
        alertController.view.addSubview(pickerFrame)
        pickerFrame.dataSource = self
        pickerFrame.delegate = self
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.addListWords(listWords: self.readFromFile(nameFileForRead: self.typeValue))
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    private func addListWords(listWords list: [String]){
        var separatedListWords = [String]()
        for item in list {
            separatedListWords.append(contentsOf: item.components(separatedBy: "\n"))
        }

        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Word", in: context) else { return }

        for item in stride(from: 0, through: separatedListWords.count-2, by: 2) {
            let wordObject = Word(entity: entity, insertInto: context)
            wordObject.title = separatedListWords[item]
            wordObject.translate = separatedListWords[item+1]
            wordObject.progress = 0
            wordObject.pin = false
            
            do {
                try context.save()
                words.append(wordObject)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        tableView.reloadData()
    }
    
    private func addUserWord(){
        let alertController = UIAlertController(title: "New Word", message: "Please add a new word", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let tf = alertController.textFields?.first
            if let newWord = tf?.text {
                self.addWord(withWord: newWord)
                self.tableView.reloadData()
            }
        }
        alertController.addTextField { _ in }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func deleteAllElements(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete all words", message: "Are you sure you want to delete all words?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        let deleteAllWordsAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.deleteAllElementsCoreData()
        }
        alertController.addAction(deleteAllWordsAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        tableView.reloadData()
    }
    
    private func deleteAllElementsCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let myPersistentStoreCoordinator = appDelegate.persistentContainer.persistentStoreCoordinator
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try myPersistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
    }
    @IBAction func saveWord(_ sender: UIBarButtonItem) {
        selectAddMode()
    }
     
    // сохраняем данные в CoreData
    private func addWord(withWord word: String){
        let context = getContext()
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Word", in: context) else { return }
        let wordObject = Word(entity: entity, insertInto: context)
        
        wordObject.title = word
        networkTranslateManager.fetchCurrentTranslation(forWord: word) { answer in
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
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func SaveContext() {
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            words = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 60
        
        // Настройка  search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Word"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtersWords.count
        }
        return words.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WordTableViewCell
        var word: Word
        if isFiltering {
            word = filtersWords[indexPath.row]
        } else {
            word = words[indexPath.row]
        }
        cell.wordLabel.text = word.title
        cell.translateLabel.text = word.translate
        cell.backgroundColor = ColorCell[Int(word.progress)]
        cell.imagePin.image = UIImage(systemName: "pin", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal)
        if word.pin == true {
            cell.imagePin.isHidden = false
        } else {
            cell.imagePin.isHidden = true
        }
        
        cell.buttonAction = { sender in
            let synthesizer = AVSpeechSynthesizer()
            let uttetance = AVSpeechUtterance(string: self.words[indexPath.row].title!)
            uttetance.voice = AVSpeechSynthesisVoice(language: "en-En")
            synthesizer.speak(uttetance)
        }
        return cell
    }


    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // удаление элемента из массива и CoreData
        if editingStyle == .delete {
            words.remove(at: indexPath.row)
            print(indexPath.row)
            let context = getContext()
            let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
            if let objects = try? context.fetch(fetchRequest) {
                context.delete(objects[indexPath.row])
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            tableView.reloadData()
        }
    }
    
    private func pin(rowIndexPath indexPath: IndexPath) -> UIContextualAction {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! WordTableViewCell
        let pin = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler  in
            if self.words[indexPath.row].pin == false {
                self.words[indexPath.row].pin = true
                cell.imagePin.isHidden = false
            } else {
                self.words[indexPath.row].pin = false
                cell.imagePin.isHidden = true
            }
            self.SaveContext()
            self.tableView.reloadData()
            completionHandler(true)
        }
        var nameImage: String = ""
        if words[indexPath.row].pin == false {
            nameImage = "pin"
        } else {
            nameImage = "pin.slash"
        }
        pin.image = UIImage(systemName: nameImage, withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal)
        pin.backgroundColor = .orange
        return pin
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pin = pin(rowIndexPath: indexPath)
        let configuration = UISwipeActionsConfiguration(actions: [pin])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    func readFromFile(nameFileForRead name: String) -> [String] {
        var textArray = [String]()
        if let path = Bundle.main.path(forResource: name, ofType: "txt") {
            if let text = try? String(contentsOfFile: path) {
                textArray = text.components(separatedBy: "\n")
            }
        } else {
            print("Не удалось прочитать файл")
        }
        return textArray
    }
    

}


extension WordsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filtersWords = words.filter( { (word: Word) -> Bool in
            return word.title?.lowercased().contains(searchText.lowercased()) ?? false
        })
        tableView.reloadData()
    }
}
