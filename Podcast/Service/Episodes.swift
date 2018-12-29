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
    var description: String?
    var episodeUrl: String?
    var artworkUrl: String?
    var releaseDate: Date?
    var length: Double?
    var subtitle: String?
    
    var inHistory: Bool
    
    var episode: Episode?
}

class Episodes {
    
    var episodes = [EpisodeDataSource]()
    
    static let shared = Episodes()
    
    init() {
        setupObservers()
    }

}

extension Episodes {
    func new(episode: EpisodeDataSource, for podcast: Podcast) {
        let localEpisode =  CoreDataManager.shared.saveNewLocalEpisode(podcast: podcast, episode: episode)
        
        let index = episodes.firstIndex { (eds) -> Bool in
            return eds.name == localEpisode.name
        }
        
        if let index = index {
            episodes[index].episode = localEpisode
        }
        
        NetworkAPI.shared.downloadEpisode(episode: localEpisode, episodeModel: episode) {
        }
    }
}

extension Episodes {
    func set(podcast: Podcast) {
        episodes = [EpisodeDataSource]()
        guard var local = podcast.episodes?.allObjects as? [Episode] else { return }
        
        local.sort { (ep1, ep2) -> Bool in
            guard let rd1 = ep1.releaseDate, let rd2 = ep2.releaseDate else { return false}
            return rd1 > rd2
        }
        
        local.forEach { (ep) in
            episodes.append(EpisodeDataSource(name: ep.name, artist: ep.artist, description: ep.subtitle, episodeUrl: ep.internetEpisodeURL, artworkUrl: ep.artwork, releaseDate: ep.releaseDate, length: ep.timeLength, subtitle: ep.subtitle, inHistory: false, episode: ep))
        }
    }
    
    func set(url: URL, completionHandler: @escaping () -> ()) {
        Parser().parse(url: url) { (episodes) in
            var episodes = episodes
            
            for i in 0 ..< episodes.count {
                let local = self.episodes.first(where: { (ep) -> Bool in
                    return ep.name == episodes[i].name
                })
                episodes[i].episode = local?.episode
            }
            
            self.episodes = episodes
            completionHandler()
        }
    }
}

extension Episodes {
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .handleDownloadProgress, object: nil)
    }
    
    @objc fileprivate func handleDownloadProgress() {
        
    }
}
