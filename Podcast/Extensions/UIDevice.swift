//
//  UIDevice.swift
//  Podcast
//
//  Created by Adrian Evensen on 01/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

extension UIDevice {
    
    enum ScreenType {
        case iphone4
        case iphone5
        case iphone6
        case iphone6Pluss
        case iphoneX
        case unknown
    }
    
    static let screenType: ScreenType = {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iphone4
        case 1136:
            return .iphone5
        case 1334:
            return .iphone6
        case 1920, 2208:
            return .iphone6Pluss
        case 2436:
            return .iphoneX
        default: return .unknown
        }
    }()
}
