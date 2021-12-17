import Foundation

struct CreatePayment: Encodable {
    var method: String? = nil
    var issuer: String? = nil
    let amount: Double
    let description: String
}
