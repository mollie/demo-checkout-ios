import Foundation

extension Encodable {
    func toData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
