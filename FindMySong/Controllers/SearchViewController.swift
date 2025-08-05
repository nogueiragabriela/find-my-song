import UIKit
import Combine

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Properties
    let viewModel: SearchViewModel
    var cancellables = Set<AnyCancellable>()
    let tableView = UITableView()
    var token: String

    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let fullTitle = "find my Song"
        titleLabel.textAlignment = .left
        let attributedText = NSMutableAttributedString(
            string: fullTitle,
            attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .regular)]
        )
        if let range = fullTitle.range(of: "Song") {
            let nsRange = NSRange(range, in: fullTitle)
            attributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: 32, weight: .bold), range: nsRange)
        }
        titleLabel.attributedText = attributedText
        return titleLabel
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Find your favorite song, band or album"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        DispatchQueue.main.async {
            let textField = searchBar.searchTextField
            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            ])
            let microphoneIcon = UIButton(type: .system)
            microphoneIcon.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            microphoneIcon.tintColor = .gray
            microphoneIcon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            microphoneIcon.contentMode = .scaleAspectFit
            textField.rightView = microphoneIcon
            textField.rightViewMode = .always
        }
        return searchBar
    }()
    
    let segmentedControl: UISegmentedControl = {
        let items = ["Band", "Song", "Album"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    let emptyIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.dashed")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let red: CGFloat = 120 / 255.0
        let green: CGFloat = 120 / 255.0
        let blue: CGFloat = 128 / 255.0
        let alpha: CGFloat = 31 / 255.0
        imageView.tintColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return imageView
    }()
    
    let emptyListMessage: UILabel = {
        let label = UILabel()
        label.text = "Nothing here. Try searching for a song."
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        let red: CGFloat = 60 / 255.0
        let green: CGFloat = 60 / 255.0
        let blue: CGFloat = 67 / 255.0
        let alpha: CGFloat = 0.3
        label.textColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return label
    }()
    
    let loadingIcon: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = UIColor(red: 60/255.0, green: 60/255.0, blue: 67/255.0, alpha: 0.6)
        return indicator
    }()

    let searchingLabel: UILabel = {
        let label = UILabel()
        label.text = "Searching..."
        label.font = UIFont(name: "SFProText-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        label.textColor = UIColor(red: 60/255.0, green: 60/255.0, blue: 67/255.0, alpha: 0.6)
        return label
    }()

    let loadingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        return stack
    }()
    
    // MARK: - Initializer
    init(token: String) {
        self.token = token
        self.viewModel = SearchViewModel(token: token)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Search", style: .plain, target: nil, action: nil)
        
        searchBar.delegate = self
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        tableView.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero

        // MARK: - Stack View Principal
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 0
        mainStackView.alignment = .fill
        mainStackView.distribution = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 32),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -32),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -28)
        ])
        
        //MARK: TitleView
        let titleView = UIView()
        titleView.addSubview(titleLabel)
        mainStackView.addArrangedSubview(titleView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: titleView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor)
        ])
        
        //MARK: SearchbarView
        let searchBarView = UIView()
        searchBarView.addSubview(searchBar)
        mainStackView.addArrangedSubview(searchBarView)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 45),
            searchBar.bottomAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor)
        ])
        
        //MARK: SegmentedControlView
        let segmentedControlView = UIView()
        segmentedControlView.addSubview(segmentedControl)
        mainStackView.addArrangedSubview(segmentedControlView)
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: searchBarView.bottomAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlView.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor)
        ])
        
        //MARK: Segmented ContentView
        let contentView = UIView()
        contentView.addSubview(emptyIcon)
        contentView.addSubview(emptyListMessage)
        mainStackView.addArrangedSubview(contentView)
        NSLayoutConstraint.activate([
            emptyIcon.topAnchor.constraint(equalTo: segmentedControlView.bottomAnchor, constant: 200),
            emptyIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emptyIcon.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            emptyIcon.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            emptyIcon.heightAnchor.constraint(equalToConstant: 100),
            emptyListMessage.topAnchor.constraint(equalTo: emptyIcon.bottomAnchor, constant: 36),
            emptyListMessage.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            emptyListMessage.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor)
        ])
        
        searchBar.delegate = self
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
        // MARK: Table View
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.isHidden = true
        emptyIcon.isHidden = false
        emptyListMessage.isHidden = false

        contentView.addSubview(loadingStackView)
        loadingStackView.addArrangedSubview(loadingIcon)
        loadingStackView.addArrangedSubview(searchingLabel)
        NSLayoutConstraint.activate([
            loadingStackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 275),
            loadingStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loadingStackView.widthAnchor.constraint(equalToConstant: 129),
            loadingStackView.heightAnchor.constraint(equalToConstant: 30),
            loadingIcon.widthAnchor.constraint(equalToConstant: 30),
            loadingIcon.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        bindViewModel()
    }
    
    // MARK: - Bindings
    private func bindViewModel() {
        viewModel.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] results in
                guard let self = self else { return }
                self.tableView.reloadData()
                let hasResults = !results.isEmpty
                self.tableView.isHidden = !hasResults
                self.emptyIcon.isHidden = hasResults
                self.emptyListMessage.isHidden = hasResults
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
    
    // MARK: - UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 3 {
            loadingIcon.startAnimating()
            loadingStackView.isHidden = false
            searchingLabel.isHidden = false
            tableView.isHidden = true
            emptyIcon.isHidden = true
            emptyListMessage.isHidden = true
        } else {
            loadingIcon.stopAnimating()
            loadingStackView.isHidden = true
            searchingLabel.isHidden = true
            tableView.isHidden = false
            viewModel.search(query: searchText)
        }
    }
    
    // MARK: - Segmented Control
    @objc func segmentedControlChanged() {
        let type = SearchType(rawValue: segmentedControl.selectedSegmentIndex) ?? .song
        let query = searchBar.text ?? ""
        viewModel.updateSearchType(type, query: query)
    }
}

// UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard case let .track(track) = viewModel.results[indexPath.row] else {
            return UITableViewCell()
        }
        let trackVM = TrackCellViewModel(track: track) { [weak self] in
            guard let self = self else { return }
            self.view.endEditing(true)
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
    }
}

// UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
