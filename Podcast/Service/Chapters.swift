//
//  Chapters.swift
//  Podcast
//
//  Created by Adrian Evensen on 20/11/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation


class Chapters {
    
    init(path: URL) {
        let asset = AVAsset(url: path)
        print(asset.availableMetadataFormats)
        
        let format = AVMetadataFormat.init(rawValue: "org.id3")
        let arr = asset.metadata(forFormat: format)
        //print(arr)
        
        let chapts = AVMetadataItem.metadataItems(from: arr, withKey: "CHAP", keySpace: AVMetadataKeySpace(rawValue: "org.id3"))
        
        for item in chapts {
            guard let data = item.dataValue else { return }
            //print(String(bytes: data, encoding: .ascii))
        }
    }
    
}
