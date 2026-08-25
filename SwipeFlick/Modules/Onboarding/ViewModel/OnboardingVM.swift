protocol OnboardingVMProtocol: AnyObject {
    var numberOfItems: Int { get }
    var currentIndex: Int { get set }
    
    func item(at index: Int) -> OnboardingModel
    func hasNext() -> Bool
    func goNext()
    func completeOnboarding()
}

final class OnboardingVM: OnboardingVMProtocol {
    
    private let onboardingInfos: [OnboardingModel]
    var currentIndex = 0
    var didFinish: (() -> Void)?
    
    init(onboardingInfos: [OnboardingModel]) {
        self.onboardingInfos = onboardingInfos
    }
    
    var numberOfItems: Int {
        onboardingInfos.count
    }
    
    func item(at index: Int) -> OnboardingModel {
        guard onboardingInfos.indices.contains(index) else {
            return onboardingInfos.first ?? OnboardingModel(title: "", subtitle: "", imageName: "")
        }
        return onboardingInfos[index]
    }
    
    func hasNext() -> Bool {
        currentIndex < numberOfItems - 1
    }
    
    func goNext() {
        if hasNext() {
            currentIndex += 1
        }
    }

    func completeOnboarding() {
        AppDefaults.openedApp = true
        didFinish?()
    }
}
