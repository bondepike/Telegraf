//
//  HomeController+PlayerView.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 08/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//
import UIKit

extension SubscriptionsController {
    
    
    func setupPlayerView() {
        
        let window = UIApplication.shared.keyWindow
        
        //window?.addSubview(playerView)
        //addChildViewController(playerView)
        window?.addSubview(playerView.view)
        //window?.rootViewController?.addChildViewController(playerView)
        
        playerView.view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
        playerView.view.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(maximizePlayerView))
        playerView.view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func maximizePlayerView() {
        UIView.animate(withDuration: 0.4) {
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            statusBar?.alpha = 0.5
        }
        let window = UIApplication.shared.keyWindow
        let rootViewController = window?.rootViewController as? UINavigationController
        
        self.playerView.dismissButton.isHidden = false
        self.playerView.dismissDragIndicator.isHidden = false
        
        self.playerView.smallConstraints.forEach { $0.isActive = false }
        self.playerView.largeConstraints.forEach { $0.isActive = true }
        //UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
            
            let screenSize = UIScreen.main.bounds
            
            self.playerView.view.frame = CGRect(x: 0, y: Theme.shared.playerViewTopDistance, width: self.view.frame.width, height: screenSize.height)//self.view.frame.height)//-24)
            
            rootViewController?.view.transform = CGAffineTransform(scaleX: Theme.shared.scaleX, y: Theme.shared.scaleY)
            rootViewController?.view.layer.cornerRadius = Theme.shared.cornerRadius
            rootViewController?.view.clipsToBounds = true
            rootViewController?.view.alpha = Theme.shared.alpha
            self.playerView.view.layer.cornerRadius = Theme.shared.cornerRadius
            self.playerView.view.layer.borderWidth = 0
            self.playerView.view.layoutIfNeeded()
            
            self.playerView.dismissDragIndicator.alpha = 1
            self.playerView.episodeSmallPlayerTitleLabel.alpha = 0
            self.playerView.playPauseSmallPlayerButton.alpha = 0
            
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            statusBar?.alpha = 1
        }, completion: { (finished) in
            if finished {
                
                self.playerView.episodeSmallPlayerTitleLabel.isHidden = true
                self.playerView.playPauseSmallPlayerButton.isHidden = true
                
            }
        })
    }
    
    @objc func dissapearPlayerView() {
        let window = UIApplication.shared.keyWindow
        let rootViewController = window?.rootViewController as? UINavigationController
        self.playerView.largeConstraints.forEach { $0.isActive = false }
        self.playerView.smallConstraints.forEach { $0.isActive = true }
        
        self.playerView.episodeSmallPlayerTitleLabel.isHidden = false
        self.playerView.playPauseSmallPlayerButton.isHidden = false
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
            
            rootViewController?.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            rootViewController?.view.layer.cornerRadius = 0
            rootViewController?.view.clipsToBounds = true
            rootViewController?.view.alpha = 1
            
            let screenSize = UIScreen.main.bounds
            
            //self.playerView.view.layer.borderColor = UIColor.darkGray.cgColor
            //self.playerView.view.layer.borderWidth = 0.2
            self.playerView.view.transform = .identity
            self.playerView.view.frame = CGRect(x: 0, y: screenSize.height, width: self.view.frame.width, height: screenSize.height)
            self.playerView.view.layer.cornerRadius = 0
            self.playerView.view.layoutIfNeeded()
            
            self.collectionView?.contentInset.bottom = 64

            
            self.playerView.dismissDragIndicator.alpha = 0
            self.playerView.episodeSmallPlayerTitleLabel.alpha = 1
            self.playerView.playPauseSmallPlayerButton.alpha = 1
            
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            statusBar?.alpha = 1
            
        }, completion: { (finished) in
            if finished {
                UIView.animate(withDuration: 0.4, animations: {
                    self.playerView.dismissDragIndicator.isHidden = true
                    self.playerView.dismissButton.isHidden = true
                })
            }
        })
    }
    
    @objc func minimizePlayerView() {
        let window = UIApplication.shared.keyWindow
        let rootViewController = window?.rootViewController as? UINavigationController
        self.playerView.largeConstraints.forEach { $0.isActive = false }
        self.playerView.smallConstraints.forEach { $0.isActive = true }
        
        self.playerView.episodeSmallPlayerTitleLabel.isHidden = false
        self.playerView.playPauseSmallPlayerButton.isHidden = false
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
            
            rootViewController?.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            rootViewController?.view.layer.cornerRadius = 0
            rootViewController?.view.clipsToBounds = true
            rootViewController?.view.alpha = 1
            
            let screenSize = UIScreen.main.bounds

            self.playerView.view.transform = .identity
            self.playerView.view.frame = CGRect(x: 0, y: screenSize.height-64, width: self.view.frame.width, height: screenSize.height)
            self.playerView.view.layer.cornerRadius = 0
            self.playerView.view.layoutIfNeeded()
            
            self.collectionView?.contentInset.bottom = 64
            
            
            //self.transform = CGAffineTransform(translationX: 0, y: translation.y*0.4)
            
            
            self.playerView.dismissDragIndicator.alpha = 0
            self.playerView.episodeSmallPlayerTitleLabel.alpha = 1
            self.playerView.playPauseSmallPlayerButton.alpha = 1
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            statusBar?.alpha = 1
            
        }, completion: { (finished) in
            if finished {
                UIView.animate(withDuration: 0.4, animations: {
                    self.playerView.dismissDragIndicator.isHidden = true
                    self.playerView.dismissButton.isHidden = true
                })
            }
        })
    }
}
