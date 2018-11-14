//
//  PlayerViewController+Mp3Parser.swift
//  Podcast
//
//  Created by Adrian Evensen on 26/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import Foundation
import AVFoundation

/*
extension PlayerViewController {
    
    func printMp3Data(file: URL) {
        print("I got the file: ", file.lastPathComponent)
        
        
        
        let asset = AVURLAsset(url: file)
        let metadata = asset.metadata(forFormat: .id3Metadata)
        print(asset.chapterMetadataGroups(bestMatchingPreferredLanguages: ["English"]))
        var chapters = [String]()
        
        let chap = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: ["und (fixed)"])

        print("Count: ", chap.count)
        chap.forEach { (media) in
            print("items: ", media)
            media.items.forEach({ (item) in
                
            })
        }
        
        
        metadata.forEach { (item) in

            print(item)

            switch item.key {
            case .some( let Wrapped):
                if Wrapped.description == "CHAP" {
                    
                    
                    print("its a: ", Wrapped.description)
                    print("DATE: ", item.duration)
                    
                    
//                    guard let value = item.value, var valueData = value as? NSMutableData else { return }
//                    valueData.replaceBytes(in: NSMakeRange(0, 34), withBytes: nil, length: 0)
//                    print(NSString(bytes: valueData.bytes, length: valueData.length, encoding: String.Encoding.ascii.rawValue))

                }

            default: print("")
            }
        }
        
        
        
        
        
        
        
//        do {
//            let data = NSData(contentsOf: file)
//            print(data)
//            let bytes = data!.bytes.assumingMemoryBound(to: UInt8.self)
//
//            let str = NSString(bytes: bytes + 23, length: 2000, encoding: String.Encoding.ascii.rawValue) as! String
//            //String.Encoding.ascii.rawValue
//            print("\n \n")
//            print("----- START ------")
//            print(str)
//            print("------ END -------")
//            print("\n \n")
//
//        } catch let error {
//            print("Failed to get data from file: \n", error)
//        }
        
    }
    
    
}
*/
