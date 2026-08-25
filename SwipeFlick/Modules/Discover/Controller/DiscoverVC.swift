import UIKit
import SnapKit

final class DiscoverVC: UIViewController {
    private var viewModel: DiscoverVMProtocol
    
    private var genreButtons: [GenreButton] = []
    private var emptyView: EmptyView?
    
    private let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "discoverTitle".translated
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "discoverSubtitle".translated
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .lightGray
        return label
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "discoverChooseGenre".translated
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        return label
    }()
    
    private let genreScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let genreStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var moviesCollectionView: UICollectionView = {
        let layout = createMoviesLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .backgroundPrimary
        collectionView.register(
            MovieCell.self,
            forCellWithReuseIdentifier: MovieCell.identifier
        )
        collectionView.contentInset.bottom = 40
        return collectionView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .lightGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: DiscoverVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
        setupBindings()
        
        Task {
            await viewModel.fetchGenres()
            await viewModel.fetchMovies(page: 1)
        }
    }
    
    //MARK: - Setup Bindings
    private func setupBindings() {
        viewModel.onGenresUpdated = { [weak self] in
            guard let self else { return }
            setupGenreButtons()
            viewModel.genres.isEmpty ? showEmptyView() : hideEmptyView()
        }
        
        viewModel.onMoviesUpdated = { [weak self] in
            guard let self else { return }
            moviesCollectionView.reloadData()
            
            if let viewModel = viewModel as? DiscoverVM, viewModel.currentPage == 1 {
                moviesCollectionView.setContentOffset(.zero, animated: false)
            }
            viewModel.movies.isEmpty ? showEmptyView() : hideEmptyView()
        }
        
        viewModel.onMoviesAppended = { [weak self] addedCount in
            guard let self else { return }
            let total = viewModel.numberOfMovies
            let start = total - addedCount
            let newIndexPaths = (start..<total).map { IndexPath(item: $0, section: 0) }
            
            moviesCollectionView.performBatchUpdates {
                self.moviesCollectionView.insertItems(at: newIndexPaths)
            }
        }
        
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            alertDialog(title: "error".translated, message: message)
            showEmptyView()
        }
    }
}

//MARK: - Genre Buttons
private extension DiscoverVC {
    func setupGenreButtons() {
        genreButtons.forEach { $0.removeFromSuperview() }
        genreButtons.removeAll()
        
        let allButton = GenreButton(title: "all".translated)
        allButton.addTarget(self, action: #selector(genreTapped(_:)), for: .touchUpInside)
        genreButtons.append(allButton)
        genreStackView.addArrangedSubview(allButton)
        
        for genre in viewModel.genres {
            let button = GenreButton(title: genre.name)
            button.tag = genre.id
            button.addTarget(self, action: #selector(genreTapped(_:)), for: .touchUpInside)
            genreButtons.append(button)
            genreStackView.addArrangedSubview(button)
        }
        
        allButton.setSelected(true)
    }
    
    @objc  func genreTapped(_ sender: GenreButton) {
        genreButtons.forEach { $0.setSelected(false) }
        sender.setSelected(true)
        
        let selectedGenreID = sender.genreTitle == "all".translated ? nil : sender.tag
        
        viewModel.setGenre(selectedGenreID)
    }
}

// MARK: - UICollectionViewDataSource
extension DiscoverVC: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.numberOfMovies
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MovieCell.identifier,
            for: indexPath
        ) as? MovieCell else {
            return UICollectionViewCell()
        }
        
        let movie = viewModel.movie(at: indexPath.item)
        cell.configure(with: movie)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DiscoverVC: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let movie = viewModel.movie(at: indexPath.item)
        showMovieDetailPopup(for: movie)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        
        guard let viewModel = viewModel as? DiscoverVM else { return }
        
        if indexPath.item == viewModel.movies.count - 5 && viewModel.currentPage < viewModel.totalPages {
            loadingIndicator.startAnimating()
            
            Task {
                await viewModel.fetchMovies(page: viewModel.currentPage + 1)
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                }
            }
        }
    }
}

//MARK: - EmptyView
private extension DiscoverVC {
    func showEmptyView() {
        emptyView?.removeFromSuperview()
        let empty = EmptyView(retryAction: { [weak self] in
            guard let self = self else { return }
            Task {
                await self.viewModel.fetchGenres()
                await self.viewModel.fetchMovies(page: 1)
            }
        })
        view.addSubview(empty)
        empty.snp.makeConstraints { $0.edges.equalToSuperview() }
        emptyView = empty
    }
    
    func hideEmptyView() {
        emptyView?.removeFromSuperview()
        emptyView = nil
    }
}

//MARK: - Movie Detail Popup
private extension DiscoverVC {
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
            self?.alertDialog(title: "error".translated, message: message)
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

//MARK: - Setup UI and Constraints
private extension DiscoverVC {
    func setupUI() {
        view.backgroundColor = .backgroundPrimary
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        view.addSubview(genreScrollView)
        genreScrollView.addSubview(genreStackView)
        view.addSubview(moviesCollectionView)
        moviesCollectionView.addSubview(loadingIndicator)
        
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        
        setupConstraints()
    }
    
    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-24)
        }
        
        genreScrollView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        
        genreStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalToSuperview()
        }
        
        moviesCollectionView.snp.makeConstraints {
            $0.top.equalTo(genreScrollView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
    }
    
    func createMoviesLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(280)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 12, trailing: 6)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(280)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        return UICollectionViewCompositionalLayout(section: section)
    }
}
