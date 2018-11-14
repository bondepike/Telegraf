//
//  HomeController+CollectionView.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 08/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

extension SubscriptionsController {
    
    //MARK:- CollectionView

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width/3
        
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts?.count ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FavoritesCell
        cell.backgroundColor = .purple
        if let podcast = self.podcasts?[indexPath.row], let artwork = podcast.artwork {
            cell.podcastImage.image = UIImage(data: artwork)
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let podcast = podcasts?[indexPath.row], let imageData = podcast.artwork else { return }
        let podcastController = PodcastController()
        let image = UIImage(data: imageData)
        podcastController.image = image
        podcastController.podcast = podcast
        podcastController.subscriptionChangesDelegate = self
        
        if podcast.episodes?.allObjects.count == 0 {
            podcastController.index = 1
        }
        
        
        navigationController?.pushViewController(podcastController, animated: true)
    }
    
    
    //MARK:- Footer
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let podcasts = podcasts else { return CGSize(width: view.frame.width, height: 0 )}
        if podcasts.isEmpty {
            return CGSize(width: view.frame.width, height: view.frame.height/3)
        }
        return CGSize(width: view.frame.width, height: 0)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerId", for: indexPath) as! UICollectionViewCell
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "No Podcasts to see here.."
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textAlignment = .center
        
        footer.addSubview(titleLabel)
        [
            titleLabel.leftAnchor.constraint(equalTo: footer.leftAnchor, constant: 14),
            titleLabel.rightAnchor.constraint(equalTo: footer.rightAnchor, constant: -14),
            titleLabel.topAnchor.constraint(equalTo: footer.centerYAnchor)
            ].forEach { $0.isActive = true }
        
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Tap the pluss button to discover new \n and meow-zing, Podcasts"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 3
        subtitleLabel.textColor = UIColor.darkCreme
        
        footer.addSubview(subtitleLabel)
        [
            subtitleLabel.leftAnchor.constraint(equalTo: footer.leftAnchor, constant: 36),
            subtitleLabel.rightAnchor.constraint(equalTo: footer.rightAnchor, constant: -36),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            
            ].forEach { $0.isActive = true }
        
        return footer
    }
    
    
}
