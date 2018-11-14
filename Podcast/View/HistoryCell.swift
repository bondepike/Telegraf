//
//  HistoryCell.swift
//  Podcast
//
//  Created by Adrian Evensen on 22/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {
    
    let podcastImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 7
        return iv
    }()
    
    let episodeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.shared.regularFont
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        
        return label
    }()
    
    let timeRemainingLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.shared.boldFont
        label.textColor = UIColor.ibmBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let timeAddedLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.shared.regularFont
        label.textColor = .darkCreme
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var episode: Episode? {
        didSet {
            guard let episode = episode else { return }
            episodeTitleLabel.text = episode.name
            
            displayTimeRemaining()
            
            guard let artwork = episode.podcast?.artwork else { return }
            podcastImage.image = UIImage(data: artwork)
            
            if episode.downloadProgress != 1 {
                isUserInteractionEnabled = false
                
            }
        }
    }
    
    fileprivate func displayTimeRemaining() {
        guard let episode = episode else { return }
        guard episode.downloadProgress == 1 else {
            timeRemainingLabel.text = "Starting download"
            return
        }

        let elapsed = episode.timeElapsed
        let length = episode.timeLength
        let remaining = Int( (length-elapsed)/60 )
        timeRemainingLabel.text = "\(remaining) min remaining"
    }
    
    fileprivate func setupObservers() {
        guard episode?.downloadProgress != 1 else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .handleDownloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadFinished), name: .handleDownloadFinished, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleElapsedTimeUpdate), name: .elapsedTimeProgress, object: nil)
    }
    
    @objc fileprivate func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else { return }
        guard userInfo["title"] as? String ?? "" == episode?.name else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        
        let percentage = Int(progress*100)
        
        timeRemainingLabel.text = "\(percentage)%"
    }
    
    @objc fileprivate func handleDownloadFinished(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String : Any] else { return }
        guard userInfo["title"] as? String ?? "" == episode?.name else { return }
        
        isUserInteractionEnabled = true
        displayTimeRemaining()
    }
    
    @objc fileprivate func handleElapsedTimeUpdate(notification: Notification) {
        guard let episode = episode else { return }

        // fikser Fatal Error
        if episode.timeLength.isNaN == true {
            return
        }
        //let percentage = episode.timeElapsed / episode.timeLength
        let timeRemaining = Int((episode.timeLength - episode.timeElapsed)/60)
        
        timeRemainingLabel.text = "\(timeRemaining)min remaining"
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        
    }
    
    fileprivate func setupLayout() {
        setupObservers()
        
        addSubview(podcastImage)
        [
            podcastImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 4),
            podcastImage.topAnchor.constraint(equalTo: topAnchor, constant: 7),
            podcastImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            podcastImage.widthAnchor.constraint(equalToConstant: 142)
            ].forEach { $0.isActive = true }
        
        addSubview(episodeTitleLabel)
        [
            episodeTitleLabel.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 7),
            episodeTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -14),
            episodeTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 14)
            ].forEach { $0.isActive = true }
        
        addSubview(timeAddedLabel)
        [
            timeAddedLabel.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 14),
            timeAddedLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7),
            timeAddedLabel.topAnchor.constraint(equalTo: episodeTitleLabel.bottomAnchor, constant: 7),
            ].forEach { $0.isActive = true }
        
        addSubview(timeRemainingLabel)
        [
            timeRemainingLabel.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 14),
            timeRemainingLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7),
            timeRemainingLabel.topAnchor.constraint(equalTo: timeAddedLabel.bottomAnchor, constant: 7)
            ].forEach { $0.isActive = true }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
