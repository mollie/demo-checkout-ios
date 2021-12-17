import UIKit
import WebKit

class InAppBrowserViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    // MARK: Properties
    private var payment: Payment?
    private let urlScheme: String
    
    // MARK: Dependency Injection
    init?(coder: NSCoder, payment: Payment?) {
        self.payment = payment
        
        if let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [AnyObject],
            let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
            let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
            let externalURLScheme = urlSchemes.first as? String {
            urlScheme = externalURLScheme
        } else {
            urlScheme = R.string.localization.deeplink_scheme()
        }
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        isModalInPresentation = true
        setupNavigation()
        setupWebView()
        loadWebView()
    }
    
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        guard let paymentId = payment?.id else { return }
        
        // Check if payment status changed and handle accordingly.
        // When the browser opened an external app, the external app will call our deeplink to open the app again. However there are some caveats:
        // 1. When iOS opens a deeplink, it will show an alert to the user. The user may have decided to click cancel here and therefore not opening the deeplink after doing the payment.
        // 2. The payment may be done asynchronously and the user may manually return to the app. In this case this screen is still open while the payment might have already been finished.
        // In conclusion it is a best practice to check the status of the payment when the user returns back to the app to make sure that this payment is not completed already.
        PaymentService.shared.getPayment(paymentId) { [weak self] result in
            switch result {
            case .success(let payment):
                self?.payment = payment
                if payment.status.completed {
                    DispatchQueue.main.async { [weak self] in
                        self?.onPaymentFinished()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupNavigation() {
        if presentingViewController != nil {
            // Add close button if needed
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: R.string.localization.general_close(), style: .plain, target: self, action: #selector(self.close(sender:)))
        }
    }
    
    private func setupWebView() {
        webView.navigationDelegate = self
    }
    
    // MARK: Logic
    
    private func loadWebView() {
        loader.isHidden = false
        
        guard
            let paymentUrl = payment?.url,
            let url = URL(string: paymentUrl)
        else { return }
        
        webView.load(URLRequest(url: url))
    }
    
    private func onPaymentFinished() {
        guard
            let navigation = self.view.window?.rootViewController as? UINavigationController,
            let paymentsDelegate = navigation.viewControllers.compactMap({ $0 as? PaymentsViewControllerDelegate }).first
       else { return }
       
        paymentsDelegate.paymentCompleted()
    }
    
    // MARK: Actions
    
    @objc func close(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
}

extension InAppBrowserViewController: WKNavigationDelegate  {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Get payment id
        if let url = navigationAction.request.url {
           if url.absoluteString.contains(urlScheme) {
               let paymentId = Int(url.lastPathComponent)
               self.onPaymentFinished()
               decisionHandler(.allow)
           } else if (url.scheme?.lowercased() != "http" && url.scheme?.lowercased() != "https") {
               // It's a deeplink, open it
               UIApplication.shared.open(url, options: [:], completionHandler: nil)
               decisionHandler(.cancel)
           } else {
               decisionHandler(.allow)
           }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loader.isHidden = true
    }
}
