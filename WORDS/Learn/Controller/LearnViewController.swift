//
//  LearnViewController.swift
//  WORDS
//
//  Created by Илья Холопов on 09.06.2021.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import AudioToolbox
import Foundation

class LearnViewController: UIViewController {
    
    var words2: [Word] = []
    var index = Array(repeating: false, count: 4)
    var indexWords: Int = 0
    var lastIndex: Int = -1
    var mode: Int = 0
    
    @IBOutlet weak var voiceOutlet: UIButton!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var outlletTextField: UITextField!
    @IBAction func answerTextField(_ sender: UITextField) {
    }
    
    @IBAction func answer1_button(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        selectAnswer(indexAnswer: 0)
    }
    @IBAction func answer2_button(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        selectAnswer(indexAnswer: 1)
    }
    @IBAction func answer3_button(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        selectAnswer(indexAnswer: 2)
    }
    @IBAction func answer4_button(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1104))
        selectAnswer(indexAnswer: 3)
    }
    
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet var answers: [UIButton]!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    
    @IBAction func nextButton(_ sender: UIButton) {
        AudioServicesPlaySystemSound(SystemSoundID(1105))
        let context = getContext()
        do {
            try context.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        resultLabel.text = ""
        wordForStudy()
        enableAllButton(selector: true)
        nextButtonOutlet.backgroundColor = .systemGray2
        outlletTextField.text = ""
    }
    
    private func spellCheck() {
        let text1 = outlletTextField.text?.lowercased()
        let text2 = words2[indexWords].title?.lowercased()
        if text1 == text2 {
            resultLabel.text = "Правильно!"
            if words2[indexWords].progress != 10 {
                words2[indexWords].progress += 2
            }
        } else {
            if let text = words2[indexWords].title {
                resultLabel.text = "Не правильно! Ответ: \(text)"
                if words2[indexWords].progress > 2 {
                    words2[indexWords].progress -= 2
                }
            }
        }
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
            resultLabel.text = "Правильно!"
            if words2[indexWords].progress != 10 {
                words2[indexWords].progress += 2
            }
        } else {
            resultLabel.text = "Не правильно!"
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
    
    private func spellingExercise() {
        for item in 0...3 {
            answers[item].isHidden = true
        }
        resultLabel.text = ""
        outlletTextField.isHidden = false
    }
    
    private func wordForStudy() {
        for item in 0...3 {
            index[item] = false
        }
        index[Int.random(in: 0...3)] = true
        indexWords = nextIndexWordForLearn()
        selectMode()
        
        switch mode {
        case 0:
            wordLabel.text = words2[indexWords].title
        case 1..<3:
            wordLabel.text = words2[indexWords].translate
        default:
            print("Error")
        }
        
        if mode == 2 {
            spellingExercise()
        } else {
            outlletTextField.isHidden = true
            for item in 0...3 {
                answers[item].isHidden = false
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
            
        }
        
        lastIndex = indexWords
    }
    
    private func selectMode(){
        switch words2[indexWords].progress {
        case 0..<7:
            mode = Int.random(in: 0...1)
        case 7..<11:
            mode = 2
        default:
            print("Error")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupTextField(){
        outlletTextField.returnKeyType = .done
        outlletTextField.autocorrectionType = .no
        outlletTextField.placeholder = "Введите слово"
        outlletTextField.delegate = self
    }
    
    private func setupNextButton(){
        nextButtonOutlet.layer.cornerRadius = 20
        nextButtonOutlet.layer.shadowColor = UIColor.black.cgColor
        nextButtonOutlet.layer.shadowOffset = CGSize(width: 5, height: 5)
        nextButtonOutlet.layer.shadowRadius = 5
        nextButtonOutlet.layer.shadowOpacity = 0.6
    }
    
    private func setupAnswersButton(){
        for item in 0...3 {
            answers[item].layer.cornerRadius = 20
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

        var haveToStudy: Bool = false
        for item in 0..<words2.count {
            if words2[item].progress < 10 {
                haveToStudy = true
            }
        }
        print(haveToStudy)
        if haveToStudy {
            setupTextField()
            resultLabel.text = ""
            setupNextButton()
            setupAnswersButton()
            wordLabel.isHidden = false
            nextButtonOutlet.isHidden = false
            voiceOutlet.isHidden = false
            wordForStudy()
        } else {
            resultLabel.text = "Нет слов для изучения"
            for item in 0...3 {
                answers[item].isHidden = true
            }
            wordLabel.isHidden = true
            outlletTextField.isHidden = true
            nextButtonOutlet.isHidden = true
            voiceOutlet.isHidden = true
        }
    }
}

extension LearnViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        spellCheck()
        nextButtonOutlet.backgroundColor = .green
        return true
    }
}
