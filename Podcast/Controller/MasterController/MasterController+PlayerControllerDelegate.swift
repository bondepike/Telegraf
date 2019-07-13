//
//  MasterController+PlayerControllerDelegate.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 23/07/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import UIKit

extension MasterController: ModalPlayerDelegate {
    
    func dismissPlayer() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.homeController.view.frame = CGRect(x: 0, y: 0, width: self.homeController.view.frame.width , height: self.homeController.view.frame.height)
        }) { (s) in
        }
    }
    
    func presentPlayer() {
        let height = homeController.view.frame.height
        let width = homeController.view.frame.width
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveEaseIn, animations: {
            self.homeController.view.frame = CGRect(x: 0, y: -150, width: width, height: height)
        }) { (s) in
        }
        modalPlayer.dismissGesture.isEnabled = true
        modalPlayer.presentGesture.isEnabled = true
    }
    
    func handlePresentGesture(translation: CGPoint) {
        let height = homeController.view.frame.height
        let width = homeController.view.frame.width
        
        homeController.view.frame = CGRect(x: 0, y: translation.y * 0.4, width: width, height: height)
    }
    
    static var startValue: CGPoint?
    func handleDismissGesture(translation: CGPoint) {
        let height = homeController.view.frame.height
        let width = homeController.view.frame.width
        
        homeController.view.frame = CGRect(x: 0, y: -150 + translation.y * 0.6, width: width, height: height)
    }
    
}
