//
//  EpisodesCell+Observer.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 15/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

extension EpisodesCell {
    
    //MARK:- Observers
    @objc func updateRemainingStatus() {
        guard let episode = localEpisode else { return }
        
        // fikser Fatal Error
        if episode.timeLength.isNaN == true {
            return
        }
        
        elapsedTimeProgressShapeLayer.isHidden = false
        let percentage = episode.timeElapsed / episode.timeLength
        let timeRemaining = Int((episode.timeLength - episode.timeElapsed)/60)
        
        elapsedTimeProgressShapeLayer.isHidden = false
        timeRemainingLabel.text = "\(timeRemaining)m"
        elapsedTimeProgressShapeLayer.strokeEnd = 1 - CGFloat(percentage)
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleDownloadFinished(notification: Notification) {
        guard let episodeName = notification.userInfo?["name"] as? String else { return }
        
        guard var thisEpisodeName = internetEpisode?.name else { return }
        thisEpisodeName = thisEpisodeName.replacingOccurrences(of: " ", with: "")
        guard thisEpisodeName == episodeName else { return }
        print("YAY")
        
        
        DispatchQueue.main.async {
            guard let episode = self.localEpisode else { return }
            guard let url = notification.object as? URL else { return }
            
            let context = CoreDataManager.shared.persistentContainer.viewContext
            episode.lastLocalPathCompoenent = url.lastPathComponent
            
            let asset = AVURLAsset(url: url)
            let assetDuration = asset.duration
            let assetDurationSeconds = CMTimeGetSeconds(assetDuration)
            episode.timeLength = assetDurationSeconds
            episode.downloadProgress = 100

            
            do {
                try context.save()
                self.isUserInteractionEnabled = true
                print("done")
            } catch let error {
                print("failed to save local path: ", error)
            }
            
            
            let length = assetDurationSeconds
            let timeRemaining = Int(length/60)
            
            self.elapsedTimeProgressShapeLayer.isHidden = false
            self.timeRemainingLabel.text = "\(timeRemaining)m"
            
        }
 }
    
    
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else { return }

        guard var identifier = userInfo["identifier"] as? String else { return }
        guard let progress = userInfo["progress"] as? Float else { return }
        
        identifier = identifier.replacingOccurrences(of: "no.adrianf.telegraf.background.", with: "")
        
        var episodeName = internetEpisode?.name ?? ""
        episodeName = episodeName.replacingOccurrences(of: " ", with: "")
        
        guard episodeName == identifier else { return }
        print(episodeName, "  :  ", progress)
        
        let percentage = Int(progress)
        
        DispatchQueue.main.async {
            self.downloadProgressShapeLayer.strokeEnd = CGFloat(progress/100)
            self.elapsedTimeProgressShapeLayer.isHidden = true
            self.timeRemainingLabel.text = "\(percentage)%"
        }
        
        if progress == 1 {
            isUserInteractionEnabled = true
            episodeTitle.textColor = .kindaBlack
            episodeSubtitle.textColor = .kindaBlack
        }
    }
    
    @objc func handleDownloadStarted(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard userInfo["title"] as? String == localEpisode?.name else { return }
        timeRemainingLabel.text = "On It!"
        elapsedTimeProgressShapeLayer.isHidden = true
    }
    
    
    
}
