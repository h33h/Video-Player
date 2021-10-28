//
//  VideoPlayerVC.swift
//  VideoPlayer
//
//  Created by XXX on 26.10.21.
//

import UIKit
import AVFoundation

class VideoPlayerVC: UIViewController {

    private var videoIsPlaying = true
    private var buttonsIsShown = false
    private var isMuted = false
    private var timer: Timer? // Hide button timer
    private var presenter: VideoPlayerPresenter?
    private var playerLayer: AVPlayerLayer? {
        didSet {
            guard let playerLayer = playerLayer else { return }
            DispatchQueue.main.async { [weak self] in
                self?.videoView.layer.addSublayer(playerLayer)
            }
        }
    }
    @IBOutlet private var videoView: UIView!
    @IBOutlet private var playButton: UIButton!
    @IBOutlet private var forwardButton: UIButton!
    @IBOutlet private var backwardButton: UIButton!
    @IBOutlet private var muteButton: UIButton!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var currentTimeLabel: UILabel!
    @IBOutlet private var fullScreenButton: UIButton!
    @IBOutlet private var slider: UISlider!
    @IBOutlet private var tapGesture: UITapGestureRecognizer!
    @IBOutlet private var dividerLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.playerPlay()
    }
    override func viewDidLayoutSubviews() {
        videoView.frame = view.bounds
        playerLayer?.frame = videoView.bounds
    }
    func setPresenter(presenter: VideoPlayerPresenter) {
        self.presenter = presenter
    }
}

extension VideoPlayerVC {
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
    private func setControllsHidden(value: Bool) {
        playButton.isHidden = value
        forwardButton.isHidden = value
        backwardButton.isHidden = value
        durationLabel.isHidden = value
        currentTimeLabel.isHidden = value
        fullScreenButton.isHidden = value
        slider.isHidden = value
        dividerLabel.isHidden = value
        muteButton.isHidden = value
    }
    private func setOrientation(orientation: UIInterfaceOrientation) {
        UIView.setAnimationsEnabled(false)
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UIView.setAnimationsEnabled(true)
    }
    private func timerReload() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] _ in
            self?.setControllsHidden(value: true)
        }
    }
    private func showButtons() {
        setControllsHidden(value: false)
        timerReload()
    }
}

extension VideoPlayerVC: VideoPlayerPresenterDelegate {
    func durationOfVideo(duration: CMTime) {
        self.durationLabel.text = getTimeString(time: duration)
        self.slider.minimumValue = 0
        self.slider.setValue(0, animated: true)
        self.slider.maximumValue = Float(duration.seconds)
    }
    func currentTimeOfVideo(currentTime: CMTime) {
        self.currentTimeLabel.text = getTimeString(time: currentTime)
        self.slider.setValue(Float(currentTime.seconds), animated: true)
    }
    func playerLayer(layer: AVPlayerLayer) {
        self.playerLayer = layer
    }
}

extension VideoPlayerVC {
    @IBAction private func backwardAction(_ sender: Any) {
        presenter?.backRewind(seconds: 15)
        timerReload()
    }
    @IBAction private func forwardAction(_ sender: Any) {
        presenter?.forwardRewind(seconds: 15)
        timerReload()
    }
    @IBAction private func fullScreenAction(_ sender: Any) {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown:
            setOrientation(orientation: .landscapeLeft)
        case .landscapeLeft, .landscapeRight:
            setOrientation(orientation: .portrait)
        case .faceDown, .faceUp, .unknown:
            setOrientation(orientation: .landscapeLeft)
        @unknown default:
            setOrientation(orientation: .landscapeLeft)
        }
        timerReload()
    }
    @IBAction private func playAction(_ sender: Any) {
        if videoIsPlaying {
            presenter?.playerPause()
            playButton.setImage(UIImage.init(systemName: "play.fill"), for: .normal)
        } else {
            presenter?.playerPlay()
            playButton.setImage(UIImage.init(systemName: "pause.fill"), for: .normal)
        }
        timerReload()
        videoIsPlaying.toggle()
    }
    @IBAction private func sliderAction(_ sender: UISlider) {
        presenter?.setPlayerTime(to: CMTimeMake(value: Int64(sender.value*1000), timescale: 1000))
    }
    @IBAction func touchDownSlider(_ sender: Any) {
        timer?.invalidate()
    }
    @IBAction func touchUpInsideSlider(_ sender: Any) {
        timerReload()
    }
    @IBAction private func muteAction(_ sender: Any) {
        if isMuted {
            presenter?.mutePlayer(value: false)
            muteButton.setImage(UIImage.init(systemName: "speaker.wave.3.fill"), for: .normal)
        } else {
            presenter?.mutePlayer(value: true)
            muteButton.setImage(UIImage.init(systemName: "volume.slash.fill"), for: .normal)
        }
        isMuted.toggle()
        timerReload()
    }
    @IBAction private func tapGesture(_ sender: Any) {
        timer?.invalidate() // if 5seconds timer launched invalidate it
        if !buttonsIsShown {
            showButtons()
        } else {
            setControllsHidden(value: true)
        }
        buttonsIsShown.toggle()
    }
}
