import Foundation

protocol AIPreferencesVMProtocol: AnyObject {
    var onStateChange: ((AIPreferencesState) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var onSaved: (() -> Void)? { get set }
    func load()
    func updateDraft(text: String)
    func save(text: String)
}

final class AIPreferencesVM: AIPreferencesVMProtocol {
    private let manager: UserPreferencesManaging
    private let authManager: AuthManaging
    private var lastSavedText: String = ""

    var onStateChange: ((AIPreferencesState) -> Void)?
    var onError: ((String) -> Void)?
    var onSaved: (() -> Void)?

    init(manager: UserPreferencesManaging, authManager: AuthManaging) {
        self.manager = manager
        self.authManager = authManager
    }

    func load() {
        guard authManager.isAuthenticated else {
            onStateChange?(AIPreferencesState(text: "", isSaving: false, isSaveEnabled: false))
            return
        }
        manager.fetchAIPreferences { [weak self] result in
            switch result {
            case .success(let value):
                let text = value ?? ""
                self?.lastSavedText = text
                self?.onStateChange?(AIPreferencesState(text: text, isSaving: false, isSaveEnabled: false))
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    func updateDraft(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let enabled = !trimmed.isEmpty && trimmed != lastSavedText
        onStateChange?(AIPreferencesState(text: text, isSaving: false, isSaveEnabled: enabled))
    }

    func save(text: String) {
        guard authManager.isAuthenticated else {
            onError?("mustBeSignedIn".translated)
            return
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != lastSavedText else {
            onStateChange?(AIPreferencesState(text: text, isSaving: false, isSaveEnabled: false))
            return
        }
        onStateChange?(AIPreferencesState(text: text, isSaving: true, isSaveEnabled: false))
        manager.saveAIPreferences(text: trimmed) { [weak self] result in
            switch result {
            case .success:
                self?.lastSavedText = trimmed
                self?.onSaved?()
                self?.onStateChange?(AIPreferencesState(text: trimmed, isSaving: false, isSaveEnabled: false))
            case .failure(let error):
                self?.onError?(error.localizedDescription)
                self?.onStateChange?(AIPreferencesState(text: text, isSaving: false, isSaveEnabled: trimmed != self?.lastSavedText))
            }
        }
    }
}
