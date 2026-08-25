import UIKit
import SnapKit

final class LikedMoviesVC: UIViewController, UICollectionViewDelegate {
    private let viewModel: LikedMoviesVMProtocol
    private var movies: [Movie] = []
    private var isLoading = false

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 24, right: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .buttonPrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "noAIPicks".translated
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    init(viewModel: LikedMoviesVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "aiPicksStat".translated
        view.backgroundColor = UIColor(named: "BackgroundPrimaryColor") ?? .black
        setupUI()
        bindViewModel()
        viewModel.loadLikedMovies()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateItemSize()
    }
}

private extension LikedMoviesVC {
    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)

        collectionView.register(LikedMoviesCell.self, forCellWithReuseIdentifier: LikedMoviesCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        setupConstraints()
    }

    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }
    }

    func bindViewModel() {
        viewModel.onMoviesLoaded = { [weak self] movies in
            guard let self = self else { return }
            self.movies = movies
            self.collectionView.reloadData()
            self.emptyLabel.isHidden = !movies.isEmpty
        }

        viewModel.onLoadingStateChange = { [weak self] isLoading in
            guard let self = self else { return }
            self.isLoading = isLoading
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }

        viewModel.onError = { [weak self] errorMessage in
            guard let self = self else { return }
            self.alertDialog(message: errorMessage)
        }
    }

    func updateItemSize() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let width = view.bounds.width
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let columns: CGFloat
        if isPad || width > 700 { columns = 4 }
        else if width > 400 { columns = 3 }
        else { columns = 2 }

        let insets = layout.sectionInset.left + layout.sectionInset.right
        let spacing = layout.minimumInteritemSpacing * (columns - 1)
        let itemWidth = floor((width - insets - spacing)) / columns
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth * 1.55)
        layout.invalidateLayout()
    }
}

// MARK: - UICollectionViewDataSource
extension LikedMoviesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikedMoviesCell.identifier, for: indexPath) as! LikedMoviesCell
        let movie = movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension LikedMoviesVC {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        showMovieDetailPopup(for: movie)
    }
}

//MARK: - Movie Detail Popup
private extension LikedMoviesVC {
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
