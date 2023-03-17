//
//  TextEditionAttributedStringContainer.swift
//  cdlztosqlite: generates a SQLite store from Oracc CDL ZIP archives
//  Copyright (C) 2023 Chaitanya Kanchan
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import CDKSwiftOracc

@available(macOS 12, *)
public struct TextEditionAttributedStringContainer {
    let cuneiform: String
    let transliteration: AttributedString
    let normalisation: AttributedString
    let translation: String
    
    public init(_ edition: OraccTextEdition) {
        self.cuneiform = edition.cuneiform
        self.transliteration = edition.transliteratedAttributedString()
        self.normalisation = edition.normalisedAttributedString()
        self.translation = edition.scrapeTranslation() ?? edition.literalTranslation
    }
}

extension TextEditionAttributedStringContainer: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cuneiform, forKey: .cuneiform)
        try container.encode(transliteration, forKey: .transliteration, configuration: CDLTextAttributes.self)
        try container.encode(normalisation, forKey: .normalisation, configuration: CDLTextAttributes.self)
        try container.encode(translation, forKey: .translation)
    }
}
