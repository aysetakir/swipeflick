import UIKit

final class TabBarController: UITabBarController {
    private let authManager: AuthManaging
    
    init(authManager: AuthManaging) {
        self.authManager = authManager
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        delegate = self
    }
}

private extension TabBarController {
    func setupTabs() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        
        tabBar.tintColor = .secondGradient
        let homeVM = HomeVM(
            preferencesManager: FirebaseUserPreferencesManager.shared,
            authManager: authManager
        )
        let homeVC = HomeVC(viewModel: homeVM)
        let homeNav = createNav(with: "home".translated,
                                image: UIImage(systemName: "house"),
                                viewController: homeVC)
        
        let discoverViewModel = DiscoverVM()
        let discoverVC = DiscoverVC(viewModel: discoverViewModel)
        let discoverNav = createNav(with: "discover".translated,
                                    image: UIImage(systemName: "sparkles"),
                                    viewController: discoverVC)
        
        let randomVM = RandomVM()
        let randomVC = RandomVC(viewModel: randomVM)
        let randomNav = createNav(with: "random".translated,
                                    image: UIImage(systemName: "shuffle"),
                                    viewController: randomVC)
        
        let profileVM = ProfileVM(
            authManager: authManager,
            preferencesManager: FirebaseUserPreferencesManager.shared
        )
        let profileVC = ProfileVC(viewModel: profileVM, authManager: authManager)
        let profileNav = createNav(with: "profile".translated,
                                   image: UIImage(systemName: "person"),
                                   viewController: profileVC)
        
        setViewControllers([homeNav, discoverNav, randomNav, profileNav], animated: false)
    }
    
    func createNav(with title: String, image: UIImage?, viewController: UIViewController) -> UINavigationController {
        let controller = UINavigationController(rootViewController: viewController)
        controller.tabBarItem.title = title
        controller.tabBarItem.image = image
        //viewController.title = title
        //controller.navigationBar.prefersLargeTitles = true
        //viewController.navigationItem.largeTitleDisplayMode = .always
        controller.toolbar.isHidden = true
        return controller
    }
}

// MARK: - UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let navController = viewController as? UINavigationController,
           navController.viewControllers.first is ProfileVC {
            
            if !authManager.isAuthenticated {
                if let currentNav = selectedViewController as? UINavigationController,
                   let topVC = currentNav.topViewController {
                    if topVC is AuthenticationVC || topVC is ForgotPasswordVC {
                        return false
                    }
                }
            }
        }
        return true
    }
}
