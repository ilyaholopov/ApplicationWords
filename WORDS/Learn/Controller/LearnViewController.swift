//
//  LearnViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 09.06.2021.
//

import UIKit
import CoreData
import AVKit

class LearnViewController: UIViewController {
    
    var words2: [Word] = []
    var index = Array(repeating: false, count: 4)
    var indexWords: Int = 0
    var lastIndex: Int = -1
    var mode: Int = 0
    
    
    @IBAction func answer1_button(_ sender: UIButton) {
        selectAnswer(indexAnswer: 0)
    }
    @IBAction func answer2_button(_ sender: UIButton) {
        selectAnswer(indexAnswer: 1)
    }
    @IBAction func answer3_button(_ sender: UIButton) {
        selectAnswer(indexAnswer: 2)
    }
    @IBAction func answer4_button(_ sender: UIButton) {
        selectAnswer(indexAnswer: 3)
    }
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet var answers: [UIButton]!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    
    @IBAction func nextButton(_ sender: UIButton) {
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        wordForStudy()
        enableAllButton(selector: true)
        nextButtonOutlet.backgroundColor = .orange
    }
    @IBAction func volumeButton(_ sender: UIButton) {
        let synthesizer = AVSpeechSynthesizer()
        if mode == 0 {
            let uttetance = AVSpeechUtterance(string: words2[indexWords].title!)
            uttetance.voice = AVSpeechSynthesisVoice(language: "en-En")
            synthesizer.speak(uttetance)
        } else {
            let uttetance = AVSpeechUtterance(string: words2[indexWords].translate!)
            uttetance.voice = AVSpeechSynthesisVoice(language: "ru-Ru")
            synthesizer.speak(uttetance)
        }
    }
    
    private func selectAnswer(indexAnswer: Int) {
        if index[indexAnswer] == true {
            answers[indexAnswer].backgroundColor = .systemGreen
            if words2[indexWords].progress != 10 {
                words2[indexWords].progress += 2
            }
        } else {
            answers[indexAnswer].backgroundColor = UIColor.red
            if words2[indexWords].progress > 2 {
                words2[indexWords].progress -= 2
            }
            for item in 0...3 {
                if index[item] == true {
                    answers[item].backgroundColor = .systemGreen
                }
            }
        }
        enableAllButton(selector: false)
        nextButtonOutlet.backgroundColor = .green
    }
    
    private func enableAllButton(selector: Bool) {
        for item in 0...3 {
            answers[item].isEnabled = selector
        }
    }
    
    //выбирает рандомом из элементов с самым низким прогрессом
    private func nextIndexWordForLearn() -> Int {
        var minProgress = 10
        var indices = [Int]()
        for item in 0..<words2.count {
            if (words2[item].progress < minProgress) && (item != lastIndex) {
                minProgress = Int(words2[item].progress)
                indices.removeAll()
                indices.append(item)
            }
            if words2[item].progress == minProgress {
                indices.append(item)
            }
            
        }
        return indices[Int.random(in: 0..<indices.count)]
    }
    
    private func wordForStudy() {
        for item in 0...3 {
            index[item] = false
        }
        index[Int.random(in: 0...3)] = true
        indexWords = nextIndexWordForLearn()
        self.mode = Int.random(in: 0...1)
        
        switch mode {
        case 0:
            wordLabel.text = words2[indexWords].title
        case 1:
            wordLabel.text = words2[indexWords].translate
        default:
            print("Error")
        }
        
        for item in 0...3 {
            switch mode {
            case 0:
                if index[item] == true {
                    answers[item].setTitle(words2[indexWords].translate, for: .normal)
                } else {
                    let wordRandom = words2[Int.random(in: 0..<words2.count)]
                    if wordRandom == words2[indexWords] {
                        index[item] = true
                    }
                    answers[item].setTitle(wordRandom.translate, for: .normal)
                }
            case 1:
                if index[item] == true {
                    answers[item].setTitle(words2[indexWords].title, for: .normal)
                } else {
                    let wordRandom = words2[Int.random(in: 0..<words2.count)]
                    if wordRandom == words2[indexWords] {
                        index[item] = true
                    }
                    answers[item].setTitle(wordRandom.title, for: .normal)
                }
            default:
                print("Error")
            }
            answers[item].backgroundColor = UIColor.orange
        }
        
        lastIndex = indexWords
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButtonOutlet.layer.cornerRadius = 15
        nextButtonOutlet.layer.shadowColor = UIColor.black.cgColor
        nextButtonOutlet.layer.shadowOffset = CGSize(width: 5, height: 5)
        nextButtonOutlet.layer.shadowRadius = 5
        nextButtonOutlet.layer.shadowOpacity = 0.6
        for item in 0...3 {
            answers[item].layer.cornerRadius = 15
            answers[item].layer.shadowColor = UIColor.black.cgColor
            answers[item].layer.shadowOffset = CGSize(width: 3, height: 3)
            answers[item].layer.shadowRadius = 5
            answers[item].layer.shadowOpacity = 0.6
            
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
            words2 = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        wordForStudy()
        
    }

}
