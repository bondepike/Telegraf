//
//  ContainerController.swift
//  Podcast
//
//  Created by Adrian Evensen on 13/07/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import NotificationCenter

class MasterController: UIViewController {
    
    let homeController = TabBarController()
    
    lazy var modalPlayer: ModalPlayer = {
        let modalPlayer = ModalPlayer()
        modalPlayer.delegate = self
        return modalPlayer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupModalPlayer()
        setupHomeController()
        setupObservers()
    }
    
    fileprivate func setupModalPlayer() {
        addChildViewController(modalPlayer)
        view.addSubview(modalPlayer.view)
        
        let screenSize = UIScreen.main.bounds
        modalPlayer.view.frame = screenSize
        modalPlayer.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        modalPlayer.didMove(toParentViewController: self)
    }
    
    fileprivate func setupHomeController() {
        homeController.view.clipsToBounds = true
        homeController.playerDelegate = self
        addViewControllerAsChildController(childController: homeController)
        homeController.view.layer.cornerRadius = 5
    }
    
    fileprivate func addViewControllerAsChildController(childController: UIViewController) {
        addChildViewController(childController)
        view.addSubview(childController.view)
        
        childController.view.frame = view.bounds
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childController.didMove(toParentViewController: self)
    }
}

extension MasterController: SubscriptionChangesDelegate {
    
    func subscribedToNew(podcast: Podcast?) {
        //homeController.fetchFavoritePodcasts()
        homeController.homeController.fetchFavoritePodcasts()
    }
    
    func deletedPodcast() {}
    
}

extension MasterController {
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayNewEpisode), name: .playNewEpisode, object: nil)
    }
    
    @objc fileprivate func handlePlayNewEpisode(notification: Notification) {
        let screenSize = UIScreen.main.bounds
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: { [unowned self] in
            
            switch UIDevice.screenType {
            case .iphoneX, .iphoneXMax:
                self.homeController.view.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 100)
                self.homeController.view.layer.cornerRadius = 25
                break
            default:
                self.homeController.view.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height - 64)
                break
            }
            
            self.homeController.view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }, completion: nil)
    }
    
}
