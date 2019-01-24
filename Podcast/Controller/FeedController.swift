//
//  Feed.swift
//  Podcast
//
//  Created by Adrian Evensen on 15/01/2019.
//  Copyright © 2019 AdrianF. All rights reserved.
//

import UIKit

class FeedController: UITableViewController {
    
    var feed = [FeedEpisode]()
    
    var episodeDataSource: [EpisodeDataSource]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        title = "Feed"
        tableView.addSubview(refresher)
        refresher.addTarget(self, action: #selector(fetchFeed), for: .valueChanged)
        tableView.register(FeedEpisodeCell.self, forCellReuseIdentifier: "cellid")
        fetchFeed()
    }
    
    @objc func fetchFeed() {
        refresher.beginRefreshing()
        var datasource = [EpisodeDataSource]()
        NetworkAPI.shared.fetchFeed { (feed) in
            for f in feed {
                let podcast = CoreDataManager.shared.fetchPodcast(name: f.Podcast ?? "")
                let ds = EpisodeDataSource(name: f.Name,
                                           artist: nil,
                                           description: nil,
                                           episodeUrl: nil,
                                           artworkUrl: nil,
                                           releaseDate: nil,
                                           length: nil,
                                           subtitle: nil,
                                           inHistory: self.inHistory(named: f.Name ?? "", from: podcast?.first),
                                           episode: self.getEpisode(named: f.Name ?? "", from: podcast?.first),
                                           podcast: podcast?.first)
                datasource.append(ds)
            }
            
            DispatchQueue.main.async {
                self.episodeDataSource = datasource
                self.refresher.endRefreshing()
            }
        }
    }
    
    func getEpisode(named: String, from podcast: Podcast?) -> Episode? {
        if let episodes = podcast?.episodes?.allObjects as? [Episode] {
            let ep = episodes.first(where: { (ep) -> Bool in
                ep.name == named
            })
            return ep
        }
        return nil
    }
    
    func inHistory(named: String, from podcast: Podcast?) -> Bool {
        guard let history = podcast?.history?.allObjects as? [History] else { return false }
        return history.contains { (h) -> Bool in
            return h.name == named
        }
    }
    
}

extension FeedController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! FeedEpisodeCell
        cell.episodeTitle.text = episodeDataSource?[indexPath.row].name
        if let artwork = episodeDataSource?[indexPath.row].podcast?.artwork {
            cell.podcastImage.image = UIImage(data: artwork)
        }
        if episodeDataSource?[indexPath.row].inHistory ?? false {
            //cell.backgroundColor = .blue
        }
        cell.episodeDataSource = episodeDataSource?[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let episode = episodeDataSource?[indexPath.row].episode {
            NotificationCenter.default.post(name: .playNewEpisode, object: episode)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeDataSource?.count ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
