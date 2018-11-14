//
//  NetworkAPI.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 2/22/18.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit
import CloudKit

class NetworkAPI: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    
    static let shared = NetworkAPI()
    private let host = "https://telegraf.adrianf.no/"
    
    //typealias HTTPHeaders = [String: Any]
    //private let host = "http://localhost:8000"


}

extension NetworkAPI {
    func fetchEpisodesFeed(feedURL: URL, completionHandler: @escaping (RSSFeed) -> ()) {
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: feedURL)// else { return }
            guard let feed = parser.parse().rssFeed else { return }
            completionHandler(feed)
        }
    }
    
    func fetchPodcasts(with searchText: String, completionHandler: @escaping ([PodcastModel]?, Error?) -> ()) {
        
        let formattedSearchText = searchText.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://itunes.apple.com/search?term="+formattedSearchText+"&media=podcast") else { return }
        
        fetchGenericData(url: url) { (podcastModel: SearchResult) in
            completionHandler(podcastModel.results, nil)
        }
    }
    
    fileprivate struct CreateUserResponse: Decodable {
        var jwt: String?
    }
    
    func fetchJWT(completionHandler: @escaping (String) -> ()) {
    
//        let predicate = NSPredicate(value: true)
//        let query = CKQuery(recordType: "details", predicate: predicate)
//        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, err) in
//            if let err = err {
//                print("Failed to fetch zone: ", err)
//                return
//            }
//            print(records)
//        }
        
        guard let url = URL(string: "\(host)/signup") else { return }
        fetchGenericData(url: url) { (res: CreateUserResponse) in
            completionHandler(res.jwt ?? "")
        }
    }
    
    func checkJWTValidation(completion: @escaping (Bool) -> ()) {
        guard let url = URL(string: "\(host)/jwt/valid") else { return }
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
        ]
        
        do {
            let req = try URLRequest(url: url, method: .post, headers: headers)
            
            URLSession.shared.dataTask(with: req) { (data, response, err) in
                if let err = err {
                    print("Failed to make /jwt/valid request: ", err)
                    return
                }
                
                guard let response = response as? HTTPURLResponse else { return }
                
                completion(response.statusCode == 200)
                
            }.resume()
            
        } catch let err {
            print(err)
            return
        }
        
        
    }
    
    fileprivate func fetchGenericData<T: Decodable>(url: URL, completionHandler: @escaping (T) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err0r = error {
                print(err0r)
                return
            }
            guard let res = response as? HTTPURLResponse else { return }
            guard res.statusCode == 200 else {
                print("Status code is not 200")
                return
            }
            guard let data = data else { return }
            do {
                let obj = try JSONDecoder().decode(T.self, from: data)
                completionHandler(obj)
            } catch let error {
                print(error)
                return
            }
            }.resume()
    }
    
}


extension NetworkAPI {
    
    enum NetworkError: Error {
        case failed
        case wrongStatusCode
    }

    func toggleNotificationEnabled(for podcast: Podcast, completion: @escaping (NetworkError?) -> ()) {
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
            "Feed": podcast.feed ?? "",
            "Enabled": String(!podcast.notificationsEnabled)
        ]
        
        do {
            let urlRequest = try URLRequest(url: "\(host)/notify", method: HTTPMethod.post, headers: headers)
            URLSession.shared.dataTask(with: urlRequest) { (data, response, err) in
                if let err = err {
                    print("Error: ", err)
                    completion(NetworkError.failed)
                    return
                }
                guard let resp = response as? HTTPURLResponse else {
                    completion(NetworkError.wrongStatusCode)
                    return
                }
                
                print("Status Code : ", resp.statusCode)
                completion(nil)
                
            }.resume()
            
        } catch let error {
            print(error)
        }
    }
    
    func uploadNewSubscription(podcast: PodcastModel, completion: @escaping (Error?) -> ()) {
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
            "Feed": podcast.feedUrl ?? ""
        ]
        do {
            let urlRequest = try URLRequest(url: "\(host)/subscribe", method: HTTPMethod.post, headers: headers)
            URLSession.shared.dataTask(with: urlRequest) { (data, res, err) in
                guard let res = res as? HTTPURLResponse else { return }
                print("Status Code: ", res.statusCode)
                if res.statusCode != 200 {
                    print("Failed to post new podcast")
                }
                
                completion(err)
            }.resume()
        } catch let err {
            completion(err)
        }
    }
    
    func uploadDeviceToken(deviceToken: String) {
        
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
            "Device-Token": deviceToken
        ]
        do {
            let urlRequest = try URLRequest(url: "\(host)/device-token", method: HTTPMethod.post, headers: headers)
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                if let err = error {
                    print("Failed to push device token: ", err)
                    return
                }
                
                guard let res = response as? HTTPURLResponse else { return }
                guard res.statusCode == 200 else { return }
                
            }).resume()
        } catch let err {
            print("Failed to upload device token: ", err)
        }
    }
}

extension NetworkAPI {
    
    func download(episode: Episode, episodeModel: EpisodeModel) {
        let config = URLSessionConfiguration.background(withIdentifier: "no.adrianf.telegraf.\(episode.name ?? "unknown").background")
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: episodeModel.episodeUrl ?? "") else { return }
        let task = session.downloadTask(with: url)
        task.resume()
        
    }
    
    func downloadEpisode(episode: Episode, episodeModel: EpisodeModel, completionHandler: @escaping()->()) {
        
        guard var name = episode.name else { return }
        name = name.replacingOccurrences(of: " ", with: "")
        
        let config = URLSessionConfiguration.background(withIdentifier: "no.adrianf.telegraf.background.\(name)")
        
        
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        
        guard let url = URL(string: episodeModel.episodeUrl ?? "") else { return }
        print(episodeModel.episodeUrl)
        
        let task = session.downloadTask(with: url)
        
        task.resume()
        
        /*
        guard let fromLink = episodeModel?.episodeUrl, let url = URL(string: fromLink) else { return }
        let suggestedLocation = DownloadRequest.suggestedDownloadDestination()
        
        
        
        Alamofire.download(url, to: suggestedLocation).validate().downloadProgress { (progress) in
            
            //CORE DATA
            CoreDataManager.shared.updateEpisodeDownloadProgress(episode: episode, downloadProgress: progress.fractionCompleted)
            
            //Notify subscribers
            NotificationCenter.default.post(name: .handleDownloadProgress, object: episodeModel, userInfo: [
                "title":episodeModel?.name ?? "",
                "progress":progress.fractionCompleted
                ])
            
            }.response { (response) in
                if let error = response.error {
                    print("failed to download episode: ", error)
                    return
                }
                
                let context = CoreDataManager.shared.persistentContainer.viewContext
                episode.lastLocalPathCompoenent = response.destinationURL?.lastPathComponent
                do {
                    try context.save()
                    completionHandler()
                } catch let error {
                    print("failed to save local path: ", error)
                }
        }*/
    }
}

extension NetworkAPI {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard var name = session.configuration.identifier else { return }
        name = name.replacingOccurrences(of: "no.adrianf.telegraf.background.", with: "")
        
        let documentFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let lastUrlPath = downloadTask.originalRequest?.url?.lastPathComponent else { return }
        guard let newLocation = documentFolder.first?.appendingPathComponent(lastUrlPath) else { return }
        
        if FileManager.default.fileExists(atPath: newLocation.relativePath) {
            do {
                try FileManager.default.removeItem(at: newLocation)
            } catch let err {
                print("Failed to delete file!",  err)
                return
            }
        }
        
        do {
            try FileManager.default.moveItem(at: location, to: newLocation)
            NotificationCenter.default.post(name: .handleDownloadFinished, object: newLocation, userInfo: [
                "name":name
                ])
        } catch let err {
            print("Failed to move file!",  err)
        }
        
        try? FileManager.default.removeItem(at: location)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)*100)
        
        NotificationCenter.default.post(name: .handleDownloadProgress, object: nil, userInfo: [
            "identifier":session.configuration.identifier ?? "UNKNOWN",
            "progress":progress
            ])
    }
}















