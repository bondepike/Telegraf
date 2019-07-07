//
//  SubscriptionChanges.swift
//  Podcast
//
//  Created by Adrian Evensen on 16/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation

@objc protocol SubscriptionChangesDelegate: class {
    
    ///Updates UI to represent state where a new podcast has beed **added** to CoreData
    func subscribedToNew(podcast: Podcast?)
    
    ///Updates UI to represent state where a new podcast has beed **removed** from CoreData
    func deletedPodcast()
}
