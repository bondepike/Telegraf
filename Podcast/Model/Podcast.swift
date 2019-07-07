//
//  Podcast.swift
//  Podcast
//
//  Created by Adrian Evensen on 20/02/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

struct PodcastModel: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var feedUrl: String?
}

