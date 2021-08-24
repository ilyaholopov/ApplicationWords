//
//  CurrentWord.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import Foundation

struct CurrentWord {
    let translation: String
    
    init?(currentTranslationData: CurrentTranslationData) {
        translation = currentTranslationData.def[0].tr[0].text
    }
}
