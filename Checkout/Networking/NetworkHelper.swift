import Foundation

enum HttpMethod: String {
    case post = "POST"
    case get = "GET"
}

struct URLRequestOptions {
    let method: HttpMethod
    let url: URL
    var body: Data? = nil
}

class NetworkHelper {
    
    static let shared = NetworkHelper()
    
    private var token: String {
        TokenService.shared.getToken()
    }
    
    func createURLRequest(options: URLRequestOptions) -> URLRequest {
        var urlRequest = URLRequest(url: options.url)
        
        urlRequest.httpMethod = options.method.rawValue
        urlRequest.timeoutInterval = 10
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue(token, forHTTPHeaderField: "X-Mollie-Checkout-Device-UUID")
        urlRequest.httpBody = options.body
        
        return urlRequest
    }
    
    func checkResponse(error: Error?, data: Data?) throws -> Data {
        if let error = error {
            throw error
        }
        
        guard let data = data else {
            throw NetworkError.noData
        }
        return data
    }
}
