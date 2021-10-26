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
        navigationItem.hidesBackButton = true
        let title = UILabel()
        title.text = "VideoTube"
        title.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        title.textColor = .white
        let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonAction))
        backButton.tintColor = .white
        backButton.image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        self.backButton = backButton
        navigationItem.titleView = title
        navigationItem.leftBarButtonItem = backButton
        containerView.addSubview(children[0].view)
    }
    func setVideo(video: Video) {
        self.video = video
    }
    private func setTitleLabel(title: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = title
        }
    }
    private func setSubitleLabel(subtitle: String) {
        DispatchQueue.main.async {
            self.subtitleLabel.text = subtitle
        }
    }
    private func setDescription(description: String) {
        DispatchQueue.main.async {
            self.descriptionTextView.text = description
        }
    }
    private func configure(video: Video) {
        if let title = video.title { setTitleLabel(title: title) }
        if let subtitle = video.subtitle { setSubitleLabel(subtitle: subtitle) }
        if let description = video.description { setDescription(description: description) }
        guard let stringUrl = video.sources?[0], let videoUrl = URL(string: stringUrl) else { return }
        let player = AVPlayer(url: videoUrl)
        let childVC = VideoPlayerVC()
        addChild(childVC)
        childVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childVC.didMove(toParent: self)
        childVC.setPlayer(player: player)
        player.play()
    }
    @objc
    func backButtonAction(sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLayoutSubviews() {
        children[0].view.frame = containerView.bounds
    }
    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            navigationItem.titleView?.isHidden = true
            navigationItem.setLeftBarButton(nil, animated: true)
        } else if UIDevice.current.orientation.isPortrait {
            navigationItem.titleView?.isHidden = false
            navigationItem.setLeftBarButton(backButton, animated: true)
        }
    }
}
