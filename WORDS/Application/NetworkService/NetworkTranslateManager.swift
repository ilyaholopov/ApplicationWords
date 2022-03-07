//
//  NetworkTranslateManager.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import Foundation
import UIKit


class NetworkTranslateManager {
    
    var activityView: UIActivityIndicatorView?
    private var urlComponents = URLComponents()
    
    func fetchCurrentTranslation(for languages: String, forWord word: String, completionHandler: @escaping (CurrentWord) -> Void)  {
//        let urlString = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup?key=\(apiKey)&lang=\(languages)&text=\(word)"
        setupURLComponents(searchText: word, languages: languages)
        //guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        print("Слово для перевода: \(word)")
        print("С какого на какой: \(languages)")
        print("\(urlComponents.url!)")
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: urlComponents.url!) { data, response, error in
            if let data = data {
                if let answer = self.parseJSON(withData: data) {
                    completionHandler(answer)
                }
            }
            semaphore.signal()
        }
        task.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
    }
    
    func parseJSON(withData data: Data) -> CurrentWord? {
        let decoder = JSONDecoder()
        do {
            let currentTranslationData = try decoder.decode(CurrentTranslationData.self, from: data)
            guard let currentTranslation = CurrentWord(currentTranslationData: currentTranslationData) else { return nil}
            return currentTranslation
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return nil
    }
    
    private func setupURLComponents(searchText: String, languages: String){
        urlComponents.scheme = "https"
        urlComponents.host = "dictionary.yandex.net"
        urlComponents.path = "/api/v1/dicservice.json/lookup"
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "lang", value: languages),
            URLQueryItem(name: "text", value: searchText)
        ]
    }
    
}
