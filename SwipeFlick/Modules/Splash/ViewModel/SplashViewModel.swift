import Foundation

enum SplashRoute {
    case onboarding
    case main
}

protocol SplashVMProtocol: AnyObject {
    var onRoute: ((SplashRoute) -> Void)? { get set }
    var onMessageUpdate: ((String) -> Void)? { get set }
    func start()
    func stop()
}

final class SplashVM: SplashVMProtocol {
    var onRoute: ((SplashRoute) -> Void)?
    var onMessageUpdate: ((String) -> Void)?
    
    private let delay: TimeInterval
    private let messageInterval: TimeInterval
    private let messages: [String]
    private var messageTimer: Timer?
    private var pendingMessages: [String] = []
    private var lastMessage: String?
    
    init(
        delay: TimeInterval = 2.5,
        messageInterval: TimeInterval = 2.0,
        messageKeys: [String] = SplashVM.defaultMessageKeys
    ) {
        self.delay = delay
        self.messageInterval = messageInterval
        self.messages = messageKeys.map { $0.translated }
    }
    
    func start() {
        startMessageCycle()
        fetchTmdbKeyIfPossible()
        scheduleRouting()
    }
    
    func stop() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
}

private extension SplashVM {
    static let defaultMessageKeys: [String] = [
        "splashMessageCurating",
        "splashMessagePopcorn",
        "splashMessageHiddenGems",
        "splashMessageCinephile",
        "splashMessageRewind",
        "splashMessageScenes"
    ]
    
    func scheduleRouting() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            let route: SplashRoute = AppDefaults.openedApp ? .main : .onboarding
            self?.onRoute?(route)
        }
    }
    
    func startMessageCycle() {
        guard !messages.isEmpty else { return }
        
        sendNextMessage()
        
        messageTimer?.invalidate()
        messageTimer = Timer.scheduledTimer(withTimeInterval: messageInterval, repeats: true) { [weak self] _ in
            self?.sendNextMessage()
        }
        
        if let messageTimer {
            RunLoop.main.add(messageTimer, forMode: .common)
        }
    }
    
    func sendNextMessage() {
        if pendingMessages.isEmpty {
            pendingMessages = messages.shuffled()
            
            if let previous = lastMessage,
               pendingMessages.first == previous,
               pendingMessages.count > 1 {
                let first = pendingMessages.removeFirst()
                pendingMessages.append(first)
            }
        }
        
        guard !pendingMessages.isEmpty else { return }
        
        let message = pendingMessages.removeFirst()
        lastMessage = message
        onMessageUpdate?(message)
    }

    func fetchTmdbKeyIfPossible() {
        TmdbKeyService.shared.fetchKey { result in
            if case .success(let key) = result {
                TmdbKeyStore.shared.key = key
            }
        }
    }
}
