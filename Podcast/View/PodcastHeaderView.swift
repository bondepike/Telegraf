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
}

class PodcastHeaderView: UIView {
    weak var delegate: PodcastHeaderViewDelegate?
    weak var subscriptionChangesDelegate: SubscriptionChangesDelegate?
    
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
        label.textColor = .graySuit
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
    
    lazy var segmentedController: UISegmentedControl = {
        let segControl = UISegmentedControl(items: ["Downloads", "All Episodes"])
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.selectedSegmentIndex = 0
        segControl.addTarget(self, action: #selector(handleSegmentedControlChange), for: .valueChanged)
        segControl.tintColor = .applePink
        segControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "IBMPlexSans-Bold", size: 16) as Any], for: .normal)
        
        return segControl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupLabels()
    }
    
    fileprivate func setupLabels() {
        podcastTitleLabel.text = Podcasts.shared.current?.name
        artistLabel.text = Podcasts.shared.current?.artist
    }
    
    
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
    
    fileprivate func setupLayout() {
        backgroundColor = .white
        
        addSubview(podcastImageView)
        [
            podcastImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 14),
            podcastImageView.heightAnchor.constraint(equalToConstant: 140),
            podcastImageView.widthAnchor.constraint(equalToConstant: 140),
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

}
