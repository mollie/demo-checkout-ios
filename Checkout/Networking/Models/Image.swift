import Foundation

struct Image: Hashable, Codable {
    let size1x: String
    let size2x: String
    let svg: String
    
    enum CodingKeys: String, CodingKey {
        case size1x = "size_1x"
        case size2x = "size_2x"
        case svg
    }
}
