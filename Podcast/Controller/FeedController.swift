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
    
    var episodeDataSource: [[EpisodeDataSource]]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(fetchFeed), for: .valueChanged)
        return refresher
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Week"
        view.backgroundColor = .white
        tableView.refreshControl = refresher
        tableView.register(FeedEpisodeCell.self, forCellReuseIdentifier: "cellid")
        tableView.tableFooterView = UIView()
        fetchFeed()
    }
    
}

// MARK:- Fetching feed
extension FeedController {
    @objc func fetchFeed() {
        refresher.beginRefreshing()
        var datasource = [[EpisodeDataSource]]()
        NetworkAPI.shared.fetchFeed { (feed) in
            
            
            feed.forEach({ (day) in
                var dayDataSource = [EpisodeDataSource]()
                for f in day {
                    let podcast = CoreDataManager.shared.fetchPodcast(name: f.Podcast ?? "")
                    let ds = EpisodeDataSource(name: f.Name,
                                               artist: nil,
                                               description: nil,
                                               episodeUrl: nil,
                                               artworkUrl: nil,
                                               releaseDate: f.PubDate?.parseRSSDate(),
                                               length: nil,
                                               subtitle: nil,
                                               inHistory: self.inHistory(named: f.Name ?? "", from: podcast?.first),
                                               episode: self.getEpisode(named: f.Name ?? "", from: podcast?.first),
                                               podcast: podcast?.first)
                    
                    dayDataSource.append(ds)
                }
                datasource.append(dayDataSource)
            })
            
            datasource.reverse()
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
        cell.episodeDataSource = episodeDataSource?[indexPath.section][indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let episode = episodeDataSource?[indexPath.section][indexPath.row].episode {
            NotificationCenter.default.post(name: .playNewEpisode, object: episode)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   override func numberOfSections(in tableView: UITableView) -> Int {
        return episodeDataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodeDataSource?[section].count ?? 0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = FeedHeaderLabel()
        
        guard let date = episodeDataSource?[section].first?.releaseDate else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"

        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_GB")

        headerView.text = formatter.string(from: date)
        
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        if calendar.isDateInToday(date) {
            headerView.text = "Today"
        } else if calendar.isDateInYesterday(date) {
            headerView.text = "Yesterday"
        }
                
        let containerView = UIView()
        containerView.addSubview(headerView)
        headerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        headerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        return containerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}
