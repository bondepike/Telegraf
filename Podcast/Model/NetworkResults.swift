//
//  NetworkResults.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    var resultCount: Int
    var results: [PodcastModel]?

}
struct TrendingPodcastsResult: Decodable {
    var feed: Feed?
}

struct Feed: Decodable {
    var updated: String?
    var results: [TrendingPodcast]?
}

struct TrendingPodcast: Decodable {
    var artistName: String?
    var name: String?
    var artworkUrl100: String?
    var genres: [PodcastGenres]?
    var url: String?
}

struct PodcastGenres: Decodable {
    var genreId: String?
    var name: String?
    var url: String?
}

