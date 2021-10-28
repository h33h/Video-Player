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
    private func configureCell(title: String, subtitle: String, thumb: UIImage) {
        DispatchQueue.main.async { [weak self] in
            self?.titleLabel.text = title
            self?.subtitleLabel.text = subtitle
            self?.thumbImageView.image = thumb
        }
    }
    func configure(video: Video) {
        if let title = video.title,
           let subtitle = video.subtitle,
           let thumb = video.getThumbUrl() {
            guard let data = try? Data(contentsOf: thumb), let image = UIImage(data: data) else { return }
            configureCell(title: title, subtitle: subtitle, thumb: image)
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
