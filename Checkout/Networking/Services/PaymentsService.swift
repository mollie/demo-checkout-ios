import Foundation

class PaymentService {
    
    static let shared = PaymentService()
    
    private let paymentsAPI = kBaseUrl.appendingPathComponent("payments")
    
    func getPayments(completion: @escaping (Result<[Payment], Error>) -> ()) {
        let options = URLRequestOptions(
            method: .get,
            url: paymentsAPI)
        
        let request = NetworkHelper.shared.createURLRequest(options: options)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let data = try NetworkHelper.shared.checkResponse(error: error, data: data)
                let payments = try decoder.decode(MollieResponse<[Payment]>.self, from: data)
                completion(.success(payments.data.sorted(by: { $0.createdAt ?? Date() > $1.createdAt ?? Date() })))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func getPayment(_ id: Int, completion: @escaping (Result<Payment, Error>) -> ()) {
        let options = URLRequestOptions(
            method: .get,
            url: paymentsAPI.appendingPathComponent("\(id)"))
        
        let request = NetworkHelper.shared.createURLRequest(options: options)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let data = try NetworkHelper.shared.checkResponse(error: error, data: data)
                let payment = try decoder.decode(MollieResponse<Payment>.self, from: data)
                completion(.success(payment.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createPayment(requestBody: CreatePayment, completion: @escaping (Result<Payment, Error>) -> ()) {
        let options = URLRequestOptions(
            method: .post,
            url: paymentsAPI,
            body: requestBody.toData())
        
        let request = NetworkHelper.shared.createURLRequest(options: options)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            do {
                let data = try NetworkHelper.shared.checkResponse(error: error, data: data)
                let payment = try decoder.decode(MollieResponse<Payment>.self, from: data)
                completion(.success(payment.data))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
