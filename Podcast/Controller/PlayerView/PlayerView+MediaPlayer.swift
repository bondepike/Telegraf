//
//  PlayerView+MediaPlayer.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import MediaPlayer
extension PlayerViewController {
    
    //MARK:- MediaPlayer Center
    func setupNowPlayingInfo(for episode: Episode) {
        var nowPlayingInfo = [String:Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.podcast?.name ?? ""
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupLockScreenDuration() {
        //guard let someDuration = player.currentItem?.duration else { return }
       // let durationSeconds = CMTimeGetSeconds(someDuration)
        let elapsedSeconds = CMTimeGetSeconds(player.currentTime())
        
        while player.currentTime().isValid != true {
            print("not so fast..")
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedSeconds
        //MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = 0//durationSeconds
    }
    
    func updateElapsedTime(playbackRate: Float) {
        let elapsedSeconds = CMTimeGetSeconds(player.currentTime())
        
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedSeconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func setupRemoteControll() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.play()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.updateElapsedTime(playbackRate: 1)
            
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.updateElapsedTime(playbackRate: 0)
            
            return .success
        }
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            self.handleForward()
            
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [10]
        commandCenter.skipBackwardCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            self.handleRewind()
            
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            self.togglePlayPause()
            
            return .success
        }
        
    }
}
