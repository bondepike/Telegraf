//
//  SearchCell.swift
//  Podcast
//
//  Created by Adrian Evensen on 20/02/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
protocol SearchCellDelegate {
    func updateCell(with indexPath: IndexPath)
}

class SearchCell: UITableViewCell {
    
    var delegate: SearchCellDelegate?
    
    var indexPath: IndexPath?
    
    var podcastModel: PodcastModel? {
        didSet {
            podcastTitleLabel.text = podcastModel?.trackName ?? ""
            artistNameLabel.text = podcastModel?.artistName ?? ""
            guard let imageUrl = podcastModel?.artworkUrl600 else { return }

            guard let url = URL(string: imageUrl), podcastImageView.image == nil else { return }

            URLSession.shared.dataTask(with: url) { (data, response, error) in

                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.podcastImageView.image = img
                }

                guard let indexPath = self.indexPath else { return }
                self.delegate?.updateCell(with: indexPath)
            }.resume()
        }
    }
    
    var podcast: Podcast? {
        didSet {
            subscribedLabel.text = "Subscribed"
        }
    }
    
    let podcastImageView: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 5
        img.clipsToBounds = true
        img.contentMode = .scaleAspectFill
        img.layer.shadowRadius = 5
        img.layer.shadowColor = UIColor.black.cgColor
        
        return img
    }()
    
    let podcastTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 18)
        label.numberOfLines = 2
        
        return label
    }()
    
    let artistNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Regular", size: 16)
        label.numberOfLines = 0
        label.textColor = UIColor.darkCreme
        
        return label
    }()
    
    let subscribedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 16)
        label.textColor = .ibmBlue
        
        return label
    }()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(podcastImageView)
        [
            podcastImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            podcastImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            podcastImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            podcastImageView.widthAnchor.constraint(equalToConstant: 134)
            ].forEach { $0.isActive = true }

        
        addSubview(podcastTitleLabel)
        [
            podcastTitleLabel.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 10),
            podcastTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            podcastTitleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            ].forEach { $0.isActive = true }
        
        
        addSubview(artistNameLabel)
        [
            artistNameLabel.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 10),
            artistNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            artistNameLabel.topAnchor.constraint(equalTo: podcastTitleLabel.bottomAnchor, constant: 5),
            ].forEach { $0.isActive = true }
        
        addSubview(subscribedLabel)
        [
            subscribedLabel.leftAnchor.constraint(equalTo: podcastImageView.rightAnchor, constant: 10),
            subscribedLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            subscribedLabel.topAnchor.constraint(equalTo: artistNameLabel.bottomAnchor, constant: 10)
            ].forEach { $0.isActive = true }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
