import Foundation

struct MollieResponse<T: Codable> : Decodable {
    let data: T
}
