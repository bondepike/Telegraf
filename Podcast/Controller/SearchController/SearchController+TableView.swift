//
//  SearchController+TableView.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 10/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

extension SearchController {
    
    //MARK:- Table View stuff
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let podcastModel = self.podcastModels?[indexPath.row] else { return }
        let podcastController = setupPodcastController(with: podcastModel)
        
        // Er abonnent på Podcasten fra før
        let cell = tableView.cellForRow(at: indexPath) as? SearchCell
        if let podcast = cell?.podcast {
            podcastController.podcast = podcast
            podcastController.index = 0
            podcastController.headerView.segmentedController.selectedSegmentIndex = 0
            podcastController.headerView.settingsButton.isHidden = false
        }
        
        //podcastController.image = cell?.podcastImageView.image
        podcastController.headerView.podcastImageView.image = cell?.podcastImageView.image
        navigationController?.pushViewController(podcastController, animated: true)
    }
    
    func setupPodcastController(with podcastModel: PodcastModel) -> PodcastController {
        let podcastController = PodcastController()
        podcastController.headerView.subscriptionChangesDelegate = self
        podcastController.podcastModel = podcastModel
        
        podcastController.index = 1
        podcastController.headerView.segmentedController.selectedSegmentIndex = 1
        podcastController.headerView.settingsButton.isHidden = true
        
        return podcastController
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let statusText = UILabel()
        statusText.text = "Search for a podcast"
        statusText.textColor = .darkGray
        statusText.textAlignment = .center
        
        return statusText
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let podcasts = podcastModels else { return 250 }
        return podcasts.count > 0 ? 0 : 250
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SearchCell()
        
        guard let podcastModel = podcastModels?[indexPath.row] else { return cell }
        cell.indexPath = indexPath
        cell.podcastModel = podcastModel
        
        podcasts?.forEach({ (podcast) in
            if podcast.name == podcastModel.trackName {
                cell.podcast = podcast
            }
        })
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastModels?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    
    
}


