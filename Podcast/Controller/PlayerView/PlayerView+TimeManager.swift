//
//  PlayerView+TimeManager.swift
//  Podcast
//
//  Created by Adrian Evensen on 18/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import AVKit
import MediaPlayer

extension PlayerViewController {
    
    //MARK:- Time observing
    func observePlayerCurrentTime() {
        let interval = CMTimeMake(1, 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [unowned self] (time) in
            let totalSeconds = Int(CMTimeGetSeconds(time))
            let seconds = totalSeconds % 60
            let minutes = totalSeconds % (60*60)/60
            let hours = totalSeconds / 60 / 60
            
            NotificationCenter.default.post(name: .elapsedTimeProgress, object: nil)
            self.elapsedTimeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)

            guard let duration = self.player.currentItem?.duration else { return }
            if duration.isIndefinite {
                return
            }
            
            let totalDurationSeconds = Int(CMTimeGetSeconds(duration))
            let remainingSeconds = (totalDurationSeconds-totalSeconds) % 60
            var durationMinutes = ((totalDurationSeconds % (60*60) / 60) - minutes) % 60
            if durationMinutes < 0 {
                durationMinutes = durationMinutes * (-1)
            }
            
            let durationHours = ((totalDurationSeconds / 60 / 60) - hours) % 60
            self.remainingTimeLabel.text = String(format: "-%02d:%02d:%02d", durationHours, durationMinutes, remainingSeconds)
            if self.currentTimeSlider.isTracking == false {
                let percentage = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(duration))
                self.currentTimeSlider.value = percentage
            }
            
            //self.updateElapsedTime(playbackRate: 1)
        }
    }
    
    func observePlayerDidStartPlaying() {
        let cmTime = CMTimeMake(1, 3)
        let times = [NSValue(time: cmTime)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [unowned self] in
            print("episode started playing")
            self.setupLockscreenDuration()
        }
    }
    
    fileprivate func setupLockscreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let time = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
    }
    
    func observePlayerSaveTime() {
        let interval = CMTimeMake(60, 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            
            guard let episode = self.episode, let duration = self.player.currentItem?.duration else { return }
            
            let elapsedSeconds = CMTimeGetSeconds(time)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            CoreDataManager.shared.updateEpisodeTimes(episode: episode, elapsedTime: elapsedSeconds, episodeLength: durationSeconds, completionHandler: { elapsedTime in
            })
            
        }
    }
    
    
    @objc func handleCurrentSliderValueChanged() {
        player.pause()
//        playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
//        playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
    @objc func handleTimeSeekerEnded() {
        player.play()
        playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    @objc func handleTimeSeekerChange() {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let timeInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = timeInSeconds * Double(percentage)
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, 1)
        
        if player.status == .readyToPlay {
            self.player.currentItem?.seek(to: seekTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { [unowned self] (_) in
                self.getCurrentChapter()
            })
        } else {
            print("rendering..")
        }
    }
    
    
    @objc func seekerIsEditing() {
        self.seekerIsBeeingDraged = true
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}





