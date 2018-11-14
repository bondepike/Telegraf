//
//  PlayerView.swift
//  Podcast
//
//  Created by Adrian Evensen on 03/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import WebKit

class PlayerViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    //MARK:- Global Variables
    var seekerIsBeeingDraged = false
    var dragingTimer: Timer?
    var startTranslation: CGFloat = 0
    var startPos: CGFloat = 0
    var hasScrolled = false
    var scrollLock = false

    let dismissButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.addTarget(self, action: #selector(handlePlayerDismiss), for: .touchUpInside)
        butt.tintColor = .black
        butt.translatesAutoresizingMaskIntoConstraints = false
        
        return butt
    }()
    

    //MARK:- Components
    let dismissDragIndicator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    let podcastImage: UIImageView = {
        let iw = UIImageView()
        iw.translatesAutoresizingMaskIntoConstraints = false
        iw.backgroundColor = .lightGray
        iw.layer.cornerRadius = 5
        iw.clipsToBounds = true
        iw.contentMode = .scaleAspectFill
        
        return iw
    }()
    
    let episodeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 20)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.heightAnchor.constraint(equalToConstant: 50)
        label.textColor = .kindaBlack
        return label
    }()
    
    let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "IBMPlexSans", size: 18)
        label.textColor = .kindaBlack
        label.numberOfLines = 1
        
        return label
    }()
    
    let episodeSmallPlayerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 13)
        label.numberOfLines = 2
        label.textColor = .kindaBlack
        
        return label
    }()
    
    lazy var playPauseSmallPlayerButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        butt.tintColor = .kindaBlack

        return butt
    }()
    
    lazy var playPauseButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        butt.tintColor = .kindaBlack

        return butt
    }()
    
    lazy var forwardButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(#imageLiteral(resourceName: "forward"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.tintColor = .kindaBlack
        butt.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        
        return butt
    }()
    
    lazy var rewindButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.setImage(#imageLiteral(resourceName: "rewind"), for: .normal)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.tintColor = .kindaBlack
        butt.addTarget(self, action: #selector(handleRewind), for: .touchUpInside)
        
        return butt
    }()
    
    
    lazy var currentTimeSlider: TimeSlider = {
        let slider = TimeSlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(handleCurrentSliderValueChanged), for: .touchDown)
        slider.addTarget(self, action: #selector(handleTimeSeekerChange), for: .valueChanged)
        slider.addTarget(self, action: #selector(handleTimeSeekerEnded), for: .touchUpOutside)
        slider.addTarget(self, action: #selector(handleTimeSeekerEnded), for: .touchUpInside)
        slider.addTarget(self, action: #selector(handleTimeSeekerEnded), for: .touchCancel)
        
        slider.minimumTrackTintColor = UIColor.lightGray
        slider.maximumTrackTintColor = UIColor.lightGray
        
        return slider
    }()
    
    let elapsedTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "elapsed"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        
        return label
    }()
    
    let remainingTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "remaining"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .right
        
        return label
    }()
    
    lazy var player: AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        
        return player
    }()
    
    let descriptionText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var nextChapterButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.setImage(#imageLiteral(resourceName: "arrow_forward"), for: .normal)
        butt.tintColor = .ibmBlue
        butt.addTarget(self, action: #selector(handleNextChapter), for: .touchUpInside)
        
        return butt
    }()
    
    lazy var prevChapterButton: UIButton = {
        let butt = UIButton(type: .system)
        butt.translatesAutoresizingMaskIntoConstraints = false
        butt.setImage(#imageLiteral(resourceName: "arrow_back"), for: .normal)
        butt.tintColor = .ibmBlue
        butt.addTarget(self, action: #selector(handlePrevChapter), for: .touchUpInside)
        
        return butt
    }()
    
    let chapterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "IBMPlexMono-Bold", size: 16)
        label.textColor = .ibmBlue
        label.numberOfLines = 2
        
        return label
    }()
    
    lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.scrollView.isScrollEnabled = false
        view.gestureRecognizers?.append(self.scrollView.panGestureRecognizer)
        view.scrollView.maximumZoomScale = 0
        view.scrollView.minimumZoomScale = 0
        view.uiDelegate = self
        view.backgroundColor = .clear
        view.tintColor = .white

        return view
    }()
    
    
    lazy var scrollView: UIScrollView = {
        let cv = UIScrollView()
        cv.translatesAutoresizingMaskIntoConstraints = false

        return cv
    }()
    
    let webViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()

    
    //MARK:- Variables
    var smallConstraints = [NSLayoutConstraint]()
    var largeConstraints = [NSLayoutConstraint]()
    
    var panGesture: UIPanGestureRecognizer!
    var panDismissGesture: UIPanGestureRecognizer!
    
    var scrollConstraints = NSLayoutConstraint()
    var lockConstraints = NSLayoutConstraint()
    
    var webViewHeightConstraint = NSLayoutConstraint()

    struct Chapter {
        var title: String
        var start: CMTime
        var duration: CMTime
    }
    
    var chapters: [Chapter]? {
        didSet {
            guard let count = chapters?.count, count > 0 else {
                prevChapterButton.isHidden = true
                chapterLabel.isHidden = true
                nextChapterButton.isHidden = true
                return }
            prevChapterButton.isHidden = false
            chapterLabel.isHidden = false
            nextChapterButton.isHidden = false
            getCurrentChapter()
        }
    }
    
    var episode: Episode? {
        didSet {
            guard let episode = episode else { return }
            newEpisode(episode: episode)
        }
    }
    
    var episodeImage: UIImage? {
        didSet {
            guard let epiosdeImage = episodeImage else { return }
            self.podcastImage.image = epiosdeImage
        }
    }
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        view.backgroundColor = .white
        setupLayout()

        // Playing and observing
        setupAudioSession()

        observePlayerCurrentTime()
        observePlayerSaveTime()
        setupRemoteControll()
        setupBoundaryTime()
        //setupObservers()
        ///observePlayerDidStartPlaying()

        scrollView.delegate = self
        scrollView.panGestureRecognizer.addTarget(self, action:  #selector(handlePanDismissGesture))
        webView.navigationDelegate = self
    }

    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayNewEpisode), name: .playNewEpisode, object: nil)
    }
    
    @objc fileprivate func handlePlayNewEpisode(notification: Notification) {
        guard let episode = notification.object as? Episode else { return }
        newEpisode(episode: episode)
    }
    
    fileprivate func newEpisode(episode: Episode) {
        setupNowPlayingInfo(for: episode)
        
        setupTitles(with: episode)
        setupWebView(with: episode)
        setupChapters()
        
        replaceCurrentPlayerItem(with: episode)
        playNew(episode: episode)
        
        //setupLockScreenDuration()
        
        guard let podcast = episode.podcast else { return }
        authorLabel.text = podcast.artist ?? ""
        
        guard let episodeData = podcast.artwork else { return }
        guard let episodeImage = UIImage(data: episodeData) else { return }
        
        let artwork = MPMediaItemArtwork(boundsSize: episodeImage.size) { (_) -> UIImage in
            return episodeImage
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.scrollView.contentSize.height = self.webView.scrollView.contentSize.height + self.view.frame.height
        }
    }
    
    deinit {
        print("Player views memory is beeing freed")
    }
}

