//
//  ReadyListsTVC.swift
//  WORDS
//
//  Created by Илья Холопов on 26.02.2022.
//

import UIKit
import CoreData

class ReadyListsTVC: UITableViewController {
    
    private var readyLists = [List(status: false, nameList: "Глаголы A1", filename: "VerbsA1"),
                              List(status: false, nameList: "Окружающий мир A1", filename: "WorldA1"),
                              List(status: false, nameList: "Семья A1", filename: "FamilyA1")]
    private var words: [Word] = []
    
    @IBAction func statusSwitchAction(_ sender: UISwitch) {
        if sender.isOn {
            readyLists[sender.tag].status = true
            addListWords(listWords: self.readFromFile(nameFileForRead: readyLists[sender.tag].filename))
        } else {
            readyLists[sender.tag].status = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 60
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            words = try context.fetch(fetchRequest)
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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return readyLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellLists", for: indexPath) as! ReadyListsTableViewCell

        cell.nameListLabel.text = readyLists[indexPath.row].nameList
        cell.addListSwitch.isOn = readyLists[indexPath.row].status
        cell.addListSwitch.tag = indexPath.row
        return cell
    }
    
    private func readFromFile(nameFileForRead name: String) -> [String] {
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
