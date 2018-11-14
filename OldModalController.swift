//
//  ModalController.swift
//  Podcast
//
//  Created by Adrian Evensen on 03/06/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

//import UIKit
//
//protocol ModalControllerDelegate {
//    func didDismiss()
//}
//
//class ModalController: UINavigationController {
//
//    let dismissDragIndicator: UIView = {
//        let view = UIView()
//        view.backgroundColor = .lightGray
//        view.layer.cornerRadius = 3
//        view.clipsToBounds = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.isHidden = true
//
//        return view
//    }()
//
//    var lightContent = false
//
//    var minimizeConstraints: [NSLayoutConstraint]?
//    var maximizeConstraints: [NSLayoutConstraint]?
//
//    var modalDelegate: ModalControllerDelegate?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanDismissGesture))
//        view.addGestureRecognizer(gestureRecognizer)
//        view.backgroundColor = .white
//        navigationBar.shadowImage = UIImage()
//        setupLayout()
//    }
//
//    fileprivate func setupLayout() {
//        view.addSubview(dismissDragIndicator)
//        [
//            dismissDragIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: 14),
//            dismissDragIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            dismissDragIndicator.heightAnchor.constraint(equalToConstant: 5),
//            dismissDragIndicator.widthAnchor.constraint(equalToConstant: 46)
//            ].forEach { $0.isActive = true }
//    }
//
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        //guard lightContent else { return .default }
//        return .lightContent
//    }
//
//    deinit {
//        print("Deinitializing ModalController")
//    }
//
//}
//
//extension ModalController {
//    func setupPlayerView() {
//        let window = UIApplication.shared.keyWindow
//        window?.addSubview(self.view)
//
//        view.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: view.frame.height)
//        view.clipsToBounds = true
//    }
//
//    @objc func present() {
//        UIView.animate(withDuration: 0.4) {
//            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
//            statusBar?.alpha = 0.5
//        }
//        let window = UIApplication.shared.keyWindow
//        let rootViewController = window?.rootViewController as? UINavigationController
//
//        //self.playerView.dismissButton.isHidden = false
//        self.dismissDragIndicator.isHidden = false
//
//        self.minimizeConstraints?.forEach { $0.isActive = false }
//        self.maximizeConstraints?.forEach { $0.isActive = true }
//
//        //UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
//        self.lightContent = true
//        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: { [unowned self] in
//
//            self.view.frame = CGRect(x: 0, y: Theme.shared.playerViewTopDistance, width: self.view.frame.width, height: self.view.frame.height)
//            rootViewController?.view.transform = CGAffineTransform(scaleX: Theme.shared.scaleX, y: Theme.shared.scaleY)
//            rootViewController?.view.layer.cornerRadius = Theme.shared.cornerRadius
//            rootViewController?.view.clipsToBounds = true
//            rootViewController?.view.alpha = Theme.shared.alpha
//            self.view.layer.cornerRadius = Theme.shared.cornerRadius
//            self.view.layer.borderWidth = 0
//            self.view.layoutIfNeeded()
//
//            self.dismissDragIndicator.alpha = 1
//
//            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
//            statusBar?.alpha = 1
//        })
//    }
//
//    @objc func minimizePlayerView() {
//        let window = UIApplication.shared.keyWindow
//        let rootViewController = window?.rootViewController as? UINavigationController
//        self.maximizeConstraints?.forEach { $0.isActive = false }
//        self.minimizeConstraints?.forEach { $0.isActive = true }
//        //let homeController = navigationController?.viewControllers[0] as? HomeController
//        self.modalDelegate?.didDismiss()
//
//        rootViewController?.removeFromParentViewController()
//
//        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: { [unowned self] in
//
//            rootViewController?.view.transform = CGAffineTransform(scaleX: 1, y: 1)
//            rootViewController?.view.layer.cornerRadius = 0
//            rootViewController?.view.clipsToBounds = true
//            rootViewController?.view.alpha = 1
//
//            self.view.layer.borderColor = UIColor.darkGray.cgColor
//            self.view.layer.borderWidth = 0.2
//            self.view.transform = .identity
//            self.view.frame = CGRect(x: 0, y: self.view.frame.height + Theme.shared.playerViewTopDistance, width: self.view.frame.width, height: self.view.frame.height)
//            self.view.layer.cornerRadius = 0
//            self.view.layoutIfNeeded()
//
//            self.dismissDragIndicator.alpha = 0
//
//            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
//            statusBar?.alpha = 1
//
//        }, completion: { [unowned self] isFinished in
//            self.removeFromParentViewController()
//            //homeController?.settingsController = nil
//        })
//    }
//}
//
//extension ModalController {
//
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self.view.superview)
//        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
//
//        //let homeController = navigationController?.viewControllers[0] as? HomeController
//
//        if gesture.state == .changed {
//
//            print(translation.y/(view.frame.height))
//
//            let widthTransform = 1-translation.y/(view.frame.height*8)
//            let heightTransform = 1-translation.y/(view.frame.height*10)
//            let cornerRadius = -translation.y/28
//
//
//            self.view.transform = CGAffineTransform(translationX: 0, y: translation.y)
//            navigationController?.view.layer.transform = CATransform3DMakeScale(widthTransform, heightTransform, 1)
//            navigationController?.view.layer.cornerRadius = cornerRadius
//            navigationController?.view.clipsToBounds = true
//            navigationController?.view.alpha = 0.7
//
//        } else if gesture.state == .ended {
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: {
//
//                let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
//                let homeController = navController?.viewControllers[0] as? HomeController
//
//                if translation.y < -200 {
//
//                    homeController?.maximizePlayerView()
//                    gesture.isEnabled = false
//
//                } else {
//                    homeController?.view.transform = .identity
//                    self.view.transform = .identity
//                }
//            })
//
//        }
//    }
//
//
//
//
//    @objc func handlePanDismissGesture(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self.view.superview)
//
//
//        guard translation.y > 0 else {
//            return
//        }
//
//
//        let velocity = gesture.velocity(in: self.view.superview)
//        let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
//        //_ = navigationController?.viewControllers[0] as? HomeController
//        //let trueTranslation = translation.y + startTranslation
//
//        var transformationScaleX = Theme.shared.scaleX + translation.y/(view.frame.height*Theme.shared.scaleYSpeed)
//        let transformationScaleY = Theme.shared.scaleY + translation.y/(view.frame.height*Theme.shared.scaleXSpeed)
//
//        let cornerRadius = Theme.shared.cornerRadius - translation.y/(50)
//
//
//        if transformationScaleX > 1 {
//            transformationScaleX = 1
//        }
//
//        if gesture.state == .changed {
//            self.view.transform = CGAffineTransform(translationX: 0, y: translation.y*0.4)
//
//            if transformationScaleY < 1 {
//                navigationController?.view.transform = CGAffineTransform(scaleX: transformationScaleX, y: transformationScaleY)
//            }
//
//            if cornerRadius >= 0 {
//                navigationController?.view.layer.cornerRadius = cornerRadius
//            }
//
//
//        }
//
//
//
//        if gesture.state == .ended {
//            if translation.y > 200 || velocity.y > 500 {
//                UIView.animate(withDuration: 0.4, animations: {
//                    let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
//                    statusBar?.alpha = 0.5
//                    //UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//                    self.lightContent = false
//                })
//                //homeController?.minimizePlayerView()
//                minimizePlayerView()
//
//            } else {
//                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0.90, options: .curveEaseOut, animations: { [unowned self ] in
//
//                    navigationController?.view.transform = CGAffineTransform(scaleX: Theme.shared.scaleX, y: Theme.shared.scaleY)
//                    self.view.transform = .identity
//                })
//
//            }
//        }
//    }
//}
