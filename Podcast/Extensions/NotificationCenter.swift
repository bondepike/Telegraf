//
//  NotificationCenter.swift
//  Podcast
//
//  Created by Adrian Evensen on 25/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    // Oppdaterer gjenstående tid
    static let elapsedTimeProgress = NSNotification.Name("elapsedTimeProgress")
    
    // Oppdaterer nedlasting framgang
    static let handleDownloadProgress = NSNotification.Name("handleDownloadProgress")
    
    // Oppdaterer nedlasting start og ferdig
    static let handleDownloadStarted = NSNotification.Name("handleDownloadStarted")
    static let handleDownloadFinished = Notification.Name("handleDownloadFinished")
    
    // Spiller av ny episode
    static let playNewEpisode = Notification.Name(rawValue: "playNewEpisode")
    
    static let reloadPodcasts = Notification.Name(rawValue: "reloadPodcasts")
}
