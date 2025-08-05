//
//  ArtistCell.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 02/08/25.
//
import UIKit
import Combine

class ArtistCell: UITableViewCell {
    static let identifier = "ArtistCell"
    let nameLabel = UILabel()
    let artworkImageView = UIImageView()
    private var cancellable: AnyCancellable?
    private var viewModel: ArtistCellViewModel?

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
        nameLabel.font = UIFont(name: "SFProText-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular)
        contentView.addSubview(artworkImageView)
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            artworkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            artworkImageView.widthAnchor.constraint(equalToConstant: 64),
            artworkImageView.heightAnchor.constraint(equalToConstant: 64),
            nameLabel.leadingAnchor.constraint(equalTo: artworkImageView.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
        artworkImageView.layer.cornerRadius = 10
        artworkImageView.clipsToBounds = true
    }

    func configure(with viewModel: ArtistCellViewModel) {
        self.viewModel = viewModel
        nameLabel.text = viewModel.name
        artworkImageView.image = viewModel.image
        cancellable = viewModel.$image
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.artworkImageView.image = image
            }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancellable?.cancel()
        artworkImageView.image = nil
        nameLabel.text = nil
        viewModel = nil
    }
}
