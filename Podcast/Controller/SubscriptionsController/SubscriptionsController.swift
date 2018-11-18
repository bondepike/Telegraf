//
//  HomeController.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 08/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

protocol HomeControllerDelegate {
    func didFetch(_ podcasts: [Podcast])
}

class SubscriptionsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, SubscriptionChangesDelegate {

    func subscribedToNew(podcast: Podcast?) {
        fetchFavoritePodcasts()
    }
    
    func deletedPodcast() {
        fetchFavoritePodcasts()
    }
    
    func segmentedControllerUpdatedIndex(index: Int) {}
    
   // let playerView = PlayerViewController()

    //MARK:- Data
    var podcasts: [Podcast]? {
        didSet {
            guard let podcasts = podcasts else { return }
            homeControllerDelegate?.didFetch(podcasts)
        }
    }
    
    var delegate: SearchControllerDelegate?
    var homeControllerDelegate: HomeControllerDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectonView()
        fetchFavoritePodcasts()
        setupNavigationbar()
        setupModalSearchController()
        
    }
    
    func setupNavigationbar() {
        //let historyButton = UIBarButtonItem(image: #imageLiteral(resourceName: "history"), style: .plain, target: self, action: #selector(presentHistoryController))
    }

    func setupModalSearchController() {
        let searchController = SearchController()
        searchController.podcasts = podcasts
        addChildViewController(searchController)
        
        searchController.subscriptionChangesDelegate = self
    }
    

    @objc fileprivate func presentSettingsController() {
        delegate?.presentSearchController()
    }
    
    @objc fileprivate func presentSearchController() {
        let searchController = SearchController()
        searchController.podcasts = podcasts
        searchController.subscriptionChangesDelegate = self
        navigationController?.pushViewController(searchController, animated: true)
    }
    

    
    fileprivate func setupUI() {
        title = "Podcasts"
        let titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.applePink,
            NSAttributedStringKey.font: UIFont(name: "IBMPlexSans-Bold", size: 18) as Any]
        navigationController?.navigationBar.titleTextAttributes = titleTextAttributes
    }
    
    fileprivate func setupCollectonView() {
        collectionView?.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footerId")
        collectionView?.backgroundColor = .white

        collectionView?.register(FavoritesCell.self, forCellWithReuseIdentifier: "cellId")
    }
    
    @objc fileprivate func deleteAllPodcasts() {
        CoreDataManager.shared.deleteAllPodcasts {
            fetchFavoritePodcasts()
        }
    }
    
    func fetchFavoritePodcasts() {
        CoreDataManager.shared.fetchAllPodcasts { (fetchedPodcasts) in
            if fetchedPodcasts.isEmpty {
            }
            print("all podcasts are fetched")
            self.podcasts = fetchedPodcasts
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}
