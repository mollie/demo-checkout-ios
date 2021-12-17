import Foundation

struct Method: Hashable, Codable, CheckoutSelectable {
    
    var id: String
    var description: String
    let minimumAmount: Amount?
    let maximumAmount: Amount?
    var image: Image
    let issuers: [Issuer]?
    let pricing: [Price]?
    
    enum CodingKeys: String, CodingKey {
        case id, description
        case minimumAmount = "minimum_mount"
        case maximumAmount = "maximum_mount"
        case image, issuers, pricing
    }
    var title: String { description }
    var hasIssuers: Bool { issuers?.isEmpty == false }
}
