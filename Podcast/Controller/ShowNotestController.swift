//
//  ShowNotestController.swift
//  Podcast
//
//  Created by Adrian Evensen on 06/10/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
import WebKit

class ShowNotesController: UIViewController {
    
    let webView: WKWebView = {
        let wv = WKWebView()
        wv.translatesAutoresizingMaskIntoConstraints = false
        
        return wv
    }()
    
    let style = "<style>*{font-size: 46px; font-family: Helvetica, Arial, Sans-Serif; a{ color: #1050D6; } img { min-width: 50%; min-height: 30%; } body{padding: 15px;}</style>"
    
    var episode: Episode? {
        didSet {
            var head = "<div><h1>\(episode?.name ?? "")</h1></div>"
            head += style

            if let content = episode?.content {
                head += "<body>"
                head += content
                head += "</body>"
                webView.loadHTMLString(head, baseURL: nil)
                return
            }
            guard var description = episode?.episodeDesciption else { return }
            description += style
            webView.loadHTMLString(description, baseURL: nil)
        }
    }
    
    var internetEpisode: EpisodeModel? {
        didSet {
            var head = "<div><h1>\(episode?.name ?? "")</h1></div>"
            head += style

            if let content = internetEpisode?.content, content != "" {
                head += style
                webView.loadHTMLString(head, baseURL: nil)
                return
            }
            guard var description = internetEpisode?.description else { return }
            description += style
            webView.loadHTMLString(description, baseURL: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Show Notes"
        view.backgroundColor = .white
        
        view.addSubview(webView)
        [
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ].forEach { $0.isActive = true }
        
    }
}
