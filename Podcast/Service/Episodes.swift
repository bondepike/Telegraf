//
//  Podcasts.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/11/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

struct EpisodeDataSource {
    var name: String?
    var artist: String?
    var subtitle: String?
    var episodeUrl: String?
    var artworkUrl: String?
    var releaseDate: Date?
    var length: Double?
    var description: String?
}

class Episodes {
    
    var episodes = [EpisodeDataSource]()
    
    fileprivate var internetEpisodes = [EpisodeDataSource]()
    
    static let shared = Episodes()
    
    init() {
        setupObservers()
    }
    
    deinit {
        print(":((((((((((((((")
    }

}

extension Episodes {
    func set(podcast: Podcast) {
        guard let local = podcast.episodes?.allObjects as? [Episode] else { return }
        
        local.forEach { (ep) in
            episodes.append(EpisodeDataSource(name: ep.name, artist: ep.artist, subtitle: ep.subtitle, episodeUrl: ep.internetEpisodeURL, artworkUrl: ep.artwork, releaseDate: ep.releaseDate, length: ep.timeLength, description: ep.description))
        }
    }
    
    func set(url: URL, completionHandler: @escaping () -> ()) {
        NetworkAPI.shared.fetchEpisodesFeed(feedURL: url) { (feed) in
            var ie = [EpisodeDataSource]()
            
            feed.items?.forEach({ (item) in
                
                let episode = EpisodeDataSource(name: item.title,
                                                artist: item.author,
                                                subtitle: item.iTunes?.iTunesSubtitle ?? item.iTunes?.iTunesSummary,
                                                episodeUrl: item.enclosure?.attributes?.url,
                                                artworkUrl: item.iTunes?.iTunesImage?.attributes?.href,
                                                releaseDate: item.pubDate,
                                                length: Double(item.enclosure?.attributes?.length ?? 0),
                                                description: item.description)
                ie.append(episode)
            })
            
            self.episodes = ie
            completionHandler()
        }
    }
}

extension Episodes {
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .handleDownloadProgress, object: nil)
    }
    
    @objc fileprivate func handleDownloadProgress() {
        print("ieh")
    }
    
    
    
}
