//
//  EpisodesTableController.swift
//  Podcast
//
//  Created by Adrian Evensen on 19/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import UserNotifications

class PodcastController: UITableViewController, PodcastHeaderViewDelegate {

    var image: UIImage?
    var refreshing = false
    var index = 0
    var subscriptionChangesDelegate: SubscriptionChangesDelegate?

    lazy var headerView: PodcastHeaderView = {
        let view = PodcastHeaderView()
        view.podcastImageView.image = image
        view.segmentedController.selectedSegmentIndex = index
        view.subscriptionChangesDelegate = subscriptionChangesDelegate
        view.delegate = self
        
        return view
    }()
    
    lazy var notifyButton = UIBarButtonItem(image: UIImage(named: "notification_on"), style: .plain, target: self, action: #selector(registerForNotifications))
    lazy var subscribeButton = UIBarButtonItem(title: "Subscribe", style: .plain, target: self, action: #selector(handleSubscribe))
    
    //MARK:- Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView()

        tableView.tableFooterView = UIView()
        tableView.contentInset.bottom = 64
        navigationController?.isNavigationBarHidden = false

        setupSegmentController()
        setupToolbar()
    }
    
    deinit {
        Podcasts.shared.current = nil
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if tableView.contentOffset.y > headerView.podcastTitleLabel.frame.height + 15 {
            if navigationItem.title?.count ?? 0 == 0 {
                UIView.animate(withDuration: 0.7) {
                    self.navigationItem.title = Podcasts.shared.current?.name
                }
            }
        } else if navigationItem.title?.count ?? 0 > 0 {
            navigationItem.title = ""
        }
        
        
    }
}

//MARK:- Setup
extension PodcastController {
    func setupHeaderView() {
        tableView.tableHeaderView = headerView
        headerView.frame =  CGRect(x: 0, y: 0, width: view.frame.width, height: 240)
    }
    
    fileprivate func setupSegmentController() {
        if let podcast = Podcasts.shared.current?.podcast {
            Episodes.shared.set(podcast: podcast)
            
            if podcast.episodes?.allObjects.count == 0 {
                headerView.segmentedController.selectedSegmentIndex = 1
                segmentedControllerUpdatedIndex(index: 1)
            }
        } else {
            segmentedControllerUpdatedIndex(index: 1)
            headerView.segmentedController.selectedSegmentIndex = 1
        }

    }
    
    fileprivate func setupToolbar() {
        guard let _ = Podcasts.shared.current?.podcast else {
            setupSubscribe()
            return
        }
        
        setupNotificationsButton()
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "settings_36"), style: .plain, target: self, action: #selector(didTapSettings))
        settingsButton.tintColor = .graySuit
        
        navigationItem.rightBarButtonItems = [settingsButton, notifyButton]
    }
    
    fileprivate func setupSubscribe() {
        subscribeButton.tintColor = .ibmBlue
        subscribeButton.setTitleTextAttributes([NSAttributedStringKey.font : UIFont(name: "IBMPlexMono-Bold", size: 18)], for: .normal)
        navigationItem.rightBarButtonItem = subscribeButton
    }
}


//MARK:- Notification
extension PodcastController {
    func setupNotificationsButton() {
        guard let podcast = Podcasts.shared.current?.podcast else { return }
        
        if podcast.notificationsEnabled {
            notifyButton.image = UIImage(named: "notification_on")
            notifyButton.tintColor = .appleGreen
        } else {
            notifyButton.image = UIImage(named: "notification_off")
            notifyButton.tintColor = .graySuit
        }
    }
    
    @objc func registerForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if let err = error {
                print("failed to request authorization: ", err)
                return
            }
            self.toggleNotificationsActive()
        }
    }
    
    //TODO: Denne er dårlig
    func toggleNotificationsActive() {
        guard let podcast = Podcasts.shared.current?.podcast else { return }
        NetworkAPI.shared.toggleNotificationEnabled(for: podcast) { (err) in
            
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItems?[1].isEnabled = false
            }
            
            CoreDataManager.shared.updatePodcastWithNotifications(podcast, isEnabled: !podcast.notificationsEnabled) { (err) in
                if let err = err {
                    print("Failed to update podcast: ", err)
                    return
                }
                DispatchQueue.main.async {
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    self.navigationItem.rightBarButtonItems?[1].isEnabled = true
                    
                    self.setupNotificationsButton()
                    generator.notificationOccurred(.success)
                }
            }
        }
    }
}


//MARK:- Handlers
extension PodcastController {
    @objc fileprivate func handleSubscribe() {
        guard let podcast = Podcasts.shared.current, let image = headerView.podcastImageView.image else { return }
        NetworkAPI.shared.uploadNewSubscription(podcast: podcast) { (err) in
            if let err = err {
                print("Failed to upload new subscription", err)
                return
            }

            CoreDataManager.shared.saveNewPodcast(podcastModel: podcast, image: image) { (podcast, error) in
                guard let podcast = podcast else { return }
                Podcasts.shared.set(podcast: podcast)
                DispatchQueue.main.async {
                    //self.subscriptionChangesDelegate?.subscribedToNew(podcast: podcast)
                    self.setupToolbar()
                    NotificationCenter.default.post(name: .reloadPodcasts, object: nil)
                }
            }
        }
    }
}


//MARK:- EpisodesHeaderDelegate
extension PodcastController {
    func didSubscribeToNew(podcast: Podcast?) {
        
    }
    
    @objc func didTapSettings() {
        let podcastSettings = UIAlertController(title: "Settings", message: "Only this podcast will be affected", preferredStyle: .actionSheet)
        
        podcastSettings.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] (_) in
            guard let podcastDataSource = Podcasts.shared.current else { return }
            guard let podcast = Podcasts.shared.current?.podcast else { return }
            
            NetworkAPI.shared.unsubscribe(podcast: podcastDataSource, completion: {
                CoreDataManager.shared.deletePodcast(podcast: podcast, completionHandler: {
                    DispatchQueue.main.async {
                        self.subscriptionChangesDelegate?.deletedPodcast()
                        NotificationCenter.default.post(name: .reloadPodcasts, object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            })
        }))
        
        podcastSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(podcastSettings, animated: true, completion: nil)
    }
    
    func segmentedControllerUpdatedIndex(index: Int) {
        switch index {
        case 0:
            guard let podcast = Podcasts.shared.current?.podcast else { return }
            Episodes.shared.set(podcast: podcast)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        case 1:
            guard let url = URL(string: Podcasts.shared.current?.feed ?? "") else { return }
            self.refreshing = true
            self.tableView.reloadData()
            Episodes.shared.set(url: url) {
                self.refreshing = false
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        default:
            break
        }
    }
}
