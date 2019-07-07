//
//  NetworkAPI.swift
//  Podcast
//
//  Created by Silje Marie Flaaten on 2/22/18.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
//import Alamofire

typealias HTTPHeaders = [String : String]

class NetworkAPI: NSObject, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    static let shared = NetworkAPI()
    private let host = "https://telegraf.adrianf.no"
    var activeDownloads = [String : Episode]()
    
}

struct FeedEpisode: Decodable {
    var Podcast: String?
    var Name: String?
    var PubDate: String?
}

extension NetworkAPI {
    func fetchFeed(completion: @escaping ([[FeedEpisode]]) -> ()){
        guard let url = URL(string: "\(host)/feed") else { return }
        //guard let url = URL(string: "http://localhost:8000/feed") else { return }
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        do {
            var req = URLRequest(url: url)
            req.addValue(jwt, forHTTPHeaderField: "Json-Web-Token")
            req.httpMethod = "POST"
            URLSession.shared.dataTask(with: req) { (data, response, err) in
                if let err = err {
                    print("Failed to make /feed request: ", err)
                    return
                }
                
                guard let data = data else { return }
                do {
                    let decoded = try JSONDecoder().decode([[FeedEpisode]].self, from: data)
                    completion(decoded)
                } catch let err {
                    print(err)
                }
                guard let response = response as? HTTPURLResponse else { return }
                }.resume()
        } catch let err {
            print(err)
            return
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
            var req = URLRequest(url: url)
            req.httpMethod = "POST"
            req.addValue(jwt, forHTTPHeaderField: "Json-Web-Token")
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
            guard let url = URL(string: "\(host)/notify") else { return }
            let urlRequest = URLRequest(url: url)
            // TODO: Add headers to request (see above)
            
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
    
    func uploadNewSubscription(podcast: PodcastsDataSource, completion: @escaping (Error?) -> ()) {
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
            "Feed": podcast.feed ?? ""
        ]
        
        do {
            guard let url = URL(string: "\(host)/subscribe") else { return }
            let urlRequest = URLRequest(url: url)
            
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
    
    func unsubscribe(podcast: PodcastsDataSource, completion: @escaping () -> ()) {
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        
        let headers: HTTPHeaders = [
            "Json-Web-Token" : jwt,
            "Feed": podcast.feed ?? ""
        ]
        
        do {
            guard let url = URL(string : "\(host)/unsubscribe") else { return }
            let urlRequest = URLRequest(url: url)
            URLSession.shared.dataTask(with: urlRequest) { (data, resp, err) in
                if let err = err {
                    print("Failed to unsubscribe: ", err)
                }
                completion()
            }.resume()
        } catch let err {
            print(err)
        }
    }
    
    func uploadDeviceToken(deviceToken: String) {
        
        guard let jwt = UserDefaults.standard.string(forKey: "jwt") else { return }
        
        let headers: HTTPHeaders = [
            "Json-Web-Token": jwt,
            "Device-Token": deviceToken
        ]
        do {
            guard let url = URL(string: "\(host)/device-token") else { return }
            let urlRequest = URLRequest(url: url)
            
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
    
    func downloadEpisode(episode: Episode, episodeModel: EpisodeDataSource, completionHandler: @escaping()->()) {
        guard var name = episode.name else { return }
        name = name.replacingOccurrences(of: " ", with: "")
        
        let config = URLSessionConfiguration.background(withIdentifier: "no.adrianf.telegraf.background.\(name)")
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: episodeModel.episodeUrl ?? "") else { return }
        
        guard let _ = episode.podcast else { return }
        activeDownloads[name] = episode
        
        session.downloadTask(with: url).resume()
    }
}

extension NetworkAPI {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard var name = session.configuration.identifier else { return }
        name = name.replacingOccurrences(of: "no.adrianf.telegraf.background.", with: "")
        
        let podcast = activeDownloads[name]?.podcast
        var podcastName = podcast?.name ?? "unknown"
        podcastName = podcastName.replacingOccurrences(of: " ", with: "_")
        
        let documentFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let lastUrlPath = downloadTask.originalRequest?.url?.lastPathComponent else { return }
        guard let newLocation = documentFolder.first?.appendingPathComponent("\(podcastName)/\(lastUrlPath)") else { return }
        
        if FileManager.default.fileExists(atPath: newLocation.relativePath) {
            do {
                try FileManager.default.removeItem(at: newLocation)
            } catch let err {
                print("Failed to delete file!",  err)
                return
            }
        }
        
        guard let folderLocation = documentFolder.first?.appendingPathComponent(podcastName) else { return }
        var exists: ObjCBool = false
        if !FileManager.default.fileExists(atPath: folderLocation.relativePath, isDirectory: &exists) {
            do {
                try FileManager.default.createDirectory(at: folderLocation, withIntermediateDirectories: true, attributes: nil)
            } catch let err {
                print(err)
                return
            }
        }
        
        do {
            try FileManager.default.moveItem(at: location, to: newLocation)
        } catch let err {
            print("Failed to move file!",  err)
            return
        }
        
        guard let episode = activeDownloads[name] else { return }
        let duration = saveEpisodePath(episode: episode, path: newLocation, name: podcastName)
        
        NotificationCenter.default.post(name: .handleDownloadFinished, object: nil, userInfo: [
            "name":name,
            "length": duration
            ])
        
        activeDownloads[name] = nil
        
    }
    
    func saveEpisodePath(episode: Episode, path: URL, name: String) -> Float64 {
        
        let context = CoreDataManager.shared.persistentContainer.viewContext
        
        let pathComponents = path.pathComponents
        var episodePath = ""
        episodePath.append(contentsOf: pathComponents[pathComponents.count-2])
        episodePath.append(contentsOf: "/")
        episodePath.append(contentsOf: pathComponents[pathComponents.count-1])
        print(episodePath)
        
        episode.lastLocalPathCompoenent = episodePath
        
        let asset = AVURLAsset(url: path)
        let assetDuration = asset.duration
        let assetDurationSeconds = CMTimeGetSeconds(assetDuration)
        episode.timeLength = assetDurationSeconds
        episode.downloadProgress = 100
        
        do {
            try context.save()
        } catch let error {
            print("failed to save local path: ", error)
        }

        return assetDurationSeconds
    }
    

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = (Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)*100)
        
        NotificationCenter.default.post(name: .handleDownloadProgress, object: nil, userInfo: [
            "identifier":session.configuration.identifier ?? "UNKNOWN",
            "progress":progress
            ])
    }
}
