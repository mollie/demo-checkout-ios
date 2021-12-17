import Foundation

class MethodsService {
    
    static let shared = MethodsService()
    
    func getActiveMethods(by amount: Double, completion: @escaping (Result<[Method], Error>) -> ()) {
        let options = URLRequestOptions(
            method: .get,
            url: kBaseUrl.appendingPathComponent("methods"))
        
        let request = NetworkHelper.shared.createURLRequest(options: options)
    
        URLSession.shared.dataTask(with: request) { data, _, error in
            do {
                let data = try NetworkHelper.shared.checkResponse(error: error, data: data)
                let methods = try JSONDecoder().decode(MollieResponse<[Method]>.self, from: data)
                completion(.success(methods.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
