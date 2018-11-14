//
//  PodcastController+Helper.swift
//  Podcast
//
//  Created by Adrian Evensen on 19/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit


extension PodcastController {
    
    ///Henter episodene fra podcast sin feedUrl.
    func fetchEpisodesFromInternet(feed: String?) {
        
        if self.internetEpisodes != nil {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            return
        }
     
        // Vis loading greie
        self.refreshing = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        guard let feedUrl = feed else { return }
        guard let url = URL(string: feedUrl) else { return }
        
        NetworkAPI.shared.fetchEpisodesFeed(feedURL: url) { (feed) in
            var episodes = [EpisodeModel]()
            
            feed.items?.forEach({ (item) in
                let episode = EpisodeModel(name: item.title,
                                           artist: item.author,
                                           subtitle: item.iTunes?.iTunesSubtitle ?? item.iTunes?.iTunesSummary,
                                           episodeUrl: item.enclosure?.attributes?.url,
                                           artworkUrl: item.iTunes?.iTunesImage?.attributes?.href,
                                           pubDate: item.pubDate,
                                           length: Double(item.enclosure?.attributes?.length ?? 0),
                                           description: item.description,
                                           content: item.content?.contentEncoded)
                

                episodes.append(episode)
            })
            
            self.internetEpisodes = episodes
            DispatchQueue.main.async {
                self.refreshing = false
                self.tableView?.reloadData()
            }            
        }
    }
}
