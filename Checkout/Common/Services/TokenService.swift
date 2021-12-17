import Foundation

class TokenService {
    
    static let shared = TokenService()
    
    func getToken() -> String {
        if let token = UserDefaultsManager.shared.get(key: .token) as? String {
            return token
        } else {
            return createToken()
        }
    }
}

// MARK: Privates
private extension TokenService {
    
    func createToken() -> String {
        let newToken = UUID().uuidString
        UserDefaultsManager.shared.set(key: .token, to: newToken)
        return newToken
    }
}
