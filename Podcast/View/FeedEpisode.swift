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
        return label
    }()
    
    fileprivate let remainingTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var episodeDataSource: EpisodeDataSource? {
        didSet {
            
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
            podcastImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
            ].forEach { $0.isActive = true }
        
        addSubview(episodeTitle)
        [
            episodeTitle.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 10),
            episodeTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -24),
            episodeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10)
            ].forEach { $0.isActive = true }
        
        addSubview(remainingTime)
        [
            remainingTime.leftAnchor.constraint(equalTo: podcastImage.rightAnchor, constant: 10),
            remainingTime.topAnchor.constraint(equalTo: episodeTitle.bottomAnchor, constant: 10),
            remainingTime.rightAnchor.constraint(equalTo: rightAnchor, constant: -20)
            ].forEach { $0.isActive = true }
        
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
