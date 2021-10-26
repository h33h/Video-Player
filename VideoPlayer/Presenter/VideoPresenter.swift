//
//  VideoPresenter.swift
//  VideoPlayer
//
//  Created by XXX on 25.10.21.
//

import Foundation

protocol VideoPresenterDelegate: AnyObject {
    func showVideos(videos: [Video])
}

class VideoPresenter {
    private weak var delegate: VideoPresenterDelegate?
    private var videoService: VideoService
    init(service: VideoService) {
        self.videoService = service
    }
    func setDelegate(delegate: VideoPresenterDelegate) {
        self.delegate = delegate
    }
    func getVideos() {
        videoService.getJsonData { [weak self] category in
            if let videos = category?.videos {
                self?.delegate?.showVideos(videos: videos)
            }
        }
    }
}
