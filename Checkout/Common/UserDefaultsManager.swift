import Foundation

enum UserDefaultsKey: String {
    case token
}

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let suite = UserDefaults.standard
    
    func get(key: UserDefaultsKey) -> Any? {
        suite.value(forKey: key.rawValue)
    }
    
    func set(key: UserDefaultsKey, to value: Any) {
        suite.setValue(value, forKey: key.rawValue)
    }
}

