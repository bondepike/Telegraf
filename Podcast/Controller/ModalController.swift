//
//  LoginController.swift
//  Podcast
//
//  Created by Adrian Evensen on 03/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit
protocol ModalControllerDelegate {
    func dismiss()
    func panDidUpdate(gesture: UIPanGestureRecognizer)
    func animateDismiss(translation: CGFloat)
}
class ModalController: UINavigationController {
    
    var modalControllerDelegate: ModalControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        view.addGestureRecognizer(panGesture)
    }
}

//MARK:- Gestures
extension ModalController {
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        modalControllerDelegate?.panDidUpdate(gesture: gesture)
    }
}
