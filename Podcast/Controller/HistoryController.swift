//
//  HistoryController.swift
//  Podcast
//
//  Created by Adrian Evensen on 22/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class HistoryController: UITableViewController {
    
    var episodes: [Episode]? {
        didSet {
            episodes?.sort(by: { (firstEp, prevEp) -> Bool in
                guard let firstDate = firstEp.releaseDate, let prevDate = prevEp.releaseDate else { return false}
                return firstDate > prevDate
            })
            
            episodes?.sort(by: { (firstEp, prevEp) -> Bool in
                guard let firstDate = firstEp.addedDate, let prevDate = prevEp.addedDate else { return false }
                return firstDate > prevDate
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "cellId")
        fetchEpisodes()
        setupUI()
        tableView.separatorColor = .clear
    }
    
    fileprivate func setupUI() {
        tableView.tableFooterView = UIView()
        title = "History"
    }
    
    fileprivate func fetchEpisodes() {
        CoreDataManager.shared.fetchAllEpisodes { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        
        //TODO: Refactor dette
        let homeController = navController?.viewControllers[0] as? SubscriptionsController
        
        let playerView = homeController?.playerView
        
        let episode = episodes?[indexPath.row]
        
        let cellPointer = tableView.cellForRow(at: indexPath) as? HistoryCell
        
        playerView?.episode = episode
        //playerView?.podcast = episode?.podcast
        playerView?.episodeImage = cellPointer?.podcastImage.image
        playerView?.playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        playerView?.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        homeController?.minimizePlayerView()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! HistoryCell
        
        cell.episode = episodes?[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            
            guard let episode = self.episodes?[indexPath.row] else { return }

            print("Trying to delete ", episode.name ?? "")
        
            CoreDataManager.shared.deleteDownloadedEpisode(episode: episode, completionHandler: {
                self.episodes?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
        
        return [deleteAction]
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
