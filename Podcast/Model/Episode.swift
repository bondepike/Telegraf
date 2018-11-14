//
//  Episode.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit


struct EpisodeModel: Decodable {

    var name: String?
    var artist: String?
    var subtitle: String?
    var episodeUrl: String?
    var artworkUrl: String?
    var pubDate: Date?
    var length: Double?
    var description: String?
    var content: String?
}

