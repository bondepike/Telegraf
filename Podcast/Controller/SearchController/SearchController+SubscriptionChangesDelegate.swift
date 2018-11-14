//
//  SearchController+SubscriptionChangesDelegate.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 10/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation


extension SearchController: SubscriptionChangesDelegate {
    //MARK:- SubscriptionChangesDelegate
    func subscribedToNew(podcast: Podcast?) {
        CoreDataManager.shared.fetchAllPodcasts { [unowned self] podcasts in
            self.podcasts = podcasts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.subscriptionChangesDelegate?.subscribedToNew(podcast: podcast)
        }
    }
}
