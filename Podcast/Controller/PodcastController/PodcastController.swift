//
//  EpisodesTableController.swift
//  Podcast
//
//  Created by Adrian Evensen on 19/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class PodcastController: UITableViewController, PodcastHeaderViewDelegate {

    var image: UIImage?
    var podcastTitle: String?
    var artistNames: String?
    var refreshing = false
    var index = 0
    var subscriptionChangesDelegate: SubscriptionChangesDelegate?
    
    //caches
    var internetEpisodes: [EpisodeModel]?
    var localEpisodes: [Episode]?
    
    //required data to
    var podcastModel: PodcastModel?
    weak var podcast: Podcast?
    
    //MARK:- Header
    lazy var headerView: PodcastHeaderView = {
        let view = PodcastHeaderView()
        view.podcastImageView.image = image
        view.segmentedController.selectedSegmentIndex = index
        view.subscriptionChangesDelegate = subscriptionChangesDelegate
        view.delegate = self
        
        return view
    }()
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false) // BUG FIX: navigation bar forsvinner
        
        tableView.register(EpisodesCell.self, forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView()
        tableView.contentInset.bottom = 64
        
        setupHeaderView()
        segmentedControllerUpdatedIndex(index: self.index)
    }
    

    
    //MARK:- EpisodesHeaderDelegate
    func didSubscribeToNew(podcast: Podcast?) {
        self.podcast = podcast
        self.localEpisodes = podcast?.episodes?.allObjects as? [Episode]
        
        subscriptionChangesDelegate?.subscribedToNew(podcast: podcast)
    }
    
    func didTapSettings() {
        let podcastSettings = UIAlertController(title: "Settings", message: "Only this podcast will be affected", preferredStyle: .actionSheet)
            
        podcastSettings.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] (_) in
            guard let podcast = self.podcast else { return }
            CoreDataManager.shared.deletePodcast(podcast: podcast, completionHandler: { [unowned self] in
                self.subscriptionChangesDelegate?.deletedPodcast()
                self.navigationController?.popViewController(animated: true)
                self.minimizePlayerView()
            })
        }))
        
        podcastSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
            self.minimizePlayerView()
        }))
        
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let homeController = navigationController?.viewControllers[0] as? SubscriptionsController
        homeController?.dissapearPlayerView()
        
        present(podcastSettings, animated: true, completion: nil)
    }
    
    func segmentedControllerUpdatedIndex(index: Int) {
        self.index = index
        switch index {
        case 0:
            fetchLocalEpisodes()
            break
            
        case 1:
            if let podcast = podcast {
                fetchEpisodesFromInternet(feed: podcast.feed)
                break
            }
            fetchEpisodesFromInternet(feed: podcastModel?.feedUrl)
            break
            
        default:
            break
        }
    }
    
    //MARK:- Helper Functions
    fileprivate func fetchLocalEpisodes() {
        sortLocalEpisodes()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func minimizePlayerView() {
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let homeController = navigationController?.viewControllers[0] as? SubscriptionsController
        guard homeController?.playerView.episode != nil else { return }
        homeController?.minimizePlayerView()
    }
    
    func sortLocalEpisodes() {
        var fetchedLocalEpisodes = podcast?.episodes?.allObjects as? [Episode]
        fetchedLocalEpisodes = fetchedLocalEpisodes?.sorted(by: { (ep1, ep2) -> Bool in
            guard let ep1 = ep1.releaseDate, let ep2 = ep2.releaseDate else { return false }
            return ep1 > ep2
        })
        self.localEpisodes = fetchedLocalEpisodes
    }
    
    //MARK:- Setup
    func setupHeaderView() {
        tableView.tableHeaderView = headerView
        headerView.frame =  CGRect(x: 0, y: 0, width: view.frame.width, height: 294)
        //headerView.delegate = self
        if let _ = podcast {
            headerView.podcast = self.podcast
        } else {
            headerView.podcastModel = self.podcastModel
        }
    }
}

extension PodcastController: EpisoceCellDelegate {
    func didLongPress(episode: Episode?, internetEpisode: EpisodeModel?) {
        let vc = ShowNotesController()        
        if let le = episode {
            vc.episode = le
        } else if let ie = internetEpisode {
            vc.internetEpisode = ie
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
