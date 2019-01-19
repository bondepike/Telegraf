//
//  EpisodesCell.swift
//  Podcast
//
//  Created by Adrian Evensen on 24/02/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {
    
    let episodeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 14)
        label.textColor = .graySuit
        
        return label
    }()
    
    let episodeSubtitle: UILabel = {
        let label = UILabel()
        label.textColor = .graySuit
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "IBMPlexSans", size: 14)
        label.textAlignment = NSTextAlignment.natural
        
        return label
    }()

    
    let timeRemainingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .graySuit
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans", size: 12)
        label.textAlignment = .center
        
        return label
    }()
    
    let doneLabel: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "done"))
        iv.tintColor = .graySuit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isHidden = true
        
        return iv
    }()
    
    let progressView: UIView = {
        let progressView = UIView()
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
    }()
    
    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "IBMPlexSans-Bold", size: 12)
        label.textColor = .graySuit
        return label
    }()
    
    
    lazy var downloadProgressShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 16, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.graySuit.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        
        return shapeLayer
    }()
    
    let elapsedTimeProgressShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 16, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.graySuit.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.isHidden = true

        return shapeLayer
    }()
    
    var podcast: Podcast?
    
    var episodeDataSource: EpisodeDataSource? {
        didSet {
            setupLabels()
            if let _ = episodeDataSource?.episode {
                episodeTitle.textColor = .kindaBlack
                episodeSubtitle.textColor = .kindaBlack
                setupProgress()
            } else {
                //guard let podcast = podcast else { return }
                //guard let history = podcast.history?.allObjects as? [History] else { return }
                if episodeDataSource?.inHistory ?? false {
                    doneLabel.isHidden = false
                }
            }
        }
    }
    
    
    fileprivate func setupLabels() {
        var string: String?
        
        if let str = episodeDataSource?.subtitle, str.count > 0 {
            string = str
        } else {
            string = episodeDataSource?.description
        }
        
        if let data = string?.data(using: .unicode) {
            do {
                let encodedString = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
                episodeSubtitle.text = encodedString
            } catch {
                episodeSubtitle.text = string
            }
        }
        
        episodeTitle.text = episodeDataSource?.name
        setupDateLabel()
    }
    
    fileprivate func setupDateLabel() {
        guard let date = episodeDataSource?.releaseDate else { return }
        
        let formatter = DateFormatter()
        let hoursSinceRelease = Date().timeIntervalSince(date) / 3600
        
        if hoursSinceRelease < 24 {
            releaseDateLabel.text = "Today"
            return
        } else if hoursSinceRelease < 48 {
            releaseDateLabel.text = "Yesterday"
            return
        } else if hoursSinceRelease < 168 {
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "en_US")
            
            releaseDateLabel.text = "\(formatter.string(from: date))  (\(Int(hoursSinceRelease / 24)) days ago)"
            return
        }
        
        formatter.dateFormat = "dd MMM YYYY"
        releaseDateLabel.text = "\(formatter.string(from: date))"
    }
    
    func setupProgress() {
        guard let localEpisode = episodeDataSource?.episode else { return }
        if localEpisode.downloadProgress < 1 {
            isUserInteractionEnabled = false
            let percentage = Int(localEpisode.downloadProgress*100)
            timeRemainingLabel.text = "\(percentage)%"
            DispatchQueue.main.async {
                self.downloadProgressShapeLayer.strokeEnd = CGFloat(localEpisode.downloadProgress)
            }
        } else {
            updateRemainingStatus()
        }
    }
    

    fileprivate func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateRemainingStatus), name: .elapsedTimeProgress, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .handleDownloadProgress, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadStarted), name: .handleDownloadStarted, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadFinished), name: .handleDownloadFinished, object: nil)
    }
    
    
    //MARK:- Init, Layout
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //updateRemainingStatus()
        setupObservers()
        setupLayout()
    }
    
    fileprivate func setupLayout() {
        addSubview(episodeTitle)
        [
            episodeTitle.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            episodeTitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            episodeTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            episodeTitle.heightAnchor.constraint(equalToConstant: 20)
            ].forEach { $0.isActive = true }
        
        addSubview(releaseDateLabel)
        [
            releaseDateLabel.topAnchor.constraint(equalTo: episodeTitle.bottomAnchor, constant: 2),
            releaseDateLabel.leftAnchor.constraint(equalTo: episodeTitle.leftAnchor, constant: 10),
            releaseDateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            releaseDateLabel.heightAnchor.constraint(equalToConstant: 15)
            ].forEach { $0.isActive = true }
        
        addSubview(progressView)
        [
            progressView.leftAnchor.constraint(equalTo: leftAnchor, constant: 33),
            progressView.widthAnchor.constraint(equalToConstant: 33),
            progressView.heightAnchor.constraint(equalToConstant: 33),
            progressView.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 26),
            //progressView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
            ].forEach { $0.isActive = true }
        
        addSubview(doneLabel)
        [
            doneLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            doneLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 10),
            doneLabel.widthAnchor.constraint(equalToConstant: 33),
            doneLabel.heightAnchor.constraint(equalToConstant: 33)
            ].forEach { $0.isActive = true }
        
        progressView.layer.addSublayer(downloadProgressShapeLayer)
        progressView.layer.addSublayer(elapsedTimeProgressShapeLayer)
        
        progressView.addSubview(timeRemainingLabel)
        [
            timeRemainingLabel.leftAnchor.constraint(equalTo: leftAnchor),
            timeRemainingLabel.rightAnchor.constraint(equalTo: progressView.rightAnchor),
            timeRemainingLabel.bottomAnchor.constraint(equalTo: progressView.bottomAnchor)
            
            ].forEach { $0.isActive = true }
        
        
        addSubview(episodeSubtitle)
        [
            episodeSubtitle.leftAnchor.constraint(equalTo: progressView.rightAnchor, constant: 7),
            episodeSubtitle.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
            episodeSubtitle.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 5),
            episodeSubtitle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10),
            //episodeSubtitle.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
            ].forEach { $0.isActive = true }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
