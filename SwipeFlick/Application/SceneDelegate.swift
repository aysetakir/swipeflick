import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let authManager = FirebaseAuthManager.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        if authManager.isAuthenticated {
            FirebaseUserPreferencesManager.shared.prefetchAllData { }
        }
        
        let splashVM = SplashVM()
        let splashVC = SplashVC(viewModel: splashVM)
        
        splashVM.onRoute = { [weak self] route in
            switch route {
            case .onboarding: self?.showOnboarding()
            case .main: self?.showMain()
            }
        }
        
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
    }
    
    private func showOnboarding() {
        let viewModel = OnboardingVM(onboardingInfos: onboardingInfos)
        let onboardingVC = OnboardingVC(viewModel: viewModel)
        viewModel.didFinish = { [weak self] in self?.showMain() }
        setRoot(onboardingVC)
    }
    
    private func showMain() {
        setRoot(TabBarController(authManager: authManager))
    }
    
    private func setRoot(_ viewController: UIViewController) {
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve) {
            self.window?.rootViewController = viewController
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

