//
//  SearchController+Search.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 10/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

extension SearchController: UISearchBarDelegate {
    //MARK:- Search functionality
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
            self.searchiTunes(searchText: searchText)

        }
    }
    
    func searchiTunes(searchText: String) {
        NetworkAPI.shared.fetchPodcasts(with: searchText) { (podcasts, error) in
            if let err = error {
                print(err)
            }
            guard let podcasts = podcasts else { return }
            self.podcastModels = podcasts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
