import UIKit

struct Payment: Codable {
    let id: Int?
    let mollieId: String?
    let method: String?
    let issuer: String?
    let amount: Double
    let description: String
    let url: String?
    let status: PaymentStatus
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case mollieId = "mollie_id"
        case method, issuer, amount
        case description, url, status
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum PaymentStatus: String, Codable {
    case open, canceled, pending, expired, failed, paid
    
    var backgroundColor: UIColor? {
        switch self {
        case .open:
            return R.color.statusOpen()
        case .canceled, .expired:
            return R.color.statusCanceledExpired()
        case .pending:
            return R.color.statusPending()
        case .failed:
            return R.color.statusFailed()
        case .paid:
            return R.color.statusAuthorized()
        }
    }
    
    var completed: Bool {
        return self != .open && self != .pending
    }
}
