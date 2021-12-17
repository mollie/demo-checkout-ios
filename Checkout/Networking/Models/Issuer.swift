import Foundation

struct Issuer: Hashable, Codable, CheckoutSelectable {
    var id: String
    var name: String
    var image: Image
    
    var title: String { name }
}
