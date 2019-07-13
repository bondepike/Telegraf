//
//  EpisodesCollectionController.swift
//  Podcast
//
//  Created by Adrian Evensen on 24/02/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import FeedKit

struct Episode {
    var name: String?
    var subtitle: String?
}


class EpisodesCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var image: UIImage?
    var podcastTitle: String?
    var artistNames: String?
    var episodeRelease: String?
    
    var episodes = [Episode]()
    
    var feedUrl: String? {
        didSet {
            guard let feed = feedUrl, let feedUrl = URL(string: feed) else { return }
            
            guard let parser = FeedParser(URL: feedUrl) else { return }
            
            parser.parseAsync(result: { (result) in
                switch result {
                case let .rss(feed):
                    self.handleFeed(feed: feed)
                    break;
                case let .failure(error):
                    print(error)
                default:
                    break;
                }
            })
            
        }
    }
    
    private func handleFeed(feed: RSSFeed) {
        let calendar = Calendar.current
        
        var week = [
            1 : 0,
            2 : 0,
            3 : 0,
            4 : 0,
            6 : 0,
            7 : 0
        ]
        
        feed.items?.forEach({ (item) in
            
            if item.iTunes?.iTunesSubtitle == nil {
                let episode = Episode(name: item.title, subtitle: item.description)
                episodes.append(episode)

            } else {
                let episode = Episode(name: item.title, subtitle: item.iTunes?.iTunesSubtitle)
                episodes.append(episode)
            }
            guard let date = item.pubDate else { return }
            let weekday = calendar.component(.weekday, from: date)
            if let _ = week[weekday] {
                week[weekday]! += 1
            }
            
            
            
        })
        
        var topValue = 0
        var topKey = 0
        week.forEach { (key, value) in
            if value > topValue {
                topValue = value
                topKey = key
            }
        }
        
        print("Most popular weekday: ", topKey)
        
        var weekdayText = "Publishes usually on "
        switch topKey {
        case 1:
            weekdayText += "Sundays"
        case 2:
            weekdayText += "Mondays"
        case 3:
            weekdayText += "Tuesdays"
        case 4:
            weekdayText += "Wednesdays"
        case 6:
            weekdayText += "Thursdays"
        case 6:
            weekdayText += "Friday"
        case 7:
            weekdayText += "Saturdays"
        default:
            break;
        }
        
        episodeRelease = weekdayText
        
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.register(EpisodesCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView?.register(EpisodesHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "face"), style: .plain, target: self, action: #selector(presentArtistsController))
    }
    
    @objc
    func presentArtistsController() {
        guard let artists = artistNames?.split(separator: ",") else { return }
        
        let artistsController = ArtistsController()
        
        artistsController.artistsRaw = artists
        
        navigationController?.pushViewController(artistsController, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! EpisodesCell
        
        print(episodes[indexPath.row].name)
        cell.episodeTitle.text = episodes[indexPath.row].name
        cell.episodeSubtitle.text = episodes[indexPath.row].subtitle
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        
        return CGSize(width: width, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! EpisodesHeaderView
        
        header.podcastTitleLabel.text = podcastTitle ?? ""
        header.podcastImageView.image = image ?? nil
        header.weekdayText.text = episodeRelease ?? ""
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
    
}
