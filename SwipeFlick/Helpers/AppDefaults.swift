import Foundation

struct AppDefaults {
    private enum Keys {
        static let openedApp = "openedApp"
    }
    
    static var openedApp: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.openedApp) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.openedApp)}
    }
}
