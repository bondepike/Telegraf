//
//  Theme.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 26/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import UIKit

class Theme {
    static let shared = Theme()

    //MARK:- PlayerView
    
    //let scaleX: CGFloat = 0.93
    //let scaleY: CGFloat = 0.935
    
    let scaleX: CGFloat = {
        switch UIDevice.screenType {
        case .iphoneX:
            return 0.90
        default: return 0.93
        }
    }()
    
    let scaleY: CGFloat = {
        switch UIDevice.screenType {
        case .iphoneX:
            return 0.905
        default: return 0.935
        }
    }()
    
    let playerViewTopDistance: CGFloat = {
        switch UIDevice.screenType {
        case .iphoneX:
            return 56
        default: return 36
        }
    }()
    
    
    /* Hvor fort PlayerView vokser på dismiss drag */
    let scaleXSpeed: CGFloat = 16
    let scaleYSpeed: CGFloat = 16
    
    let cornerRadius: CGFloat = 12
    let alpha: CGFloat = 0.4
    
//    /** Avstanden fra podcast image til toppen av scroll view */
//    let podcastImageTopContraintConstant: CGFloat = {
//        switch UIDevice.screenType {
//        case .iphone4:
//            return 14
//        case .iphone5:
//            return 16
//        case .iphone6:
//            return 24
//        case .iphone6Pluss:
//            return 32
//        case .iphoneX:
//            return 36
//        case .unknown:
//            return 14
//        }
//
//    }()
    
    //MARK:- Fonts
    let boldFont = UIFont(name: "IBMPlexSans-Bold", size: 14)
    let regularFont = UIFont(name: "IBMPlexSans", size: 14)
    
    
//    //MARK:- App States
//    var downloadStatus = [String:Double]()
//    
//    init() {
//        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .handleDownloadProgress, object: nil)
//    }
//    
//    @objc func handleDownloadProgress(notification: Notification) {
//        guard let userInfo = notification.userInfo else { return }
//        guard let episodeName = userInfo["title"] as? String else { return }
//        guard let downloadProgress = userInfo["progress"] as? Double else { return }
//        downloadStatus[episodeName] = downloadProgress
//    }
//    
}
