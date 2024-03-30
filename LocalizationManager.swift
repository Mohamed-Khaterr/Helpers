import Foundation
import UIKit


class LocalizationManager {
    // MARK: - Enums
    enum LanguageDirection {
        case leftToRight
        case rightToLeft
    }
    
    enum Language: String {
        case arabic = "ar"
        case english = "en"
    }
    
    
    // MARK: - Properties
    static let shared = LocalizationManager()
    private var bundle: Bundle?
    private var storedLanguage: String? {
        set { UserDefaults.standard.setValue(newValue, forKey: "user_preferred_language") }
        get { UserDefaults.standard.string(forKey: "user_preferred_language") }
    }
    
    var isRightToLeftSemantic: Bool { getLanguageDirection() == .rightToLeft }
    
    
    // MARK: - Initializers
    private init() {}
    
    
    // MARK: - Observers
    private var languageChangeObserver: (() -> Void)?
    
    func languageDidChange(_ observe: @escaping () -> Void) {
        languageChangeObserver = observe
    }
    
    // MARK: - Funcitons
    /// Get current language from UserDefaults
    func getCurrentLanguage() -> Language? {
        guard let languageCode = storedLanguage else { return nil }
        return Language(rawValue: languageCode)
    }
    
    /// Get the language from Language Code.
    /// - Parameter code: Language Code (ISO-639)
    /// - Returns: Optional Language or nil if the code is not supported in the App
    func getLanguage(from code: String) -> Language? {
        var finalCode = ""
        if code.contains("en") {
            finalCode = "en"
        } else if code.contains("ar") {
            finalCode = "ar"
        }
        return Language(rawValue: finalCode)
    }
    
    /// Get direction of the alignment from language.
    ///
    /// The default direction for unknown language is LTR (Left to Right)
    private func getLanguageDirection() -> LanguageDirection {
        let currentLanguage = getCurrentLanguage()
        switch currentLanguage {
        case .arabic:
            return .rightToLeft
        case .english:
            return .leftToRight
            
        default:
            // Default Direction for unknown Language
            return .leftToRight
        }
    }
    
    /// Get localized string for given code from the given bundle
    func localizedString(for value: String) -> String {
        if let localizedString = bundle?.localizedString(forKey: value, value: value, table: nil) {
            return localizedString
        }
        
        return value
    }
    
    
    /// Set language for Localization
    func setLanguage(_ language: Language) {
        storedLanguage = language.rawValue
        
        if let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj") {
            self.bundle = Bundle(path: path)
        } else {
            // Reset Bundle (Localization)
            bundle = Bundle.main
        }
        
        // Reset App UI for the new Language
        updateSemanticAppearance()
        languageChangeObserver?()
    }
    
    
    /// Update the global Semantic Appearance for UI Components.
    private func updateSemanticAppearance() {
        let semantic: UISemanticContentAttribute
        switch getLanguageDirection() {
        case .leftToRight:
            semantic = .forceLeftToRight
        case .rightToLeft:
            semantic = .forceRightToLeft
        }
        
        UINavigationBar.appearance().semanticContentAttribute = semantic
        UITabBar.appearance().semanticContentAttribute = semantic
        UIView.appearance().semanticContentAttribute = semantic
    }
    
    
    /// Configure Startup language. And Language for first time user open the app
    func setAppLaunchingLanguage() {
        if let selectedLanguage = getCurrentLanguage() {
            setLanguage(selectedLanguage)
            return
        }
        
        // User first time open the App
        if let systemLanguageCode = Bundle.main.preferredLocalizations.first,
            let systemLanguage = getLanguage(from: systemLanguageCode) {
            // Get system language an set it as an app language
            setLanguage(systemLanguage)
        } else {
            // System language is unknown
            setLanguage(.english) // Set english as default Language
        }
    }
}

