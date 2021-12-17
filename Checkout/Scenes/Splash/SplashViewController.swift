import UIKit

class SplashViewController: UIViewController {

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getPayments()
    }
    
    // MARK: Methods
    func getPayments() {
        PaymentService.shared.getPayments { [weak self] result in
            switch result {
            case .success(let payments):
                print(payments)
                self?.presentPaymentsController(with: payments)
            case .failure(let error):
                self?.presentPaymentsController(with: [])
                print(error)
            }
        }
    }
    
    func presentPaymentsController(with payments: [Payment]) {
        DispatchQueue.main.async { [weak self] in
            let storyboard = R.storyboard.payments()
            let navigationVC = storyboard.instantiateInitialViewController { coder -> PaymentsViewController? in
                PaymentsViewController(coder: coder, payments: payments)
            }
            
            if let navigationVC = navigationVC {
                self?.view.window?.rootViewController = UINavigationController(rootViewController: navigationVC)
                self?.view.window?.makeKeyAndVisible()
            }
        }
    }
}

