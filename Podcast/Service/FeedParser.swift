//
//  FeedParser.swift
//  Podcast
//
//  Created by Adrian Evensen on 27/11/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

struct ParserFeed {
    var title: String?
    var episodes: [EpisodeDataSource]?
}

class Parser: NSObject {
    
    var podcastTitle = ""
    var episodes = [EpisodeDataSource]()
    var completionHandler: (([EpisodeDataSource]) -> ())?
    
    var dictionary = [String: String]()
    
    private var currentElement = ""
    private var didEncounterItem = false
    
}
extension Parser: XMLParserDelegate {
    
    fileprivate enum RSS: String {
        case item = "item"
        case title = "title"
        case description = "description"
        case enclosure = "enclosure"
        case subtitle = "itunes:subtitle"
        case pubDate = "pubDate"
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        switch elementName {
        case RSS.item.rawValue:
            dictionary = [String: String]()
            
        case RSS.enclosure.rawValue:
            guard let url = attributeDict["url"] else { return }
            dictionary["url"] = url

        default: break
        }
    }
    
    //MARK:- CDATA
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard didEncounterItem else { return }
        let string = String(bytes: CDATABlock, encoding: .utf8)
        switch currentElement {
        case "itunes:summary":
            dictionary[RSS.subtitle.rawValue] = string
            break
        default:
            dictionary[currentElement] = string
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var newCharacters = string
        newCharacters = newCharacters.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var element = currentElement
        switch currentElement {
        case "itunes:summary":
            element = RSS.subtitle.rawValue
            break
        default: break
        }
        
        if let c = dictionary[element] {
            dictionary[element] = c + newCharacters
        } else {
            dictionary[element] = newCharacters
        }
       
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let ltitle = dictionary["title"] else { return }
        let podcastTitle = Podcasts.shared.current?.name ?? ""
        switch elementName {
        case RSS.title.rawValue:
            if !didEncounterItem {
                didEncounterItem = true
            } else {
                if ltitle.starts(with: podcastTitle) {
                    dictionary["title"] = ltitle.replacingOccurrences(of: "\(podcastTitle) ", with: "")
                }
            }
            break
            
        case RSS.item.rawValue:
            var newEpisode = EpisodeDataSource(name: dictionary["title"],
                                               artist: dictionary["artist"],
                                               description: dictionary["description"],
                                               episodeUrl: dictionary["url"],
                                               artworkUrl: nil,
                                               releaseDate: nil,
                                               length: nil,
                                               subtitle:  dictionary["itunes:subtitle"],
                                               inHistory: false,
                                               episode: nil,
                                               podcast: nil)
            newEpisode.releaseDate = parse(date: dictionary["pubDate"])
            newEpisode.inHistory = findInHistory()
            episodes.append(newEpisode)
            break
            
        default: break
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        episodes = [EpisodeDataSource]()
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?(episodes)
    }
    
    func parse(date string: String?) -> Date? {
        guard let string = string else { return nil }
        let dateFormats = [
            "EEE, d MMM yyyy HH:mm:ss zzz",
            "EEE, d MMM yyyy HH:mm zzz",
            "d MMM yyyy HH:mm:ss Z"
        ]
        
        let formatter = DateFormatter()
        
        for format in dateFormats {
            formatter.dateFormat = format
            if let formattedDate = formatter.date(from: string) {
                return formattedDate
            }
        }

        return nil
    }
    
    func findInHistory() -> Bool {
        guard let podcast = Podcasts.shared.current?.podcast,
            let history = podcast.history?.allObjects as? [History] else { return false }
        
        for h in history {
            if h.name == dictionary["title"] {
                return true
            }
        }
        
        return false
    }
    
}

extension Parser {
    func parse(url: URL, completion: @escaping ([EpisodeDataSource]) -> ()) {
        self.completionHandler = completion
        
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if err != nil {
                print("Failed to fetch feed: ", err as Any)
                return
            }
            
            guard let data = data else { return }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
            
            }.resume()
    }
}

