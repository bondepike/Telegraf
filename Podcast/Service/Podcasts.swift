//
//  Podcasts.swift
//  Podcast
//
//  Created by Adrian Evensen on 25/11/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

struct PodcastsDataSource {
    var name: String?
    var feed: String?
    var artist: String?
    var artwork: String?
    var podcast: Podcast?
}

class Podcasts {
    static let shared = Podcasts()
    
    var current: PodcastsDataSource?
    
    
}

//MARK:- Set
extension Podcasts {
    
    func set(podcast: Podcast) {
        self.current = PodcastsDataSource(name: podcast.name, feed: podcast.feed, artist: podcast.artist, artwork: nil, podcast: podcast)
    }
    
    func set(podcast: PodcastModel) {
        self.current = PodcastsDataSource(name: podcast.trackName, feed: podcast.feedUrl, artist: podcast.artistName, artwork: podcast.artworkUrl600, podcast: nil)
        
    }
}
