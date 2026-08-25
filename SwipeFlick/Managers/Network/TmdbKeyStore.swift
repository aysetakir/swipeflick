import Foundation

final class TmdbKeyStore {
    static let shared = TmdbKeyStore()
    private init() {}

    private let queue = DispatchQueue(label: "TmdbKeyStore.queue", attributes: .concurrent)
    private var _key: String?

    var key: String? {
        get { queue.sync { _key } }
        set { queue.async(flags: .barrier) { self._key = newValue } }
    }
}

