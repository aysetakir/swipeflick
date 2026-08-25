import UIKit
import SnapKit

final class ProfileVC: UIViewController {
    private let viewModel: ProfileVMProtocol
    private let authManager: AuthManaging

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.buttonPrimary.withAlphaComponent(0.5).cgColor
        return view
    }()
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 42, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .left
        return label
    }()

    private let statsStack = UIStackView()
    private let likedCard = StatCardView(icon: "heart", title: "likedStat".translated)
    private let watchedCard = StatCardView(icon: "hand.thumbsdown.fill", title: "unlikedStat".translated)
    private let aiCard = StatCardView(icon: "sparkles", title: "aiPicksStat".translated)

    private let savedHeader = UILabel()
    private let savedEmptyLabel: UILabel = {
        let l = UILabel()
        l.text = "noAIPicks".translated
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .white.withAlphaComponent(0.7)
        l.textAlignment = .center
        l.numberOfLines = 0
        l.isHidden = true
        return l
    }()
    private let savedViewAll = UIButton(type: .system)
    private lazy var savedCollection: UICollectionView = makeHorizontalCollection()

    private let settingsTitle = UILabel()
    private let settingsStack = UIStackView()
    private let accountSettingsRow = SettingRowView(title: "accountSettings".translated, systemIcon: "gearshape")
    private let aiPreferencesRow = SettingRowView(title: "aiPreferences".translated, systemIcon: "sparkles")
    private let logoutRow = SettingRowView(title: "logout".translated, systemIcon: "rectangle.portrait.and.arrow.right", style: .destructive)
    
    private var savedMovies: [Movie] = []
    private var isPresentingAuth = false

    init(viewModel: ProfileVMProtocol, authManager: AuthManaging) {
        self.viewModel = viewModel
        self.authManager = authManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "profile".translated
        view.backgroundColor = UIColor(named: "BackgroundPrimaryColor") ?? .black
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
        bindViewModel()
        viewModel.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requireAuthenticationIfNeeded()
        viewModel.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarContainer.layer.cornerRadius = avatarContainer.bounds.height / 2
    }
}

private extension ProfileVC {
    // MARK: - UI Setup
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.showsVerticalScrollIndicator = false

        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.alignment = .center
        headerStack.spacing = 16

        let titlesStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        titlesStack.axis = .vertical
        titlesStack.spacing = 4

        avatarContainer.addSubview(avatarLabel)
        avatarLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        headerStack.addArrangedSubview(avatarContainer)
        headerStack.addArrangedSubview(titlesStack)

        contentView.addSubview(headerStack)
        headerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        avatarContainer.snp.makeConstraints { $0.size.equalTo(72) }

        statsStack.axis = .horizontal
        statsStack.spacing = 12
        statsStack.distribution = .fillEqually
        [likedCard, watchedCard, aiCard].forEach { statsStack.addArrangedSubview($0) }
        contentView.addSubview(statsStack)
        statsStack.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        savedHeader.text = "aiPicksStat".translated
        savedHeader.textColor = .white
        savedHeader.font = .systemFont(ofSize: 18, weight: .semibold)
        savedViewAll.setTitle("\("viewAll".translated)  >", for: .normal)
        savedViewAll.setTitleColor(.buttonPrimary, for: .normal)
        let savedHeaderContainer = UIView()
        savedHeaderContainer.addSubview(savedHeader)
        savedHeaderContainer.addSubview(savedViewAll)
        contentView.addSubview(savedHeaderContainer)
        savedHeader.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        savedViewAll.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(savedHeader)
            make.leading.greaterThanOrEqualTo(savedHeader.snp.trailing).offset(8)
        }
        savedHeaderContainer.snp.makeConstraints { make in
            make.top.equalTo(statsStack.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        contentView.addSubview(savedCollection)
        savedCollection.backgroundColor = .clear
        savedCollection.register(ProfilePosterCell.self, forCellWithReuseIdentifier: ProfilePosterCell.identifier)
        savedCollection.dataSource = self
        savedCollection.delegate = self
        savedCollection.snp.makeConstraints { make in
            make.top.equalTo(savedHeaderContainer.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

        settingsTitle.text = "settings".translated
        settingsTitle.textColor = .white
        settingsTitle.font = .systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(settingsTitle)
        settingsTitle.snp.makeConstraints { make in
            make.top.equalTo(savedCollection.snp.bottom).offset(28)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        settingsStack.axis = .vertical
        settingsStack.spacing = 12
        [accountSettingsRow, aiPreferencesRow, logoutRow].forEach { settingsStack.addArrangedSubview($0) }
        contentView.addSubview(settingsStack)
        settingsStack.snp.makeConstraints { make in
            make.top.equalTo(settingsTitle.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-32)
        }

        savedViewAll.addTarget(self, action: #selector(openLikedMovies), for: .touchUpInside)
        accountSettingsRow.addTarget(self, action: #selector(openAccountSettings), for: .touchUpInside)
        aiPreferencesRow.addTarget(self, action: #selector(openAIPreferences), for: .touchUpInside)
        logoutRow.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        contentView.addSubview(savedEmptyLabel)
        savedEmptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(savedCollection.snp.centerY)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    func makeHorizontalCollection() -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        layout.itemSize = CGSize(width: 140, height: 190)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsHorizontalScrollIndicator = false
        return cv
    }
}

private extension ProfileVC {
    // MARK: - Bindings
    func bindViewModel() {
        viewModel.onStateChange = { [weak self] state in
            self?.apply(state)
        }
        viewModel.onRequestAuthentication = { [weak self] in
            self?.presentAuthentication()
        }
    }
}

private extension ProfileVC {
    // MARK: - State Updates
    func apply(_ state: ProfileViewState) {
        if state.isAuthenticated {
            scrollView.isHidden = false
            let initial = (state.displayName ?? state.email)?.first.map { String($0).uppercased() } ?? "U"
            avatarLabel.text = initial
            nameLabel.text = state.displayName ?? "profileWelcome".translated
            subtitleLabel.text = state.bio ?? ""

            likedCard.value = state.stats.liked
            watchedCard.value = state.stats.watched
            aiCard.value = state.stats.aiPicks

            savedMovies = state.savedMovies
            savedCollection.reloadData()
            savedEmptyLabel.isHidden = !savedMovies.isEmpty
            logoutRow.isHidden = false
        } else {
            scrollView.isHidden = true
            avatarLabel.text = "?"
            nameLabel.text = "profileGuest".translated
            subtitleLabel.text = "profileGuestDetail".translated
            logoutRow.isHidden = true
            requireAuthenticationIfNeeded()
        }
    }
}

private extension ProfileVC {
    // MARK: - Actions
    @objc func openAccountSettings() {
        let accountSettingsViewModel = AccountSettingsVM(profileViewModel: viewModel)
        let accountSettingsViewController = AccountSettingsVC(viewModel: accountSettingsViewModel)
        navigationController?.pushViewController(accountSettingsViewController, animated: true)
    }
    @objc func openLikedMovies() {
        let likedMoviesViewModel = LikedMoviesVM()
        let likedMoviesViewController = LikedMoviesVC(viewModel: likedMoviesViewModel)
        navigationController?.pushViewController(likedMoviesViewController, animated: true)
    }

    @objc func openAIPreferences() {
        let aiPreferencesViewModel = AIPreferencesVM(manager: FirebaseUserPreferencesManager.shared, authManager: authManager)
        let aiPreferencesViewController = AIPreferencesVC(viewModel: aiPreferencesViewModel)
        navigationController?.pushViewController(aiPreferencesViewController, animated: true)
    }

    @objc func logoutTapped() {
        let confirm = UIAlertAction(title: "logout".translated, style: .destructive) { [weak self] _ in
            self?.viewModel.handleLogout { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self?.presentAuthentication()
                    case .failure(let error):
                        self?.alertDialog(message: error.localizedDescription)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "cancel".translated, style: .cancel)
        alertDialog(title: "logout".translated, message: "", actions: [confirm, cancel])
    }
}

private extension ProfileVC {
    // MARK: - Navigation
    func presentAuthentication() {
        guard !isPresentingAuth else { return }
        if let nav = navigationController, nav.topViewController is AuthenticationVC { return }
        isPresentingAuth = true
        let authVM = AuthenticationVM(authManager: authManager)
        let authVC = AuthenticationVC(viewModel: authVM)
        authVC.navigationItem.hidesBackButton = true
        authVC.onSuccess = { [weak self] in
            guard let self else { return }
            self.navigationController?.popViewController(animated: true)
            self.isPresentingAuth = false
            self.scrollView.isHidden = false
            self.viewModel.load()
        }
        navigationController?.pushViewController(authVC, animated: true)
    }

    func requireAuthenticationIfNeeded() {
        if !authManager.isAuthenticated {
            scrollView.isHidden = true
            presentAuthentication()
        } else {
            scrollView.isHidden = false
        }
    }
}

// MARK: - Collection DataSource
extension ProfileVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePosterCell.identifier, for: indexPath) as! ProfilePosterCell
        let movie = savedMovies[indexPath.item]
        cell.configure(with: movie.posterURL)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = savedMovies[indexPath.item]
        showMovieDetailPopup(for: movie)
    }
}

//MARK: - Movie Detail Popup
private extension ProfileVC {
    func showMovieDetailPopup(for movie: Movie) {
        let movieDetailVM = MovieDetailVM(movieId: movie.id)
        let popup = MovieDetailView(viewModel: movieDetailVM)

        popup.onClose = { [weak popup] in
            UIView.animate(withDuration: 0.25, animations: {
                popup?.alpha = 0
            }, completion: { _ in
                popup?.removeFromSuperview()
            })
        }

        popup.onError = { [weak self] message in
            guard let self else { return }
            alertDialog(title: "error".translated, message: message)
        }

        popup.frame = view.bounds
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        view.addSubview(popup)

        UIView.animate(withDuration: 0.3) {
            popup.alpha = 1
            popup.transform = .identity
        }
    }
}
