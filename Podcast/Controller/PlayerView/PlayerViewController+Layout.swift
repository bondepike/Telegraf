//
//  PlayerViewController+Layout.swift
//  Podcast
//
//  Created by Adrian Evensen on 27/04/2018.
//  Copyright © 2018 AdrianF. All rights reserved.
//

import UIKit

extension PlayerViewController {
    
    //Animations
    @objc func handlePlayerDismiss() {
        let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
        let homeController = navController?.viewControllers[0] as? SubscriptionsController
        panGesture.isEnabled = true
        homeController?.minimizePlayerView()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            UIApplication.shared.keyWindow?.rootViewController?.view.layer.transform = CATransform3DMakeScale(1, 1, 1)
            UIApplication.shared.keyWindow?.rootViewController?.view.layer.cornerRadius = 0
            UIApplication.shared.keyWindow?.rootViewController?.view.alpha = 1
        })
    }
    
    func setupConstraintVariables() {
        smallConstraints = [
            podcastImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7),
            podcastImage.widthAnchor.constraint(equalToConstant: 50),
            podcastImage.heightAnchor.constraint(equalToConstant: 50),
            podcastImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 7),
        ]
        
        largeConstraints = [
            podcastImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24),
            podcastImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24),
            podcastImage.topAnchor.constraint(equalTo: dismissDragIndicator.bottomAnchor, constant: Theme.shared.podcastImageTopContraintConstant),
            podcastImage.heightAnchor.constraint(equalToConstant: (UIApplication.shared.keyWindow?.frame.width)! - 48),
        ]
        

    }
    
    //MARK:- Auto-Layout
    func setupLayout() {
        
        view.addSubview(scrollView)
        [
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(dismissDragIndicator)
        scrollConstraints = dismissDragIndicator.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 14)
        lockConstraints = dismissDragIndicator.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 14)
        [
            dismissDragIndicator.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            //dismissDragIndicator.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 14),
            scrollConstraints,
            dismissDragIndicator.widthAnchor.constraint(equalToConstant: 64),
            dismissDragIndicator.heightAnchor.constraint(equalToConstant: 6)
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(podcastImage)
        setupConstraintVariables()
        
        
        scrollView.addSubview(currentTimeSlider)
        [
            currentTimeSlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36),
            currentTimeSlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -36),
            currentTimeSlider.topAnchor.constraint(equalTo: podcastImage.bottomAnchor, constant: 7)
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(elapsedTimeLabel)
        [
            elapsedTimeLabel.leftAnchor.constraint(equalTo: currentTimeSlider.leftAnchor),
            elapsedTimeLabel.topAnchor.constraint(equalTo: currentTimeSlider.bottomAnchor),
            elapsedTimeLabel.rightAnchor.constraint(equalTo: currentTimeSlider.centerXAnchor)
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(episodeTitleLabel)
        [
            episodeTitleLabel.topAnchor.constraint(equalTo: currentTimeSlider.bottomAnchor, constant: 24),
            episodeTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36),
            episodeTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -36),
            episodeTitleLabel.heightAnchor.constraint(equalToConstant: (title?.count ?? 0 > 35 ? 60 : 30)),
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(prevChapterButton)
        scrollView.addSubview(nextChapterButton)
        [
            prevChapterButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 7),
            prevChapterButton.topAnchor.constraint(equalTo: episodeTitleLabel.bottomAnchor),
            prevChapterButton.widthAnchor.constraint(equalToConstant: 48),
            prevChapterButton.heightAnchor.constraint(equalToConstant: 48),
            
            nextChapterButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -7),
            nextChapterButton.topAnchor.constraint(equalTo: episodeTitleLabel.bottomAnchor),
            nextChapterButton.widthAnchor.constraint(equalToConstant: 48),
            nextChapterButton.heightAnchor.constraint(equalToConstant: 48)
            ].forEach { $0.isActive = true }
        
        scrollView.addSubview(chapterLabel)
        [
            chapterLabel.leftAnchor.constraint(equalTo: prevChapterButton.rightAnchor, constant: 14),
            chapterLabel.rightAnchor.constraint(equalTo: nextChapterButton.leftAnchor, constant: -14),
            chapterLabel.heightAnchor.constraint(equalToConstant: 50),
            chapterLabel.centerYAnchor.constraint(equalTo: prevChapterButton.centerYAnchor)
            ].forEach { $0.isActive = true }


        let avControlStackView = UIStackView(arrangedSubviews: [rewindButton, playPauseButton, forwardButton])
        avControlStackView.translatesAutoresizingMaskIntoConstraints = false
        avControlStackView.distribution = .fillProportionally
        
        scrollView.addSubview(avControlStackView)
        [
            avControlStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 36),
            avControlStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -36),
            avControlStackView.topAnchor.constraint(equalTo: chapterLabel.bottomAnchor, constant: 36),
            avControlStackView.heightAnchor.constraint(equalToConstant: 50)
            ].forEach { $0.isActive = true }
        
        view.addSubview(webViewContainer)
        webViewHeightConstraint = webViewContainer.heightAnchor.constraint(equalToConstant: 0)
        [
            webViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            webViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            webViewContainer.topAnchor.constraint(equalTo: avControlStackView.bottomAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            //webViewHeightConstraint
            ].forEach { $0.isActive = true }
        
        webViewContainer.addSubview(webView)
        [
            webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor, constant: 7),
            webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor, constant: -7),
            webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor, constant: 36),
            webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor, constant: -7)
            //descriptionText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
            ].forEach { $0.isActive = true }

        
        view.addSubview(episodeSmallPlayerTitleLabel)
        [
            episodeSmallPlayerTitleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 64),
            episodeSmallPlayerTitleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14),
            episodeSmallPlayerTitleLabel.centerYAnchor.constraint(equalTo: podcastImage.centerYAnchor),
            episodeSmallPlayerTitleLabel.heightAnchor.constraint(equalToConstant: 50)
            ].forEach { $0.isActive = true }
        
        view.addSubview(playPauseSmallPlayerButton)
        [
            playPauseSmallPlayerButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -14),
            playPauseSmallPlayerButton.heightAnchor.constraint(equalToConstant: 44),
            playPauseSmallPlayerButton.widthAnchor.constraint(equalToConstant: 44),
            playPauseSmallPlayerButton.centerYAnchor.constraint(equalTo: podcastImage.centerYAnchor)
            ].forEach { $0.isActive = true }


    }
}

