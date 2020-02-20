//
//  FeedHeaderView.swift
//  Podcast
//
//  Created by Adrian Evensen on 27/01/2019.
//  Copyright © 2019 AdrianF. All rights reserved.
//

import UIKit

class FeedHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        clipsToBounds = true
        textColor = .applePink
        backgroundColor = .white
        font = UIFont(name: "IBMPlexSans-Bold", size: 18)
        
    }

    override var intrinsicContentSize: CGSize {
        let originalSize = super.intrinsicContentSize
        let height = originalSize.height + 10
        let width = originalSize.width + 22
        
        layer.cornerRadius = height/2.2
        
        return CGSize(width: width, height: height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
