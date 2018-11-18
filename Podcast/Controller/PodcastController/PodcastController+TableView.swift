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
        return Episodes.shared.episodes.count
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = EpisodesCell()
        cell.episodeCellDelegate = self
        cell.episodeDataSource = Episodes.shared.episodes[indexPath.row]
        
        return cell
    }
//
//    //MARK:- Actions
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
//        guard let _ = cell?.localEpisode else { return false }
//        return true
//    }
//
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
//        guard let episode = cell?.localEpisode else { return nil }
//
//        let removeAction = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] (_, indexPath) in
//            CoreDataManager.shared.deleteDownloadedEpisode(episode: episode, completionHandler: {
//                if self.index == 0 {
//                    self.localEpisodes?.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .left)
//                } else {
//                    /*
//                        Finer index til episoden i både localEpisodes og internetEpisodes array
//                        og sletter de før den oppdaterer tableView med delte animation
//                    */
//                    guard let index = self.localEpisodes?.index(of: episode) else { return }
//                    self.localEpisodes?.remove(at: index)
//
//                    guard let newIndex = self.internetEpisodes?.index(where: { (episodeModel) -> Bool in
//                        return cell?.internetEpisode?.name == episodeModel.name
//                    }) else { return }
//
//                    self.internetEpisodes?.remove(at: newIndex)
//
//                    tableView.deleteRows(at: [indexPath], with: .left)
//                }
//
//            })
//            self.sortLocalEpisodes()
//        }
//        return [ removeAction ]
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.isSelected = false
//
//        if index == 0 {
//            let pointer = tableView.cellForRow(at: indexPath) as? EpisodesCell
//            if let episode = pointer?.localEpisode {
//                NotificationCenter.default.post(name: .playNewEpisode, object: episode)
//            }
//        }
//        
//        if index == 1 {
//            let pointer = tableView.cellForRow(at: indexPath) as? EpisodesCell
//            pointer?.doneLabel.isHidden = true
//            if let episode = pointer?.localEpisode {
//                NotificationCenter.default.post(name: .playNewEpisode, object: episode)
//            } else {
//                guard let podcast = self.podcast else { return }
//                guard let episodeModel = self.internetEpisodes?[indexPath.row] else { return }
//                guard let episodeUrl = episodeModel.episodeUrl else { return }
//               
//                guard let lastPathComponent = URL(string: episodeUrl)?.lastPathComponent else { return }
//                let cell = tableView.cellForRow(at: indexPath) as? EpisodesCell
//                cell?.isUserInteractionEnabled = false
//                
//                CoreDataManager.shared.saveNewLocalEpisode(podcast: podcast, episodeModel: episodeModel, lastPathComponent: lastPathComponent, completionHandler: { episode in
//                                        
//                    cell?.localEpisode = episode
//                    
//                    NotificationCenter.default.post(name: .handleDownloadStarted, object: nil, userInfo: ["title":episode.name ?? ""])
//                    
//                    NetworkAPI.shared.downloadEpisode(episode: episode, episodeModel: episodeModel, completionHandler: {
//                        
//                        guard var trueFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//                        trueFileUrl.appendPathComponent(episode.lastLocalPathCompoenent ?? "")
//                        
//                        let asset = AVURLAsset(url: trueFileUrl)
//                        let assetDuration = asset.duration
//                        let assetDurationSeconds = CMTimeGetSeconds(assetDuration)
//                        
//                        CoreDataManager.shared.updateEpisodeLength(episode: episode, length: assetDurationSeconds)
//                        NotificationCenter.default.post(name: .handleDownloadFinished, object: nil, userInfo: ["title":episode.name ?? ""])
//                        self.sortLocalEpisodes()
//                    })
//                })
//            }
//        }
//        
//    }
    
    

}
