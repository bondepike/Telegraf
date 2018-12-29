//
//  ModalPlayer.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 15/07/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

protocol ModalPlayerDelegate {
    func  handlePresentGesture(translation: CGPoint)
    func  handleDismissGesture(translation: CGPoint)
    
    func presentPlayer()
    func dismissPlayer()
}

class ModalPlayer: UIViewController {
    
    lazy var playPauseButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(UIImage(named: "play"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        butt.tintColor = .white//.applePink
 
        return butt
    }()
    
    lazy var rewindButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(UIImage(named: "rewind"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(handleRewind), for: .touchUpInside)
        butt.tintColor = .white//.applePink
        
        return butt
    }()
    
    lazy var forwardButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(UIImage(named: "forward"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        butt.tintColor = .white//.applePink
        
        return butt
    }()
    
    let artwork: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.white.cgColor
        
        return imageView
    }()
    
    let episodeName: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "IBMPlexMono-Bold", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 5
        
        return label
    }()
    

    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    var currentEpisode: Episode?
    var delegate: ModalPlayerDelegate?
    
    var presentGesture: UIPanGestureRecognizer!
    var dismissGesture: UIPanGestureRecognizer!
    
    var dismissGestureStartValue: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAutoLayout()
        setupObservers()
        setupGestures()
        setupBackgroundColor()
    }
}

//MARK:- Gestures
extension ModalPlayer {
    
    func setupGestures() {
        presentGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePresentGesture))
        view.addGestureRecognizer(presentGesture)

        dismissGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDismissGesture))
        dismissGesture.isEnabled = false
        view.addGestureRecognizer(dismissGesture)
        
    }
    
    @objc fileprivate func handleDismissGesture(gesture: UIPanGestureRecognizer) {
 
        let translation = gesture.translation(in: view.superview)
        let velocity = gesture.velocity(in: view.superview)
        
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }

        guard translation.y > 0 else { return }
        switch gesture.state {
        case .began:
            dismissGestureStartValue = translation.y
        case .changed:
            delegate?.handleDismissGesture(translation: translation)
        case .cancelled, .ended, .failed:
            if translation.y > 200 || velocity.y > 600 {
                delegate?.dismissPlayer()
                toggleEnabledGestures()
            } else {
                delegate?.presentPlayer()
            }
        default: break
        }
        
        
    }
    
    @objc fileprivate func handlePresentGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view.superview)
        let velocity = gesture.velocity(in: view.superview)
        
        if gesture.state == .began {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
        }
        
//        if gesture.state == .cancelled || gesture.state == .ended || gesture.state == .failed || gesture.state != .possible {
//            if translation.y < -100 || velocity.y < -600 {
//                delegate?.presentPlayer()
//                //toggleEnabledGestures()
//            } else {
//                delegate?.dismissPlayer()
//            }
//            return
//        }
        
        guard translation.y < 0 else { return }
        switch gesture.state {
        case .changed:
            delegate?.handlePresentGesture(translation: translation)
            break
        case .cancelled, .ended, .failed, .possible:
            if translation.y < -100 || velocity.y < -600 {
                delegate?.presentPlayer()
                //toggleEnabledGestures()
            } else {
                delegate?.dismissPlayer()
            }
            break
        default:
            delegate?.dismissPlayer()
        }
    }
    
    fileprivate func toggleEnabledGestures() {
        presentGesture.isEnabled = !presentGesture.isEnabled
        dismissGesture.isEnabled = !dismissGesture.isEnabled
    }
}

//MARK:- Observers
extension ModalPlayer {
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayNewEpisode), name: .playNewEpisode, object: nil)
        observeAndSavePlayTime()
    }
    
    @objc fileprivate func handlePlayNewEpisode(notification: Notification) {
        guard let episode = notification.object as? Episode else { return }
        playNew(episode: episode)
    }
    
    fileprivate func observeAndSavePlayTime() {
        let interval = CMTimeMake(60, 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [unowned self] (time) in
            guard let currentEpisode = self.currentEpisode, let duration = self.player.currentItem?.duration else { return }
            let elapsedSeconds = CMTimeGetSeconds(time)
            let durationSeconds = CMTimeGetSeconds(duration)
            
            //TODO: Bytte på denne API-en
            CoreDataManager.shared.updateEpisodeTimes(episode: currentEpisode, elapsedTime: elapsedSeconds, episodeLength: durationSeconds, completionHandler: { (_) in
                NotificationCenter.default.post(name: .elapsedTimeProgress, object: nil)
            })
        }
    }
}

import MediaPlayer



//MARK:- Player
extension ModalPlayer {
    
    func playNew(episode: Episode) {
        setupAudioSession()
        
        guard var fileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
//        guard let podcast = episode.podcast else { return }
//        var podcastName = podcast.name ?? ""
//        podcastName = podcastName.replacingOccurrences(of: " ", with: "_")
//        fileUrl.appendPathComponent(podcastName)
        
        fileUrl.appendPathComponent(episode.lastLocalPathCompoenent ?? "")
        chapters(url: fileUrl)
        
        let playerItem = AVPlayerItem(url: fileUrl)
        
        
        player.replaceCurrentItem(with: playerItem)
        
        currentEpisode = episode
        
        let time = CMTime(seconds: episode.timeElapsed, preferredTimescale: 1)
        player.seek(to: time)
        player.play()
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
        
        setupEpisodeMetadata(episode: episode)
        setupMediaPlayerNowPlayingInfo(for: episode)
        setupRemoteControll()
    }
    
    fileprivate func chapters(url: URL) {
        let data = try NSData(contentsOf: url)
        
        guard let length = data?.length else { return }
        
        let count = length / Int(UInt32.max)
        
        var arr = [UInt32](repeating: 0, count: length)
        data?.getBytes(&arr, length: length)
        
        print(Int(arr[0].bigEndian))
        print(arr[1])
        print(arr[2])
        print(arr[15])

    }
    
    fileprivate func setupMediaPlayerNowPlayingInfo(for episode: Episode) {
        var nowPlayingInfo = [String:Any]()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = episode.timeElapsed
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = episode.timeLength
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.podcast?.name

        guard let podcastArtworkData = episode.podcast?.artwork else { return }
        guard let podcastArtwork = UIImage(data: podcastArtworkData) else { return }
        
        let mediaPlayerArtwork = MPMediaItemArtwork(boundsSize: podcastArtwork.size) { (_) -> UIImage in
            return podcastArtwork
        }
        nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaPlayerArtwork
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error {
            print("failed to set AVSession active: ", error)
        }
    }
    
    fileprivate func setupEpisodeMetadata(episode: Episode) {
        episodeName.text = episode.name ?? ""
        if let imageData = episode.podcast?.artwork {
            let image = UIImage(data: imageData)
            artwork.image = image
        }
    
    }
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            play()
        } else {
            pause()
        }
    }
    
    func pause() {
        player.pause()
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
        playPauseButton.setImage(UIImage(named: "play"), for: .normal)
    }
    
    func play() {
        player.play()
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
        playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
    }
    
    @objc func handleForward() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime()) + 30
        addSecondsToCurentPlayback(seconds: 30)

    }
    
    @objc func handleRewind() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(self.player.currentTime()) - 10
        addSecondsToCurentPlayback(seconds: -10)
    }
    
    fileprivate func addSecondsToCurentPlayback(seconds: Double) {
        let currentTime = player.currentTime()
        let forwardTime = CMTimeMakeWithSeconds(seconds, 1)
        let newTime = CMTimeAdd(currentTime, forwardTime)
        player.seek(to: newTime)
    }
}

extension ModalPlayer {
    
    func setupRemoteControll() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            self.play()
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [unowned self] (_) -> MPRemoteCommandHandlerStatus in
            self.pause()
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
            self.handlePlayPause()
            return .success
        }
    
        
    }
    
}

//MARK:- Layout
extension ModalPlayer {
    func setupBackgroundColor() {
        switch UIDevice.screenType {
        case .iphoneXR, .iphoneX, .iphoneXMax:
            view.backgroundColor = .black
            break
        default: view.backgroundColor = .kindaBlack
        }
    }
    
    func setupAutoLayout() {
        setupPlayControll()
        setupArtwork()
        setupTextLabel()
    }
    
    fileprivate func setupPlayControll() {
        view.addSubview(playPauseButton)
        [
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: 44),
            playPauseButton.widthAnchor.constraint(equalToConstant: 44),
            playPauseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -6)
            ].forEach { $0.isActive = true }
        
        view.addSubview(rewindButton)
        [
            rewindButton.rightAnchor.constraint(equalTo: playPauseButton.leftAnchor, constant: -30),
            rewindButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            rewindButton.heightAnchor.constraint(equalToConstant: 44),
            rewindButton.widthAnchor.constraint(equalToConstant: 44)
            ].forEach { $0.isActive = true }
        
        view.addSubview(forwardButton)
        [
            forwardButton.leftAnchor.constraint(equalTo: playPauseButton.rightAnchor, constant: 30),
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor),
            forwardButton.heightAnchor.constraint(equalToConstant: 44),
            forwardButton.widthAnchor.constraint(equalToConstant: 44)
            ].forEach { $0.isActive = true }
    }
    
    fileprivate func setupArtwork() {
        let screenSize = UIScreen.main.bounds
        view.addSubview(artwork)
        [
            artwork.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36),
            artwork.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -36),
            artwork.heightAnchor.constraint(equalToConstant: screenSize.width-36*2),
            artwork.topAnchor.constraint(equalTo: view.topAnchor, constant: 56)
            ].forEach { $0.isActive = true }
    }
    
    fileprivate func setupTextLabel() {
        view.addSubview(episodeName)
        [
            episodeName.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            episodeName.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            episodeName.topAnchor.constraint(equalTo: artwork.bottomAnchor, constant: 15)
            ].forEach { $0.isActive = true }
    }
    

    
}
