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
    
    var episodeUrl = "" {
        didSet {
            episodeUrl = episodeUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var title: String = "" {
        didSet {
            title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var episodeDescription: String = "" {
        didSet {
            episodeDescription = episodeDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    
    private var subtitle: String = "" {
        didSet {
            subtitle = subtitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private var pubDate: String = "" {
        didSet {
            pubDate = pubDate.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
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
            title = ""
            
        case RSS.description.rawValue:
            episodeDescription = ""
            
        case RSS.enclosure.rawValue:
            guard let url = attributeDict["url"] else { return }
            episodeUrl = url
        
        case RSS.subtitle.rawValue:
            subtitle = ""
        
        case RSS.pubDate.rawValue:
            pubDate = ""
            
            
        default: break
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case RSS.title.rawValue:
            title += string
            break
            
        case RSS.description.rawValue:
            episodeDescription += string
            break
            
        case RSS.subtitle.rawValue:
            subtitle += string
            break
            
        case RSS.pubDate.rawValue:
            pubDate += string
            break
            
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName {
        case RSS.title.rawValue:
            if !didEncounterItem {
                podcastTitle = title
                didEncounterItem = true
            } else {
                if title.starts(with: podcastTitle) {
                    title = title.replacingOccurrences(of: "\(podcastTitle) ", with: "")
                }
            }
            break
            
        case RSS.item.rawValue:
            var newEpisode = EpisodeDataSource(name: title, artist: nil, description: episodeDescription, episodeUrl: episodeUrl, artworkUrl: nil, releaseDate: nil, length: nil, subtitle: subtitle, inHistory: false, episode: nil)

            newEpisode.releaseDate = parse(date: pubDate)

            if let podcast = Podcasts.shared.current?.podcast {
                let history = podcast.history?.allObjects as? [History]
                history?.forEach({ (h) in
                    if h.name == newEpisode.name {
                        newEpisode.inHistory = true
                    }
                })
            }
            
            episodes.append(newEpisode)
            break
        default: break
        }
        
        if elementName == RSS.item.rawValue {
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        episodes = [EpisodeDataSource]()
        title = ""
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        completionHandler?(episodes)
    }
    
    func parse(date string: String) -> Date? {
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

