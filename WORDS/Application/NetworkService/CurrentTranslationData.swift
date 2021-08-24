//
//  CurrentTranslationData.swift
//  WORDS
//
//  Created by Илья Холопов on 06.06.2021.
//

import Foundation

struct CurrentTranslationData: Decodable {
    let def: [def]
}

struct def: Decodable {
    let tr: [tr]
}

struct tr: Decodable {
    let text: String
}
