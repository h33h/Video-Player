//
//  ShowVideoVC.swift
//  VideoPlayer
//
//  Created by XXX on 26.10.21.
//

import UIKit
import AVFoundation
import AVKit

class ShowVideoVC: UIViewController {

    private var video: Video? {
        // When video is setted then setup Player and Labels
        didSet {
            if let video = video {
                configure(video: video)
            }
        }
    }
    private var backButton: UIBarButtonItem?
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        containerView.addSubview(children[0].view)
    }
    private func configure(video: Video) {
        if let title = video.title { setTitleLabel(title: title) }
        if let subtitle = video.subtitle { setSubitleLabel(subtitle: subtitle) }
        if let description = video.description { setDescription(description: description) }
        guard let stringUrl = video.sources?[0], let videoUrl = URL(string: stringUrl) else { return }
        setupPlayerVC(url: videoUrl)
    }
    override func viewDidLayoutSubviews() {
        // VideoPlayerVC set frame to containerView bounds
        children[0].view.frame = containerView.bounds
    }
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            navigationItem.titleView?.isHidden = false
            navigationItem.setLeftBarButton(backButton, animated: true)
        default:
            navigationItem.titleView?.isHidden = true
            navigationItem.setLeftBarButton(nil, animated: true)
        }
    }
}

extension ShowVideoVC {
    private func setupNavigationBar() {
        setupLabel()
        setupBackButton()
    }
    private func setupBackButton() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonAction))
        backButton.tintColor = .white
        backButton.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        self.backButton = backButton
        navigationItem.leftBarButtonItem = backButton
        }
    private func setupLabel() {
        navigationItem.hidesBackButton = true
        let title = UILabel()
        title.text = "VideoTube"
        title.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        title.textColor = .white
        navigationItem.titleView = title
    }
    @objc
    func backButtonAction(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension ShowVideoVC {
    func setVideo(video: Video) {
        self.video = video
    }
    private func setTitleLabel(title: String) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = title
        }
    }
    private func setSubitleLabel(subtitle: String) {
        DispatchQueue.main.async { [weak self] in
            self?.subtitleLabel.text = subtitle
        }
    }
    private func setDescription(description: String) {
        DispatchQueue.main.async { [weak self] in
            self?.descriptionTextView.text = description
        }
    }
}

extension ShowVideoVC {
    private func setupPlayerVC(url: URL) {
        let player = AVPlayer(url: url)
        let childVC = VideoPlayerVC()
        childVC.setPresenter(presenter: VideoPlayerPresenter(player: player, delegate: childVC))
        addChild(childVC)
        childVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childVC.didMove(toParent: self)
    }
}
