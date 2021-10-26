//
//  VideoPlayerVC.swift
//  VideoPlayer
//
//  Created by XXX on 26.10.21.
//

import UIKit
import AVFoundation

class VideoPlayerVC: UIViewController {

    private var videoIsPlaying = false
    private var buttonsIsShown = (false, Date.now)
    private var player: AVPlayer? {
        didSet {
            playerLayer = AVPlayerLayer(player: player)
            player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.initial, .new], context: nil)
            addTimeObserver()
        }
    }
    private var playerLayer: AVPlayerLayer? {
        didSet {
            playerLayer?.videoGravity = .resize
            if let playerLayer = playerLayer {
                videoView.layer.insertSublayer(playerLayer, at: 0)
                videoIsPlaying = true
            }
        }
    }
    @IBOutlet private var videoView: UIView!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var forwardButton: UIButton!
    @IBOutlet private var backwardButton: UIButton!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var currentTimeLabel: UILabel!
    @IBOutlet private var fullScreenButton: UIButton!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var tapGesture: UITapGestureRecognizer!
    @IBOutlet private var dividerLabel: UILabel!
    func setPlayer(player: AVPlayer) {
        self.player = player
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    private func showButtons() {
        let lastShow = buttonsIsShown.1
        playButton.isHidden = false
        forwardButton.isHidden = false
        backwardButton.isHidden = false
        durationLabel.isHidden = false
        currentTimeLabel.isHidden = false
        fullScreenButton.isHidden = false
        slider.isHidden = false
        dividerLabel.isHidden = false
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) {[weak self] _ in
            guard let buttonsIsShown = self?.buttonsIsShown else { return }
            if buttonsIsShown.0, lastShow == buttonsIsShown.1 {
            self?.playButton.isHidden = true
            self?.forwardButton.isHidden = true
            self?.backwardButton.isHidden = true
            self?.durationLabel.isHidden = true
            self?.currentTimeLabel.isHidden = true
            self?.fullScreenButton.isHidden = true
            self?.slider.isHidden = true
            self?.dividerLabel.isHidden = true
                self?.buttonsIsShown.0.toggle()
                self?.buttonsIsShown.1 = Date.now
            }
        }
    }
    private func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        _ = player?.addPeriodicTimeObserver(forInterval: interval,
                                            queue: DispatchQueue.main,
                                            using: { [weak self] time in
            guard let currentItem = self?.player?.currentItem else { return }
            self?.slider.maximumValue = Float(currentItem.duration.seconds)
            self?.slider.minimumValue = 0
            self?.slider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(time: currentItem.currentTime())
        })
    }
    private func getTimeString(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60)%60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds])
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player?.play()
    }
    override func viewDidLayoutSubviews() {
        playerLayer?.frame = videoView.bounds
    }
    // swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == "duration",
            let duration = player?.currentItem?.duration.seconds,
            let durationTime = player?.currentItem?.duration,
            duration > 0.0 {
            self.durationLabel.text = getTimeString(time: durationTime)
        }
    }
    @IBAction private func backwardAction(_ sender: Any) {
        guard let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        var newTime = currentTime - 15.0
        if newTime < 0 {
            newTime = 0
        }
        let time = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
        player.seek(to: time)
    }
    @IBAction private func fullScreenAction(_ sender: Any) {
        if UIDevice.current.orientation.isPortrait {
          UIView.setAnimationsEnabled(false)
          UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
          UIView.setAnimationsEnabled(true)
        } else if UIDevice.current.orientation.isLandscape {
            UIView.setAnimationsEnabled(false)
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIView.setAnimationsEnabled(true)
          }
    }
    @IBAction private func forwardAction(_ sender: Any) {
        guard let duration = player?.currentItem?.duration, let player = player else { return }
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = currentTime + 15.0
        if newTime < (CMTimeGetSeconds(duration) - 15) {
            let time = CMTimeMake(value: Int64(newTime * 1000), timescale: 1000)
            player.seek(to: time)
        }
    }
    @IBAction private func playAction(_ sender: Any) {
        if videoIsPlaying {
            player?.pause()
            playButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        }
        if !videoIsPlaying {
            player?.play()
            playButton.setImage(UIImage.init(systemName: "pause.fill"), for: .normal)
        }
        videoIsPlaying.toggle()
    }
    @IBAction private func sliderAction(_ sender: UISlider) {
        player?.seek(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    @IBAction private func tapGesture(_ sender: Any) {
        if !buttonsIsShown.0 {
            buttonsIsShown.0.toggle()
            buttonsIsShown.1 = Date.now
            showButtons()
        } else {
            playButton.isHidden = true
            forwardButton.isHidden = true
            backwardButton.isHidden = true
            durationLabel.isHidden = true
            currentTimeLabel.isHidden = true
            fullScreenButton.isHidden = true
            slider.isHidden = true
            dividerLabel.isHidden = true
            buttonsIsShown.0.toggle()
            buttonsIsShown.1 = Date.now
        }
    }
}
