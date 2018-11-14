//
//  NotificationCenter.swift
//  Podcast
//
//  Created by Adrian Evensen on 25/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("downloadProgress")
    static let downloadStarted = NSNotification.Name("downloadStarted")
    static let elapsedTimeProgress = NSNotification.Name("elapsedTimeProgress")
    static let handleDownloadProgress = NSNotification.Name("handleDownloadProgress")
    static let handleDownloadStarted = NSNotification.Name("handleDownloadStarted")
    
    static let handleDownloadFinished = Notification.Name("handleDownloadFinished")
    
    static let playNewEpisode = Notification.Name(rawValue: "playNewEpisode")
}
