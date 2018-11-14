//
//  PodcastHeaderView.swift
//  Podcast
//
//  Created by Adrian Evensen on 19/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

protocol PodcastHeaderViewDelegate: class {
    func segmentedControllerUpdatedIndex(index: Int)
    func didSubscribeToNew(podcast: Podcast?)
    func didTapSettings()
}

class PodcastHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    weak var delegate: PodcastHeaderViewDelegate?
    weak var subscriptionChangesDelegate: SubscriptionChangesDelegate?
    
    weak var podcast: Podcast? {
        didSet {
            guard let podcast = podcast else { return }
            podcastTitleLabel.text = podcast.name
            artistLabel.text = podcast.artist
            subscribeButton.isHidden = true
            setupNotificationsButton()
        }
    }
    
    var podcastModel: PodcastModel? {
        didSet {
            guard let podcastModel = podcastModel else { return }
            podcastTitleLabel.text = podcastModel.trackName
            artistLabel.text = podcastModel.artistName
        }
    }
    
    var episodes: [EpisodeModel]?
    
    let podcastImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let podcastTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .kindaBlack
        
        return label
    }()
    
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "IBMPlexSans", size: 16)
        label.textColor = .kindaBlack
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let weekdayText: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "IBMPlexSans", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textColor = .darkCreme
        label.isHidden = true
        
        return label
    }()
    
    lazy var subscribeButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Subscribe", for: .normal)
        button.layer.cornerRadius = 5
        button.backgroundColor = .ibmBlue
        button.tintColor = .white
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.titleLabel?.font = UIFont(name: "IBMPlexSans-Bold", size: 20)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSubscribe), for: .touchUpInside)
        return button
    }()
    
    lazy var notificationsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "notification_off"), for: .normal)
        button.tintColor = .ibmBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleNotification), for: .touchUpInside)
        
        
        return button
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        return activityIndicator
    }()
    
    lazy var settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "settings"), for: .normal)
       // button.setTitle("Settings", for: .normal)
//        button.layer.cornerRadius = 5
//        button.backgroundColor = .white
//        button.layer.borderColor = UIColor.ibmBlue.cgColor
//        button.layer.borderWidth = 2
        button.tintColor = .ibmBlue
//        button.titleLabel?.font = UIFont(name: "IBMPlexSans-Bold", size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        
        return button
    }()
    
    lazy var segmentedController: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["Downloads", "All Episodes"])
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(handleSegmentedControlChange), for: .valueChanged)
        segControl.tintColor = .applePink
        segControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "IBMPlexSans-Bold", size: 16) as Any], for: .normal)
        
        return segControl
    }()
    
    @objc func handleSegmentedControlChange(index: Int) {
        switch segmentedController.selectedSegmentIndex {
        case 0:
            delegate?.segmentedControllerUpdatedIndex(index: 0)
            break;
        case 1:
            delegate?.segmentedControllerUpdatedIndex(index: 1)
            break;
        default: break;
        }
    }
    
    fileprivate func setupNotificationsButton() {
        guard let podcast = podcast else { return }
        if podcast.notificationsEnabled {
            notificationsButton.tintColor = .appleGreen
            notificationsButton.setImage(UIImage(named: "notification_on"), for: .normal)
        } else {
            notificationsButton.tintColor = .ibmBlue
            notificationsButton.setImage(UIImage(named: "notification_off"), for: .normal)
        }
    }
    
    
    //MARK:- Handling Subscribe
    @objc fileprivate func handleSubscribe() {
        
        subscribeButton.backgroundColor = .lightGray
        guard let podcastModel = podcastModel, let image = podcastImageView.image else { return }
        
        
        NetworkAPI.shared.uploadNewSubscription(podcast: podcastModel) { (err) in
            if let err = err {
                print("Failed to upload new subscription", err)
                return
            }
            
            CoreDataManager.shared.saveNewPodcast(podcastModel: podcastModel, image: image) { (podcast, error) in
                self.delegate?.didSubscribeToNew(podcast: podcast)
                self.subscriptionChangesDelegate?.subscribedToNew(podcast: podcast)
                DispatchQueue.main.async {
                    self.subscribeButton.isHidden = true
                    self.settingsButton.isHidden = false
                }
            }
            
        }

    }
    
    @objc fileprivate func handleSettings() {
        delegate?.didTapSettings()
    }
    
    fileprivate func setupLayout() {
        backgroundColor = .white
        
        addSubview(podcastImageView)
        [
            podcastImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            podcastImageView.heightAnchor.constraint(equalToConstant: 200),
            podcastImageView.widthAnchor.constraint(equalToConstant: 200),
            podcastImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
            ].forEach { $0.isActive = true }
        
        addSubview(podcastTitleLabel)
        [
            podcastTitleLabel.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 14),
            podcastTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
            podcastTitleLabel.topAnchor.constraint(equalTo: podcastImageView.topAnchor),
            ].forEach { $0.isActive = true }
        
        addSubview(artistLabel)
        [
            artistLabel.topAnchor.constraint(equalTo: podcastTitleLabel.bottomAnchor, constant: 5),
            artistLabel.leftAnchor.constraint(equalTo: podcastTitleLabel.leftAnchor, constant: 5),
            artistLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
            ].forEach { $0.isActive = true }
        
        addSubview(weekdayText)
        [
            weekdayText.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 5),
            weekdayText.leftAnchor.constraint(equalTo: artistLabel.leftAnchor, constant: 5),
            weekdayText.rightAnchor.constraint(equalTo: rightAnchor, constant: -5)
            ].forEach { $0.isActive = true }
        
        let subscribedStackView = UIStackView(arrangedSubviews: [notificationsButton, settingsButton])
        subscribedStackView.translatesAutoresizingMaskIntoConstraints = false
        subscribedStackView.distribution = .fillEqually
        
        addSubview(subscribedStackView)
        [
            subscribedStackView.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 14),
            subscribedStackView.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            subscribedStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            subscribedStackView.heightAnchor.constraint(equalToConstant: 44)
            ].forEach { $0.isActive = true }
        
        addSubview(activityIndicator)
        [
            activityIndicator.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 14),
            activityIndicator.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            activityIndicator.widthAnchor.constraint(equalToConstant: 54),
            activityIndicator.heightAnchor.constraint(equalToConstant: 44)
            ].forEach { $0.isActive = true }

        
        addSubview(subscribeButton)
        [
            subscribeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            subscribeButton.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 20),
            subscribeButton.heightAnchor.constraint(equalToConstant: 44),
            subscribeButton.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 14)
            ].forEach { $0.isActive = true }
        

        
        addSubview(segmentedController)
        [
            segmentedController.leftAnchor.constraint(equalTo: leftAnchor, constant: 14),
            segmentedController.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            segmentedController.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            segmentedController.heightAnchor.constraint(equalToConstant: 44)
            ].forEach { $0.isActive = true }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if let err = error {
                print("failed to request authorization: ", err)
                return
            }
            print("Authorization granted: \(granted ? "True" : "False")")
            self.toggleNotificationsActive()
        }
    }
    
    func toggleNotificationsActive() {
        guard let podcast = podcast else { return }
        
        DispatchQueue.main.async {
            self.notificationsButton.isEnabled = false
        }
        
        NetworkAPI.shared.toggleNotificationEnabled(for: podcast) { (err) in
            
            CoreDataManager.shared.updatePodcastWithNotifications(podcast, isEnabled: !podcast.notificationsEnabled) { (err) in
                if let err = err {
                    print("Failed to update podcast: ", err)
                    return
                }
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    self.setupNotificationsButton()
                    generator.notificationOccurred(.success)
                    self.notificationsButton.isEnabled = true
                }
            }
        }
        

    }
    
}

import UserNotifications
extension PodcastHeaderView {
    
    @objc func handleNotification() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.registerForNotifications()
                break
            case .authorized:
                self.toggleNotificationsActive()
            default: break
            }
        }
        
//        subscribed = !subscribed
//        if subscribed {
//            notificationsButton.setImage(UIImage(named: "notification_on"), for: .normal)
//            notificationsButton.tintColor = .appleGreen
//            generator.notificationOccurred(.success)
//        } else {
//            notificationsButton.setImage(UIImage(named: "notification_off"), for: .normal)
//            notificationsButton.tintColor = .ibmBlue
//            generator.notificationOccurred(.warning)
//        }
        
        
    }
    
}
