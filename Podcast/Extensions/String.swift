//
//  String.swift
//  Podcast
//
//  Created by Adrian Evensen on 28/08/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit


extension String {
    func parseHtmlToAttributedString() -> NSAttributedString {
        
        var someText = self
        someText += "<style>text-color: white;</style>"
        
        guard let data = someText.data(using: .unicode) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.unicode.rawValue], documentAttributes: nil)
        } catch let error {
            print(error)
            return NSAttributedString()
        }
    }
}


