//
//  PodcastController+TableView.swift
//  Podcast
//
//  Created by Adrian Evensen on 24/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import AVFoundation

extension PodcastController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK:- Footer
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.color = UIColor.kindaBlack
        activityIndicator.startAnimating()
        
        return activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }
        if self.refreshing {
            return 70
        }
        return 0
    }
    
    //MARK:- Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if refreshing {
            return 0
        }
        return Episodes.shared.episodes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EpisodeCell()
        //cell.podcast = podcast
        cell.episodeDataSource = Episodes.shared.episodes[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? EpisodeCell
        return cell?.episodeDataSource?.episode != nil
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        guard let episode = Episodes.shared.episodes[indexPath.row].episode else { return nil }
        guard let podcast = Podcasts.shared.current?.podcast else { return nil }
        
        let removeAction = UITableViewRowAction(style: .destructive, title: "delete") { (_, indexPath) in
            CoreDataManager.shared.saveToHistory(podcast, episode: episode)
            CoreDataManager.shared.deleteDownloadedEpisode(episode: episode, completionHandler: {
                Episodes.shared.episodes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
        
        return [removeAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EpisodeCell else { return }
        
        if let episode = cell.episodeDataSource?.episode {
            NotificationCenter.default.post(name: .playNewEpisode, object: episode)
        } else if let episodeDataSource = cell.episodeDataSource {
            downloadEpisode(episodeDataSource: episodeDataSource)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate func downloadEpisode(episodeDataSource: EpisodeDataSource) {
        guard let podcast = Podcasts.shared.current?.podcast else { return }
        Episodes.shared.new(episode: episodeDataSource, for: podcast)
    }

}
