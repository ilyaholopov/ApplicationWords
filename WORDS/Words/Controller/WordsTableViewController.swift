//
//  WordsTableViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import UIKit
import CoreData

class WordsTableViewController: UITableViewController {
    
    //индикатор, нужно его отсюда убрать
    var activityView: UIActivityIndicatorView?
    
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
    
    func selectAddMode() {
        let alertController = UIAlertController(title: "Add new Word", message: "Please select the word add mode", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        let userWordAction = UIAlertAction(title: "My word", style: .default) { (action) in
            self.addUserWord()
        }
        let wordListAction = UIAlertAction(title: "100 words", style: .default) { (action) in
            self.addListWords()
        }
        alertController.addAction(userWordAction)
        alertController.addAction(wordListAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func addListWords(){
        let listWords = readFromFile()
        var separatedListWords = [String]()
        for item in listWords {
            separatedListWords.append(contentsOf: item.components(separatedBy: "\n"))
        }

        let context = getContext()
        guard let entity = NSEntityDescription.entity(forEntityName: "Word", in: context) else { return }
        
        
        for item in stride(from: 0, through: 198, by: 2) {
            let wordObject = Word(entity: entity, insertInto: context)
            wordObject.title = separatedListWords[item]
            wordObject.translate = separatedListWords[item+1]
            wordObject.progress = 1
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
    
    func addUserWord(){
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
        wordObject.progress = 1
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
        cell.backgroundColor = ColorCell[Int(word.progress)-1]
        cell.imagePin.image = UIImage(systemName: "pin", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withRenderingMode(.alwaysOriginal)
        if word.pin == true {
            cell.imagePin.isHidden = false
        } else {
            cell.imagePin.isHidden = true
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
    
    func readFromFile() -> [String] {
        var textArray = [String]()
        if let path = Bundle.main.path(forResource: "text100words", ofType: "txt") {
            if let text = try? String(contentsOfFile: path) {
                textArray = text.components(separatedBy: "\n\n")
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
