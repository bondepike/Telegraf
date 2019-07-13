//
//  FeedEpisode.swift
//  Podcast
//
//  Created by Adrian Evensen on 18/01/2019.
//  Copyright © 2019 AdrianF. All rights reserved.
//

import UIKit

class FeedEpisodeCell: UITableViewCell {
    
    let podcastImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 5
        return iv
    }()
    
    let episodeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .kindaBlack
        label.numberOfLines = 2
        return label
    }()
    
    fileprivate let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .graySuit
        return label
    }()
    
    var episodeDataSource: EpisodeDataSource? {
        didSet {
            if let artwork = episodeDataSource?.podcast?.artwork {
                podcastImage.image = UIImage(data: artwork)
            }
            episodeTitle.text = episodeDataSource?.name
            setupStatusLabel()
        }
    }
    
    fileprivate func setupStatusLabel() {
        if let episode = episodeDataSource?.episode {
            let timeRemaining = Int((episode.timeLength - episode.timeElapsed)/60)
            statusLabel.text = "\(timeRemaining)m remaining"
        } else if episodeDataSource?.inHistory ?? false {
            statusLabel.text = "done"
            episodeTitle.textColor = .graySuit
            podcastImage.alpha = 0.5
        } else {
            statusLabel.text = ""
            episodeTitle.textColor = .kindaBlack
            podcastImage.alpha = 1

        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        addSubview(podcastImage)
        [
            podcastImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            podcastImage.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            podcastImage.heightAnchor.constraint(equalToConstant: 60),
            podcastImage.widthAnchor.constraint(equalToConstant: 60),
            podcastImage.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -5)
            ].forEach { $0.isActive = true }
        
        addSubview(episodeTitle)
        [
            episodeTitle.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 10),
            episodeTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -24),
            episodeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10)
            ].forEach { $0.isActive = true }
        
        addSubview(statusLabel)
        [
            statusLabel.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 10),
            statusLabel.topAnchor.constraint(equalTo: episodeTitle.bottomAnchor, constant: 5),
            statusLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            statusLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
            ].forEach { $0.isActive = true }
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
