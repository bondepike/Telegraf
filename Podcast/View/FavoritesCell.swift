//
//  FavoritesCell.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class FavoritesCell: UICollectionViewCell {
    
    let podcastImage: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        
        return img
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        addSubview(podcastImage)
        [
            podcastImage.leftAnchor.constraint(equalTo: leftAnchor),
            podcastImage.rightAnchor.constraint(equalTo: rightAnchor),
            podcastImage.topAnchor.constraint(equalTo: topAnchor),
            podcastImage.bottomAnchor.constraint(equalTo: bottomAnchor)
            ].forEach { $0.isActive = true }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
