//
//  CoreDataManager.swift
//  Podcast
//
//  Created by Adrian Evensen on 17/03/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PodcastModels")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("loading of store failed: \(error)")
            }
        })
        return container
    }()
    
    
    //MARK:- Update
    func updatePodcastWithNotifications(_ podcast: Podcast, isEnabled: Bool, completionHandler: (Error?) -> ()) {
        let context = persistentContainer.viewContext
        podcast.notificationsEnabled = isEnabled
        
        do {
            try context.save()
            completionHandler(nil)
        } catch let err {
            completionHandler(err)
        }
    }
    
    
    func updateEpisodeTimes(episode: Episode, elapsedTime: Double, episodeLength: Double, completionHandler: (Double)->()) {
        let context = persistentContainer.viewContext
        episode.timeElapsed = elapsedTime
        episode.timeLength = episodeLength
        
        do {
            try context.save()
            completionHandler(elapsedTime)
        } catch let error {
            print("failed to update episode time: \n", error)
        }
    }
    
    func updateEpisodeLength(episode: Episode, length: Double) {
        let context = persistentContainer.viewContext
        episode.timeLength = length
       
        do {
            try context.save()
            print("sucessfully saved length: ", length)
        } catch let error {
            print("failed to save length", error)
        }
    }
    
    func updateEpisodeDownloadProgress(episode: Episode, downloadProgress: Double) {
        let context = persistentContainer.viewContext
        episode.downloadProgress = downloadProgress
       
        do {
            try context.save()
        } catch let error {
            print("failed to update download progress", error)
        }
    }
    
    
    //MARK:- Save
    func saveNewPodcast(podcastModel: PodcastModel, image: UIImage, completionHandler: (Podcast?, Error?) -> ()) {
        let context = persistentContainer.viewContext
        let podcastEntity = NSEntityDescription.insertNewObject(forEntityName: "Podcast", into: context) as! Podcast
        podcastEntity.name = podcastModel.trackName ?? ""
        podcastEntity.feed = podcastModel.feedUrl ?? ""
        podcastEntity.artist = podcastModel.artistName ?? ""
        podcastEntity.artwork = UIImageJPEGRepresentation(image, 10)
        podcastEntity.notificationsEnabled = false
        do {
            try context.save()
            completionHandler(podcastEntity, nil)
        } catch let error {
            completionHandler(nil, error)
            print("failed to save new podcast: \n", error)
        }
    }
    
    func saveNewLocalEpisode(podcast: Podcast, episodeModel: EpisodeModel, lastPathComponent: String, completionHandler: (Episode) -> ()) {
        let context = persistentContainer.viewContext
        let episode = NSEntityDescription.insertNewObject(forEntityName: "Episode", into: context) as! Episode
        episode.name = episodeModel.name ?? ""
        episode.artist = episodeModel.artist ?? ""
        episode.subtitle = episodeModel.subtitle
        episode.releaseDate = episodeModel.pubDate
        episode.episodeDesciption = episodeModel.description
        episode.content = episodeModel.content
        episode.addedDate = Date()
        podcast.addToEpisodes(episode)
        
        if let history = podcast.history?.allObjects as? [History] {
            let exists = history.contains { (h) -> Bool in
                return h.name ?? "" == episode.name
            }
            if !exists {
                let history = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as! History
                history.name = episode.name ?? ""
                history.date = Date()
                podcast.addToHistory(history)
            }
        }
        
        do {
            try context.save()
            completionHandler(episode)
        } catch let error {
            print("failed to save new episode: ", error)
        }
    }
    
    /// Legger gitt episode i podcasten sin History.
    func addEpisodeToHistoryFor(_ podcast: Podcast, episode: Episode) {
        let context = persistentContainer.viewContext
        let history = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as! History
        history.name = episode.name ?? ""
        history.date = Date()
        
        do {
            try context.save()
        } catch let error {
            print("Failed to save history", error)
        }
    }
    
    //MARK:- Delete
    func deleteDownloadedEpisode(episode: Episode, completionHandler: @escaping()->()) {
        let context = persistentContainer.viewContext
        
        if let lastPathComponent = episode.lastLocalPathCompoenent {
            let documentFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let url = documentFolder.first?.appendingPathComponent(lastPathComponent) else { return }
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                print("failed to delete episode: ", error)
            }
        }
        
        if let podcast = episode.podcast {
            podcast.removeFromEpisodes(episode)
        }
        context.delete(episode)

        do {
            try context.save()
            completionHandler()
        } catch let error {
            print("failed to delete episode: ", error)
        }
    }
    
    func deleteAllPodcasts(completionHandler: ()->()) {
        let context = persistentContainer.viewContext
        let batchDelete = NSBatchDeleteRequest(fetchRequest: Podcast.fetchRequest())
        do {
            try context.execute(batchDelete)
            completionHandler()
        } catch let error {
            print("failed to delete all podcasts: \n", error)
        }
    }
    
    func deletePodcast(podcast: Podcast, completionHandler: () -> () ) {
        guard let episodes = podcast.episodes?.allObjects as? [Episode] else { return }
        episodes.forEach { (episode) in
            self.deleteDownloadedEpisode(episode: episode, completionHandler: {
                
            })
        }
        let context = persistentContainer.viewContext
        context.delete(podcast)
        
        do {
            try context.save()
            completionHandler()
        } catch let error {
            print("Failed to delete podcast: \n", error)
        }
    }
    
    //MARK:- Fetch
    func fetchAllPodcasts(completionHandler: @escaping ([Podcast]) -> ()) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Podcast>(entityName: "Podcast")
        do {
            let fetchedPodcast = try context.fetch(fetchRequest)
            completionHandler(fetchedPodcast)
        } catch let error {
            print("failed to fetch all podcasts from core data: \n", error)
        }
    }
    
    func fetchAllEpisodes(completionHandler: @escaping ([Episode]) ->()) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Episode>(entityName: "Episode")
        do {
            print("trying to fetch episodes")
            let fetchedEpisodes = try context.fetch(fetchRequest)
            print("sucess")
            completionHandler(fetchedEpisodes)
        } catch let error {
            print("failed to fetch episodes: ", error)
        }
    }
}
