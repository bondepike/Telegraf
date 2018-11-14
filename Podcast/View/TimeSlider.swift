//
//  TimeSlider.swift
//  Podcast
//
//  Created by Adrian Evensen on 04/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

class TimeSlider: UISlider {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setThumbImage(#imageLiteral(resourceName: "knob"), for: .normal)
        
        //minimumValueImageRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: 2, height: 2))
        maximumValueImageRect(forBounds: CGRect(x: frame.origin.x, y: frame.origin.y, width: 2, height: 2))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        minimumTrackTintColor = .applePink

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        minimumTrackTintColor = .lightGray

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        minimumTrackTintColor = .lightGray

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
