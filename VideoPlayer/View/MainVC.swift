//
//  ViewController.swift
//  VideoPlayer
//
//  Created by XXX on 25.10.21.
//

import UIKit

class MainVC: UIViewController {

    private var videos = [Video]()
    private var videoPresenter = VideoPresenter(service: VideoService())
    private var reuseIdentifire = String(describing: VideoTableViewCell.self)
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel()
        title.text = "VideoTube"
        title.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        title.textColor = .white
        navigationItem.titleView = title
        videoPresenter.setDelegate(delegate: self)
        videoPresenter.getVideos()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: reuseIdentifire, bundle: nil), forCellReuseIdentifier: reuseIdentifire)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowVideoVC, let sender = sender as? Video {
            destination.setVideo(video: sender)
        }
    }
}

extension MainVC: UITableViewDelegate, UITableViewDataSource, VideoPresenterDelegate {
    func showVideos(videos: [Video]) {
        self.videos.append(contentsOf: videos)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire,
                                                       for: indexPath)
                as? VideoTableViewCell else { return UITableViewCell() }
        let video = videos[indexPath.row]
        cell.configure(video: video)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowVideo", sender: videos[indexPath.row])
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        247
    }
}
