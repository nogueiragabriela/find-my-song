//
//  TrackCell.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 02/08/25.
//
import UIKit
import Combine

class TrackCell: UITableViewCell {
    static let identifier = "TrackCell"
    let nameLabel = UILabel()
    let artistLabel = UILabel()
    let artworkImageView = UIImageView()
    let arrowButton = UIButton(type: .system)
    private var cancellable: AnyCancellable?
    private var viewModel: TrackCellViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowButton.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont(name: "SFProText-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular)
        artistLabel.font = UIFont(name: "SFProText-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        artistLabel.numberOfLines = 1

        contentView.addSubview(artworkImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(artistLabel)
        contentView.addSubview(arrowButton)

        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            artworkImageView.widthAnchor.constraint(equalToConstant: 64),
            artworkImageView.heightAnchor.constraint(equalToConstant: 64),

            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: arrowButton.leadingAnchor, constant: -8),

            artistLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            artistLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            artistLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            artistLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),

            arrowButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            arrowButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowButton.widthAnchor.constraint(equalToConstant: 17),
            arrowButton.heightAnchor.constraint(equalToConstant: 17)
        ])

        artworkImageView.layer.cornerRadius = 10
        artworkImageView.clipsToBounds = true

        let arrowImage = UIImage(systemName: "chevron.right")
        arrowButton.setImage(arrowImage, for: .normal)
        arrowButton.tintColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 67/255.0, alpha: 0.3)
        arrowButton.imageView?.contentMode = .scaleAspectFit
        arrowButton.addTarget(self, action: #selector(arrowTapped), for: .touchUpInside)
    }

    func configure(with viewModel: TrackCellViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        artistLabel.text = viewModel.artist
        artworkImageView.image = viewModel.image
        cancellable = viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.artworkImageView.image = image
            }
    }

    @objc private func arrowTapped() {
        viewModel?.onArrowTapped?()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        artworkImageView.image = nil
        nameLabel.text = nil
        artistLabel.text = nil
        viewModel = nil
    }
}
