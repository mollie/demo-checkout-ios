import Foundation

struct Price: Hashable, Codable {
    let description: String
    let fixed: Amount
    let variable: Double
    let feeRegion: String?
    
    enum CodingKeys: String, CodingKey {
        case description, fixed, variable
        case feeRegion = "fee_region"
    }
}
