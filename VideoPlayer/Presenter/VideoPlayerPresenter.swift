//
//  VideoPlayerPresenter.swift
//  VideoPlayer
//
//  Created by XXX on 27.10.21.
//

import Foundation
import AVFoundation

protocol VideoPlayerPresenterDelegate: AnyObject {
    func durationOfVideo(duration: CMTime)
    func currentTimeOfVideo(currentTime: CMTime)
    func playerLayer(layer: AVPlayerLayer)
}

class VideoPlayerPresenter {
    private var player: AVPlayer
    private func setupPlayerLayer(player: AVPlayer) {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        delegate?.playerLayer(layer: playerLayer)
    }
    func setPlayerTime(to time: CMTime) {
        player.seek(to: time)
    }
    func playerPlay() {
        player.play()
    }
    func playerPause() {
        player.pause()
    }
    func mutePlayer(value: Bool) {
        player.isMuted = value
    }
    func backRewind(seconds: Double) {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - seconds
        if newTime < 0 {
            newTime = 0
        }
        let time = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }
    func forwardRewind(seconds: Double) {
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + seconds
        if newTime < (CMTimeGetSeconds(duration) - seconds) {
            let time = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    private func addTimeObservers() {
        durationObserver = player.currentItem?.observe(\.duration,
                                                        options: [.initial, .new],
                                                        changeHandler: { [weak self] _, _ in
            guard let self = self else { return }
            if let duration = self.player.currentItem?.duration, duration.seconds > 0.0 {
                self.delegate?.durationOfVideo(duration: duration)
            }
        })
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        currentTimeObserver = player.addPeriodicTimeObserver(forInterval: interval,
                                            queue: DispatchQueue.main,
                                            using: { [weak self] _ in
            guard let self = self,
                  let currentTime = self.player.currentItem?.currentTime()
            else { return }
            self.delegate?.currentTimeOfVideo(currentTime: currentTime)
        })
    }
    private weak var delegate: VideoPlayerPresenterDelegate?
    private var durationObserver: NSKeyValueObservation?
    private var currentTimeObserver: Any?
    init(player: AVPlayer, delegate: VideoPlayerPresenterDelegate) {
        self.delegate = delegate
        self.player = player
        // Add Observers for video duration and current time
        addTimeObservers()
        // When player is setted then setup PlayerLayer
        setupPlayerLayer(player: player)
    }
    deinit {
        durationObserver?.invalidate()
        if let currentTimeObserver = currentTimeObserver {
            player.removeTimeObserver(currentTimeObserver)
        }
    }
}
