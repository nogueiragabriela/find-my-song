//
//  SongViewController.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 03/08/25.
//
import UIKit

class SongViewController: UIViewController {
    let viewModel: SongViewModel

    private let artworkImageView = UIImageView()
    private let nameLabel = UILabel()
    private let albumLabel = UILabel()
    private let artistLabel = UILabel()
    private let openSpotifyButton = UIButton(type: .system)
    private let spotifyLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "spotify_logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()

    init(track: Track) {
        self.viewModel = SongViewModel(track: track)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupSubviews()
        setupContent()
        setupConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarVC = self.parent?.parent as? TabBarViewController {
            tabBarVC.tabBar.isHidden = false
        }
    }

    private func setupSubviews() {
        [spotifyLogoImageView, artworkImageView, nameLabel, albumLabel, artistLabel, openSpotifyButton].forEach {
            view.addSubview($0)
        }
    }

    private func setupContent() {
        // Artwork
        artworkImageView.translatesAutoresizingMaskIntoConstraints = false
        artworkImageView.contentMode = .scaleAspectFit
        artworkImageView.layer.cornerRadius = 5
        artworkImageView.clipsToBounds = true
        if let url = viewModel.artworkURL {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.artworkImageView.image = image
                }
            }.resume()
        } else {
            artworkImageView.image = UIImage(systemName: "photo")
        }

        // Labels
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.attributedText = viewModel.trackName
        nameLabel.textAlignment = .left

        albumLabel.translatesAutoresizingMaskIntoConstraints = false
        albumLabel.attributedText = viewModel.albumName
        albumLabel.textAlignment = .left
        albumLabel.textColor = .black

        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.attributedText = viewModel.artistName
        artistLabel.textAlignment = .left
        artistLabel.textColor = .black

        // Button
        openSpotifyButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonTitle = "Open on Spotify"
        let buttonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SFProText-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular),
            .kern: -0.43,
            .foregroundColor: UIColor.white
        ]
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: buttonAttributes)
        openSpotifyButton.setAttributedTitle(attributedTitle, for: .normal)
        openSpotifyButton.backgroundColor = UIColor(red: 30/255.0, green: 215/255.0, blue: 96/255.0, alpha: 1)
        openSpotifyButton.layer.cornerRadius = 25
        openSpotifyButton.addTarget(self, action: #selector(openOnSpotify), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            spotifyLogoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 31),
            spotifyLogoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            spotifyLogoImageView.widthAnchor.constraint(equalToConstant: 123),
            spotifyLogoImageView.heightAnchor.constraint(equalToConstant: 34),

            artworkImageView.topAnchor.constraint(equalTo: spotifyLogoImageView.bottomAnchor, constant: 31),
            artworkImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            artworkImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            artworkImageView.heightAnchor.constraint(equalToConstant: 366),

            nameLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            albumLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            albumLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            albumLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            artistLabel.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 7),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            artistLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            openSpotifyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            openSpotifyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openSpotifyButton.widthAnchor.constraint(equalToConstant: 366),
            openSpotifyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func openOnSpotify() {
        guard let url = viewModel.spotifyURL else { return }
        UIApplication.shared.open(url)
    }
}
