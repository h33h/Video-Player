//
//  VideoTableViewCell.swift
//  VideoPlayer
//
//  Created by XXX on 25.10.21.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subtitleLabel: UILabel!
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
    private func setThumbnail(thumb: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.thumbImageView.image = thumb
        }
    }
    func configure(video: Video) {
        if let title = video.title { setTitleLabel(title: title) }
        if let subtitle = video.subtitle { setSubitleLabel(subtitle: subtitle) }
        if let thumb = video.getThumbUrl() {
            guard let data = try? Data(contentsOf: thumb), let image = UIImage(data: data) else { return }
            setThumbnail(thumb: image)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
