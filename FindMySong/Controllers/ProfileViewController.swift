//
//  ProfileViewController.swift
//  FindMySong
//
//  Created by gabriela.p.nogueira on 03/08/25.
//
import UIKit
import Combine

class ProfileViewController: UIViewController {
    
    private let viewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    private let productTypeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 60/255, green: 60/255, blue: 67/255, alpha: 0.6)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let productTypeBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0)
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let favoriteSongsLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite Songs"
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let favoriteBandsLabel: UILabel = {
        let label = UILabel()
        label.text = "Favorite Bands"
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let songsTableView = UITableView()
    private let bandsTableView = UITableView()

    private let spotifyLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See more on Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.tintColor = UIColor(red: 30/255.0, green: 215/255.0, blue: 96/255.0, alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        
        setupTableViews()
        setupLayout()
        setupSpotifyButton()
        bindViewModel()
        
        viewModel.fetchUserProfile()
        viewModel.fetchUserFavoriteItems(endpoint: "tracks")
        viewModel.fetchUserFavoriteItems(endpoint: "artists")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    private func setupTableViews() {
        songsTableView.separatorInset = .zero
        songsTableView.layoutMargins = .zero
        songsTableView.translatesAutoresizingMaskIntoConstraints = false
        songsTableView.dataSource = self
        songsTableView.delegate = self
        songsTableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        
        bandsTableView.separatorInset = .zero
        bandsTableView.layoutMargins = .zero
        bandsTableView.translatesAutoresizingMaskIntoConstraints = false
        bandsTableView.dataSource = self
        bandsTableView.delegate = self
        bandsTableView.register(ArtistCell.self, forCellReuseIdentifier: ArtistCell.identifier)
    }
    
    private func setupLayout() {
        if let navBar = navigationController?.navigationBar {
            let separator = UIView()
            separator.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
            separator.translatesAutoresizingMaskIntoConstraints = false
            navBar.addSubview(separator)
            NSLayoutConstraint.activate([
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.leadingAnchor.constraint(equalTo: navBar.leadingAnchor),
                separator.trailingAnchor.constraint(equalTo: navBar.trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: navBar.bottomAnchor)
            ])
        }
        
        productTypeBackgroundView.addSubview(productTypeLabel)
        let infoStack = UIStackView(arrangedSubviews: [nameLabel, followersLabel, productTypeBackgroundView])
        infoStack.axis = .vertical
        infoStack.spacing = 11
        infoStack.alignment = .leading
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let mainStack = UIStackView(arrangedSubviews: [avatarImageView, infoStack])
        mainStack.axis = .horizontal
        mainStack.spacing = 24
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 119),
            avatarImageView.heightAnchor.constraint(equalToConstant: 119),
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            mainStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32)
        ])
        
        NSLayoutConstraint.activate([
            productTypeBackgroundView.leadingAnchor.constraint(equalTo: productTypeLabel.leadingAnchor, constant: -6),
            productTypeBackgroundView.trailingAnchor.constraint(equalTo: productTypeLabel.trailingAnchor, constant: 6),
            productTypeBackgroundView.centerYAnchor.constraint(equalTo: productTypeLabel.centerYAnchor),
            productTypeLabel.topAnchor.constraint(equalTo: productTypeBackgroundView.topAnchor, constant: 6),
            productTypeLabel.bottomAnchor.constraint(equalTo: productTypeBackgroundView.bottomAnchor, constant: -6),
            productTypeLabel.leadingAnchor.constraint(equalTo: productTypeBackgroundView.leadingAnchor, constant: 6),
            productTypeLabel.trailingAnchor.constraint(equalTo: productTypeBackgroundView.trailingAnchor, constant: -6)
        ])
        
        view.addSubview(favoriteSongsLabel)
        NSLayoutConstraint.activate([
            favoriteSongsLabel.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 20),
            favoriteSongsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            favoriteSongsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        view.addSubview(songsTableView)
        NSLayoutConstraint.activate([
            songsTableView.topAnchor.constraint(equalTo: favoriteSongsLabel.bottomAnchor, constant: 8),
            songsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            songsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            songsTableView.heightAnchor.constraint(equalToConstant: 200)
        ])

        view.addSubview(favoriteBandsLabel)
        NSLayoutConstraint.activate([
            favoriteBandsLabel.topAnchor.constraint(equalTo: songsTableView.bottomAnchor, constant: 20),
            favoriteBandsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            favoriteBandsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        view.addSubview(bandsTableView)
        NSLayoutConstraint.activate([
            bandsTableView.topAnchor.constraint(equalTo: favoriteBandsLabel.bottomAnchor, constant: 8),
            bandsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            bandsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            bandsTableView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupSpotifyButton() {
        view.addSubview(spotifyLinkButton)
        NSLayoutConstraint.activate([
            spotifyLinkButton.topAnchor.constraint(equalTo: bandsTableView.bottomAnchor, constant: 20),
            spotifyLinkButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        spotifyLinkButton.addTarget(self, action: #selector(openSpotify), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self = self, let user = user else { return }
                self.nameLabel.text = user.display_name
                let followersCount = "\(user.followers.total)"
                let followersText = " followers"
                let attributedText = NSMutableAttributedString(
                    string: followersCount,
                    attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]
                )
                attributedText.append(NSAttributedString(
                    string: followersText,
                    attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .regular)]
                ))
                self.followersLabel.attributedText = attributedText
                self.productTypeLabel.text = user.product.uppercased()
                if let imageUrl = user.images.first?.url, let url = URL(string: imageUrl) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.avatarImageView.image = image
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
        
        viewModel.$favoriteTracks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tracks in
                self?.songsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$favoriteArtists
            .receive(on: DispatchQueue.main)
            .sink { [weak self] artists in
                self?.bandsTableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                guard let self = self, let errorMessage = errorMessage else { return }
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func openSpotify() {
        if let url = URL(string: "https://open.spotify.com") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == songsTableView {
            return viewModel.favoriteTracks.count
        } else if tableView == bandsTableView {
            return viewModel.favoriteArtists.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == songsTableView {
            let track = viewModel.favoriteTracks[indexPath.row]
            let trackVM = TrackCellViewModel(track: track) { [weak self] in
                guard let self = self else { return }
                if let tabBarVC = self.parent?.parent as? TabBarViewController {
                    tabBarVC.tabBar.isHidden = true
                    tabBarVC.updateCurrentVCConstraints()
                }
                let songVC = SongViewController(track: track)
                self.navigationController?.pushViewController(songVC, animated: true)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: TrackCell.identifier, for: indexPath) as! TrackCell
            cell.configure(with: trackVM)
            return cell
        } else if tableView == bandsTableView {
            let artist = viewModel.favoriteArtists[indexPath.row]
            let artistVM = ArtistCellViewModel(artist: artist)
            let cell = tableView.dequeueReusableCell(withIdentifier: ArtistCell.identifier, for: indexPath) as! ArtistCell
            cell.configure(with: artistVM)
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == bandsTableView {
            let artist = viewModel.favoriteArtists[indexPath.row]
            if let urlString = artist.external_urls["spotify"], let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
