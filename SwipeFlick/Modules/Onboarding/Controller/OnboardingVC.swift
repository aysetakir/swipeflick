import UIKit
import SnapKit

final class OnboardingVC: UIViewController {
    
    private let viewModel: OnboardingVMProtocol
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundSecondary
        return view
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("getStarted".translated, for: .normal)
        button.clipsToBounds = true
        button.backgroundColor = .buttonPrimary
        button.setTitleColor(.backgroundSecondary, for: .normal)
        button.clipsToBounds = true
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("next".translated, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.buttonPrimary.cgColor
        button.setTitleColor(.buttonPrimary, for: .normal)
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("skip".translated, for: .normal)
        button.setTitleColor(.backgroundSecondary, for: .normal)
        return button
    }()
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .buttonPrimary
        control.pageIndicatorTintColor = .buttonSecondary
        return control
    }()
    
    init(viewModel: OnboardingVMProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupConstraints()
        setupPageControl()
        setupButtonActions()
        
    }
    
    override func viewDidLayoutSubviews() {
        startButton.layer.cornerRadius = startButton.bounds.height / 2
        nextButton.layer.cornerRadius = nextButton.bounds.height / 2
    }
    
    private func setupUI() {
        view.backgroundColor = .backgroundPrimary
        
        view.addSubview(collectionView)
        view.addSubview(bottomContainerView)
        view.addSubview(skipButton)
        
        bottomContainerView.addSubview(nextButton)
        bottomContainerView.addSubview(startButton)
        bottomContainerView.addSubview(pageControl)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
        collectionView.backgroundColor = .backgroundPrimary
    }
    
    private func setupPageControl() {
        pageControl.page = 0
        startButton.isHidden = true
    }
    
    private func setupButtonActions() {
        skipButton.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        pageControl.addTarget(self, action: #selector(pageControlChanged), for: .valueChanged)
    }
    
    private func showItems(_ isHidden: Bool) {
        skipButton.isHidden = !isHidden
        nextButton.isHidden = !isHidden
        startButton.isHidden = isHidden
    }
    
    private func showPageItem(at index: Int) {
        viewModel.currentIndex = index
        showItems(index != viewModel.numberOfItems - 1)
        pageControl.page = index
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally, .centeredVertically], animated: true)
    }
}

//MARK: - Constraints

private extension OnboardingVC {
    private func setupConstraints() {
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(view.snp.height).multipliedBy(0.7)
        }
        
        bottomContainerView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(bottomContainerView.snp.top).offset(16)
            make.centerX.equalTo(bottomContainerView.snp.centerX)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
        
        startButton.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(40)
            make.height.equalTo(50)
        }
    }
}

//MARK: - Button Actions

private extension OnboardingVC {
    @objc private func skipTapped() {
        showPageItem(at: viewModel.numberOfItems - 1)
    }
    
    @objc private func nextTapped() {
        if viewModel.hasNext() {
            viewModel.goNext()
            showPageItem(at: viewModel.currentIndex)
        } else {
            viewModel.completeOnboarding()
        }
    }
    
    @objc private func startTapped() {
        viewModel.completeOnboarding()
    }
    
    @objc private func pageControlChanged() {
        showPageItem(at: pageControl.currentPage)
    }
}

//MARK: - CollectionView

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        let item = viewModel.item(at: indexPath.row)
        cell.configure(title: item.title, subtitle: item.subtitle, imageName: item.imageName)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        viewModel.currentIndex = page
        pageControl.currentPage = page
        showItems(page != viewModel.numberOfItems - 1)
    }
}

//MARK: - UIPageControl

private extension UIPageControl {
    var page: Int {
        get {
            currentPage
        }
        set {
            currentPage = newValue
        }
    }
}
