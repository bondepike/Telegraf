//
//  searchController.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 2/20/18.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

protocol SearchControllerDelegate {
    func presentSearchController()
    func dismissSearchController()
}

class SearchController: UITableViewController {
    
    func deletedPodcast() {}
    var textCount = Int()
    var timer = Timer()
    
    var subscriptionChangesDelegate: SubscriptionChangesDelegate?
    var searchControllerDelegate: SearchControllerDelegate?
    var tabBarDelegate: UITabBarDelegate?
    
    var podcastModels: [PodcastModel]?
    var podcasts: [Podcast]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Search"
        setupUI()
        setupNavigtionItems()
        setupSearchController()
        setupObservers()
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.hidesBarsWhenKeyboardAppears = false
        
        searchiTunes(searchText: "NPR")
    }
    
    
    //MARK:- Setup
    fileprivate func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
    }
    
    fileprivate func setupNavigtionItems() {
        let customLinkButton = UIBarButtonItem(title: "Custom URL", style: .plain, target: self, action: #selector(handleCustomLink))

        navigationItem.rightBarButtonItem = customLinkButton
    }

    
    @objc fileprivate func handleCustomLink() {
        /*
        let popupController = UIAlertController(title: "Add a custom URL", message: "Type or paste the URL below", preferredStyle: .alert)
        popupController.addTextField { (textfield) in
        }
        
        popupController.addAction(UIAlertAction(title: "Add", style: .default, handler: { (_) in
            print(popupController.textFields?.first?.text ?? "")
            
            guard let text = popupController.textFields?.first?.text else { return }
            guard let url = URL(string: text) else { return }
            NetworkAPI.shared.fetchEpisodesFeed(feedURL: url, completionHandler: { (feed) in

                let podcastModel = PodcastModel(trackName: feed.title, artistName: feed.iTunes?.iTunesAuthor, artworkUrl600: feed.image?.url, feedUrl: text)
                guard let imgUrl = feed.image?.url ?? feed.iTunes?.iTunesImage?.attributes?.href else { return }
                guard let url = URL(string: imgUrl) else { return }
                
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if let err = error {
                        print(err)
                        return
                    }
                    guard let data = data else { return }
                    
                    DispatchQueue.main.async {
                        let podcastController = self.setupPodcastController(with: podcastModel)
                        podcastController.headerView.podcastImageView.image = UIImage(data: data)
                            self.navigationController?.pushViewController(podcastController, animated: true)
                    }
                    
                }).resume()
            })
        }))
        
        present(popupController, animated: true, completion: nil)
 
 */
    }
    
    fileprivate func setupUI() {
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        navigationController?.view.backgroundColor = .white
    }

}

extension SearchController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print("hllo")
    }
}
