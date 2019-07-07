//
//  EpisodesCell+Observer.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 15/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

extension EpisodeCell {
//
//    //MARK:- Observers
    @objc func updateRemainingStatus() {
        guard let episode = episodeDataSource?.episode else { return }

        // fikser Fatal Error
        if episode.timeLength.isNaN {
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

        var thisEpisodeName = episodeDataSource?.name ?? ""
        thisEpisodeName = thisEpisodeName.replacingOccurrences(of: " ", with: "")

        guard thisEpisodeName == episodeName else { return }

        guard let length = notification.userInfo?["length"] as? Float64 else { return }
        let timeRemaining = Int(length/60)

        DispatchQueue.main.async {
            self.elapsedTimeProgressShapeLayer.isHidden = false
            self.timeRemainingLabel.text = "\(timeRemaining)m"
            self.isUserInteractionEnabled = true
        }

    }

    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else { return }

        guard var identifier = userInfo["identifier"] as? String else { return }
        guard let progress = userInfo["progress"] as? Float else { return }

        identifier = identifier.replacingOccurrences(of: "no.adrianf.telegraf.background.", with: "")


        DispatchQueue.main.async {

            var episodeName = self.episodeTitle.text ?? ""
            episodeName = episodeName.replacingOccurrences(of: " ", with: "")

            guard episodeName == identifier else { return }

            let percentage = Int(progress)

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
        guard userInfo["title"] as? String == episodeDataSource?.name else { return }
        timeRemainingLabel.text = "On It!"
        elapsedTimeProgressShapeLayer.isHidden = true
    }
}
