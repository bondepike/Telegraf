//
//  Date.swift
//  Podcast
//
//  Created by Adrian Evensen on 26/01/2019.
//  Copyright © 2019 AdrianF. All rights reserved.
//

import Foundation


extension String {
    
    ///Tries to parse string to date, with formats often found in RSS feeds.
    func parseRSSDate() -> Date? {
        //guard let string = string else { return nil }
        let dateFormats = [
            "EEE, d MMM yyyy HH:mm:ss zzz",
            "EEE, d MMM yyyy HH:mm zzz",
            "d MMM yyyy HH:mm:ss Z"
        ]
        let formatter = DateFormatter()
        for format in dateFormats {
            formatter.dateFormat = format
            if let formattedDate = formatter.date(from: self) {
                return formattedDate
            }
        }
        
        return nil
    }
}


extension Date {
    func feedString() -> String {
        let formatter = DateFormatter()
        let hoursSinceRelease = Date().timeIntervalSince(self) / 3600
        
        if hoursSinceRelease < 24 {
            return "Today"
            
        } else if hoursSinceRelease < 48 {
            return "Yesterday"
            
        } else if hoursSinceRelease < 168 {
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "en_GB")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            return "\(formatter.string(from: self))  (\(Int(hoursSinceRelease / 24)) days ago)"
        }
        
        formatter.dateFormat = "dd MMM YYYY"
        return "\(formatter.string(from: self))"
    }
}
