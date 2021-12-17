import Foundation

enum CheckoutItem: Hashable {
    case method(method: Method)
    case issuer(issuer: Issuer)
    
    /// Used for common attributes that both the Issuer and Method use.
    var selectableItem: CheckoutSelectable {
        switch self {
        case .issuer(let issuer):
            return issuer as CheckoutSelectable
        case .method(let method):
            return method as CheckoutSelectable
        }
    }
}
