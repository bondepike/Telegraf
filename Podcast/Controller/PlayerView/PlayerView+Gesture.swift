//
//  PlayerView+Gesture.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 09/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit


extension PlayerViewController: UIScrollViewDelegate {
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        hasScrolled = true

    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 10 && scrollView.panGestureRecognizer.velocity(in: view.superview).y > 0 {
            print("I SHOULD CONTINUE TO SCROLL")
        }
        
        if scrollView.contentOffset.y < 40 {
            scrollView.bounces = false
        } else {
            scrollView.bounces = true
        }

    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollLock = false
    }
    
    func transitionViews(translation: CGPoint) {
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        var transformationScaleX = Theme.shared.scaleX + translation.y/(view.frame.height*Theme.shared.scaleYSpeed)
        let transformationScaleY = Theme.shared.scaleY + translation.y/(view.frame.height*Theme.shared.scaleXSpeed)
        let cornerRadius = Theme.shared.cornerRadius - translation.y/(50)
        if transformationScaleX > 1 {
            transformationScaleX = 1
        }
        
        self.view.transform = CGAffineTransform(translationX: 0, y: (translation.y - startPos) * 0.4 )

        if transformationScaleY < 1 {
            navigationController?.view.transform = CGAffineTransform(scaleX: transformationScaleX, y: transformationScaleY)
        }
        
        if cornerRadius >= 0 {
            navigationController?.view.layer.cornerRadius = cornerRadius
        }
    }
    
    
    
    
    
    @objc func handlePanDismissGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view.superview)
        
        guard translation.y > 0 else { return }
        let velocity = gesture.velocity(in: self.view.superview)
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let homeController = navigationController?.viewControllers[0] as? SubscriptionsController

        
        if gesture.state == .began {
            //hasScrolled = true
        }
        
        if gesture.state == .changed {
            scrollLock = false
            
            guard self.scrollView.contentOffset.y <= 0 else { return }
            scrollLock = true
            if hasScrolled {
                scrollLock = false
                startPos = translation.y
                hasScrolled = false
            }
            transitionViews(translation: translation)
        }
        
        if gesture.state == .cancelled || gesture.state == .failed {
            scrollLock = false
        }
        
        if gesture.state == .ended {
            scrollLock = false

            if (translation.y > 200 || velocity.y > 500) && self.scrollView.contentOffset.y <= 0 {
                UIView.animate(withDuration: 0.4, animations: {
                    let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
                    statusBar?.alpha = 0.5
                    //UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
                })
                homeController?.minimizePlayerView()

            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
                    
                    navigationController?.view.transform = CGAffineTransform(scaleX: Theme.shared.scaleX, y: Theme.shared.scaleY)
                    self.view.transform = .identity
                })
            }
        }
    }
    
    

    
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view.superview)
        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        
        //let homeController = navigationController?.viewControllers[0] as? HomeController
        
        
        if gesture.state == .changed {
            
            print(translation.y/(view.frame.height))
            
            let widthTransform = 1-translation.y/(view.frame.height*8)
            let heightTransform = 1-translation.y/(view.frame.height*10)
            let cornerRadius = -translation.y/28
            
            
            self.view.transform = CGAffineTransform(translationX: 0, y: translation.y)
            navigationController?.view.layer.transform = CATransform3DMakeScale(widthTransform, heightTransform, 1)
            navigationController?.view.layer.cornerRadius = cornerRadius
            navigationController?.view.clipsToBounds = true
            navigationController?.view.alpha = 0.7
            
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
                
                let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
                let homeController = navController?.viewControllers[0] as? SubscriptionsController
                
                if translation.y < -200 {
                    
                    homeController?.maximizePlayerView()
                    gesture.isEnabled = false
                    
                } else {
                    homeController?.view.transform = .identity
                    self.view.transform = .identity
                }
            })
            
        }
    }
    
}
