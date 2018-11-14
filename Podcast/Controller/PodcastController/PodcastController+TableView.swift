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
        guard section == 0 else { return 0 }
        
        if index == 0 {
            guard let localEpisodes = localEpisodes else { return 0 }
            return localEpisodes.count
            
        }
        guard let internetEpisodes = internetEpisodes else { return 0 }
        return internetEpisodes.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EpisodesCell()
        cell.episodeCellDelegate = self

        //Local
        if index == 0 {
            guard let localEpisodes = localEpisodes else { return cell }
            cell.localEpisode = localEpisodes[indexPath.row]
        }
        
        //Internet
        if index == 1 {
            guard var internetEpisodes = internetEpisodes else { return cell }
            
//            // Formaterer vekk Podcast navn fra Episode tittel
//            if let episodeTitle = internetEpisodes[indexPath.row].name, let podcastName = podcast?.name {
//                let episodeTitleFormatted = episodeTitle.replacingOccurrences(of: podcastName, with: "")
//                internetEpisodes[indexPath.row].name = episodeTitleFormatted
//                self.internetEpisodes?[indexPath.row].name = episodeTitleFormatted
//            }
            cell.internetEpisode = internetEpisodes[indexPath.row]
            cell.podcast = self.podcast
            
            
            // Episoden er lagret i Core Data
            if let localEpisodes = localEpisodes {
                localEpisodes.forEach({ (localEpisode) in
                    if internetEpisodes[indexPath.row].name == localEpisode.name {
                        cell.localEpisode = localEpisode
                    }
                })
            }
        }
        
        return cell
    }
    
    //MARK:- Actions
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
        guard let _ = cell?.localEpisode else { return false }
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
        guard let episode = cell?.localEpisode else { return nil }
        
        let removeAction = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
            CoreDataManager.shared.deleteDownloadedEpisode(episode: episode, completionHandler: {
                if self.index == 0 {
                    self.localEpisodes?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                } else {
                    /*
                        Finer index til episoden i både localEpisodes og internetEpisodes array
                        og sletter de før den oppdaterer tableView med delte animation
                    */
                    guard let index = self.localEpisodes?.index(of: episode) else { return }
                    self.localEpisodes?.remove(at: index)
                    
                    guard let newIndex = self.internetEpisodes?.index(where: { (episodeModel) -> Bool in
                        return cell?.internetEpisode?.name == episodeModel.name
                    }) else { return }
                    
                    self.internetEpisodes?.remove(at: newIndex)
                    
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
                
            })
            self.sortLocalEpisodes()
        }
        return [ removeAction ]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if index == 0 {
            let pointer = tableView.cellForRow(at: indexPath) as? EpisodesCell
            if let episode = pointer?.localEpisode {
                //playNewEpisode(episode: episode)
                NotificationCenter.default.post(name: .playNewEpisode, object: episode)
            }
        }
        
        if index == 1 {
            let pointer = tableView.cellForRow(at: indexPath) as? EpisodesCell
            pointer?.doneLabel.isHidden = true
            if let episode = pointer?.localEpisode {
                NotificationCenter.default.post(name: .playNewEpisode, object: episode)
            } else {
                guard let podcast = self.podcast else { return }
                guard let episodeModel = self.internetEpisodes?[indexPath.row] else { return }
                guard let episodeUrl = episodeModel.episodeUrl else { return }
               
                guard let lastPathComponent = URL(string: episodeUrl)?.lastPathComponent else { return }
                let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
                cell?.isUserInteractionEnabled = false
                
                CoreDataManager.shared.saveNewLocalEpisode(podcast: podcast, episodeModel: episodeModel, lastPathComponent: lastPathComponent, completionHandler: { episode in
                                        
                    cell?.localEpisode = episode
                    
                    NotificationCenter.default.post(name: .handleDownloadStarted, object: nil, userInfo: ["title":episode.name ?? ""])
                    
                    NetworkAPI.shared.downloadEpisode(episode: episode, episodeModel: episodeModel, completionHandler: {
                        
                        guard var trueFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
                        trueFileUrl.appendPathComponent(episode.lastLocalPathCompoenent ?? "")
                        
                        let asset = AVURLAsset(url: trueFileUrl)
                        let assetDuration = asset.duration
                        let assetDurationSeconds = CMTimeGetSeconds(assetDuration)
                        
                        CoreDataManager.shared.updateEpisodeLength(episode: episode, length: assetDurationSeconds)
                        NotificationCenter.default.post(name: .handleDownloadFinished, object: nil, userInfo: ["title":episode.name ?? ""])
                        self.sortLocalEpisodes()
                    })
                })
            }
        }
        
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    

}


extension PodcastController {
    
    func playNewEpisode(episode: Episode) {
        
        NotificationCenter.default.post(name: .playNewEpisode, object: episode)
        let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let homeController = navController?.viewControllers[0] as? SubscriptionsController
        let playerView = homeController?.playerView
        
        playerView?.episode = episode
        //playerView?.podcast = podcast
        playerView?.episodeImage = image
        
        playerView?.playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        playerView?.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        homeController?.minimizePlayerView()
        
    }
    
}
