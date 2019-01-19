//
//  TabBarController.swift
//  Podcast
//
//  Created by Adrian Evensen on 27/07/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var searchNavController: UINavigationController?
    let searchController = SearchController()
    
    var homeNavController: UINavigationController?
    lazy var homeController: SubscriptionsController = {
        let layout = UICollectionViewFlowLayout()
        let homeController = SubscriptionsController(collectionViewLayout: layout)
        homeController.homeControllerDelegate = self
        
        return homeController
    }()
    
    let feedController = FeedController()
    var playerDelegate: ModalPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchNavController = UINavigationController(rootViewController: searchController)
        guard let searchNavController = searchNavController else { return }
        searchNavController.tabBarItem.image = UIImage(named: "search")
        searchNavController.title = "Search"
        searchController.tabBarDelegate = self
        searchController.subscriptionChangesDelegate = self
        
        homeNavController = UINavigationController(rootViewController: homeController)
        guard let homeNavController = homeNavController else { return }
        homeNavController.tabBarItem.image = UIImage(named: "podcasts")
        
        let feedNavController = UINavigationController(rootViewController: feedController)
        feedNavController.title = "Feed"
        feedNavController.tabBarItem.image = UIImage(named: "stream")

        viewControllers = [homeNavController, feedNavController, searchNavController]
        
        //setupDragIndicator()
        setupGestures()
    }
    
    func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleTabBarPanGesture))
        tabBar.addGestureRecognizer(panGesture)
    }
    
    @objc fileprivate func handleTabBarPanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view.superview)
        let velocity = gesture.velocity(in: view.superview)
        
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
        
        guard translation.y < 0 else { return }
        switch gesture.state {

        case .changed:
            playerDelegate?.handlePresentGesture(translation: translation)
            break
        case .cancelled, .ended, .failed, .possible:
            if translation.y < -100 || velocity.y < -600 {
                playerDelegate?.presentPlayer()
                //toggleEnabledGestures()
            } else {
                playerDelegate?.dismissPlayer()
            }
            break
        default:
            playerDelegate?.dismissPlayer()
        }
    }
    
    func setupDragIndicator() {
        let dragIndicator = UIView()
        dragIndicator.backgroundColor = .lightGray
        dragIndicator.clipsToBounds = true
        dragIndicator.layer.cornerRadius = 3
        dragIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(dragIndicator)
        [
            dragIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
            dragIndicator.widthAnchor.constraint(equalToConstant: 66),
            dragIndicator.heightAnchor.constraint(equalToConstant: 3),
            dragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ].forEach { $0.isActive = true }
    }
    
    func shadow() {
        view.layer.shadowColor = UIColor.black.cgColor
        //view.layer.shadowOffset = //CGSizeMake(5, 5)
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 1.0
        view.layer.masksToBounds = false
    }
    
}

extension TabBarController: SubscriptionChangesDelegate {
    func subscribedToNew(podcast: Podcast?) {
        self.homeController.fetchFavoritePodcasts()
    }
    
    func deletedPodcast() {
        self.homeController.fetchFavoritePodcasts()
    }
    
    
}

extension TabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        searchController.navigationItem.searchController?.dismiss(animated: true, completion: nil)
    }
}

extension TabBarController: HomeControllerDelegate {
    func didFetch(_ podcasts: [Podcast]) {
        searchController.podcasts = podcasts
    }
}
