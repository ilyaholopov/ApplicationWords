//
//  ProfileViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 25.09.2021.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    
    var words2: [Word] = []
    @IBOutlet weak var wordsForStudyLabel: UILabel!
    @IBOutlet weak var wordsLearnedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func numberWordsLearned() -> Int {
        var number: Int = 0
        for item in words2 {
            if item.progress == 10 {
                number += 1
            }
        }
        return number
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        do {
            words2 = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        wordsForStudyLabel.text = "Слов на изучении: \(words2.count)"
        wordsLearnedLabel.text = "Слов изучено: \(numberWordsLearned())"
    }
    

}
