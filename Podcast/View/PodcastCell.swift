//
//  FavoritesCell.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class PodcastCell: UICollectionViewCell {
    
    let podcastImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        
        return img
    }()
    
    let podcastTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        
        return label
    }()

    var podcast: Podcast? {
        didSet {
            guard let podcast = podcast, let artwork = podcast.artwork else { return }
            podcastImage.image = UIImage(data: artwork)
            podcastTitle.text = podcast.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(podcastImage)
        [
            podcastImage.leftAnchor.constraint(equalTo: leftAnchor),
            podcastImage.rightAnchor.constraint(equalTo: rightAnchor),
            podcastImage.topAnchor.constraint(equalTo: topAnchor),
            //podcastImage.heightAnchor.constraint(equalToConstant: frame.width-(2*const))
            podcastImage.bottomAnchor.constraint(equalTo: bottomAnchor)
            ].forEach { $0.isActive = true }
        
//        addSubview(podcastTitle)
//        [
//            podcastTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: const),
//            podcastTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -const),
//            podcastTitle.topAnchor.constraint(equalTo: podcastImage.bottomAnchor, constant: 5),
//            podcastTitle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
//        ].forEach { $0.isActive = true }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
