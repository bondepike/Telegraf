//
//  PlayerViewController+Player.swift
//  Podcast
//
//  Created by Adrian Evensen on 27/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import MediaPlayer
import AVKit
import UIKit

extension PlayerViewController {
    
    //MARK:- Handle actions
    @objc func handleForward() {
        addSecondsToCurrentPlayback(seconds: 30)
        updateElapsedTime(playbackRate: player.rate)

    }
    
    @objc func handleRewind() {
        addSecondsToCurrentPlayback(seconds: -10)
        updateElapsedTime(playbackRate: player.rate)
    }
    
    fileprivate func addSecondsToCurrentPlayback(seconds: Double) {
        let currentTime = player.currentTime()
        let forwardSeconds = CMTimeMakeWithSeconds(seconds, 1)
        let forwardedTime = CMTimeAdd(currentTime, forwardSeconds)
        player.seek(to: forwardedTime)
    }
    
    @objc func togglePlayPause() {
        if player.timeControlStatus == .paused {
            player.play()
            setupLockScreenDuration()
            updateElapsedTime(playbackRate: 0)
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)

        } else {
            player.pause()
            setupLockScreenDuration()
            updateElapsedTime(playbackRate: 1)
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            playPauseSmallPlayerButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    //MARK:- New Episode
    func playNew(episode : Episode) {
        let time = CMTime(seconds: episode.timeElapsed, preferredTimescale: 1)
        player.seek(to: time)
        player.play()
    }
    
    func setupWebView(with episode: Episode) {
        let css = "<style> body { font-size:46px; font-family: Helvetica; } a { color: #1050D6; text-decoration: none; } p { font-weight: bold;  } * { margin: 5%; } </style>"
        
        if let HTML = episode.episodeDesciption {
            print(HTML)
            var soup = HTML
            soup += css
            webView.loadHTMLString(soup, baseURL: nil)
        }
    }
    func setupTitles(with episode: Episode) {
        episodeTitleLabel.text = episode.name ?? ""
        episodeSmallPlayerTitleLabel.text = episode.name ?? ""
    }
    
    func replaceCurrentPlayerItem(with episode: Episode) {
        guard var trueFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        trueFileUrl.appendPathComponent(episode.lastLocalPathCompoenent ?? "")
        
        let playerItem = AVPlayerItem(url: trueFileUrl)
        player.replaceCurrentItem(with: playerItem)
    }
    
    
    //MARK:- Setup
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("failed to set AVSession active: ", error)
        }
    }
    
    func setupBoundaryTime() {
        let playerTime = player.currentTime()
        let addTime = CMTime(seconds: 1, preferredTimescale: 1)
        let addedPlayerTime = CMTimeAdd(playerTime, addTime)
        
        let addedPlayerTimes = [NSValue(time: addedPlayerTime)]
        player.addBoundaryTimeObserver(forTimes: addedPlayerTimes, queue: .main) { [weak self] in
            self?.setupLockScreenDuration()
        }
    }
    

    
    //MARK:- Chapters
    func getCurrentChapter() {
        let currentIndex = getCurrentChapterIndex()
        guard currentIndex > 0 else { return }
        
        guard let currentChapter = chapters?[currentIndex] else { return }
        chapterLabel.text = currentChapter.title
    }
    
    func getCurrentChapterIndex() -> Int {
        let currentTime = player.currentTime()
        var currentIndex = 0
        
        chapters?.enumerated().forEach({ (index, chapter) in
            if currentTime.seconds - chapter.start.seconds > 0 {
                currentIndex = index
            }
        })
        return currentIndex
    }
    
    @objc func handleNextChapter() {
        let currentIndex = getCurrentChapterIndex()
        let nextIndex = currentIndex + 1
        if let count = chapters?.count, count > nextIndex {
            guard let nextChapter = chapters?[currentIndex + 1] else { return }
            player.currentItem?.seek(to: nextChapter.start, completionHandler: { [unowned self] (success) in
                self.player.play()
            })
        }
    }
    @objc func handlePrevChapter() {
        let currentIndex = getCurrentChapterIndex()
        let prevIndex = currentIndex - 1
        guard prevIndex > 0 else { return }
        guard let prevChapter = chapters?[currentIndex - 1] else { return }
        player.currentItem?.seek(to: prevChapter.start, completionHandler: { [unowned self] _ in
            self.chapterLabel.text = prevChapter.title
            self.player.play()
        })
    }
    
    func setupChapters() {
        var localChapter = [Chapter]()
        
        if let metadata = MNAVChapterReader.chapters(from: player.currentItem?.asset) as? [MNAVChapter] {
            metadata.forEach({ (item) in
                let chapter = Chapter(title: item.title, start: item.time, duration: item.duration)
                localChapter.append(chapter)
                
                let nsValue = NSValue(time: item.time)
                player.addBoundaryTimeObserver(forTimes: [nsValue], queue: .main, using: {
                    self.chapterLabel.text = chapter.title
                })
            })
            chapters = localChapter
        }
    }
    
}
