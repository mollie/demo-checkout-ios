# Implementing the advanced flow

<img align="right" src="images/FlowAdvanced.gif" alt="Advanced flow" width="24%" />

Instead of using an external browser, the advanced implementation executes the payment in an in-app browser. This enables you to style the payment flow so that it matches your app’s theme.

## Behaviour

When customers create a payment, the payment link opens in a WKWebView to execute the payment. If necessary, the WKWebView launches other native apps to complete the payment.

The payment result returns through a deep link or a callback in the WKWebView. The app refreshes the payment statuses when it’s opened, to ensure the latest statuses are shown in case the payment result doesn’t return.

## Implementation

> :warning: **Note**: Before implementing the advanced flow, implement the basic flow and change `kPaymentFlow` to `.inAppBrowser` in [Settings.swift](Checkout/App/Settings.swift).

The advanced flow consists of the following steps:

1.  [Create an in-app browser ViewController](#create-an-in-app-browser-viewcontroller).
2.  [Configure the WKWebView settings](#configure-the-wkwebview-settings).
3.  [Configure the WKWebView client callback](#configure-the-wkwebview-client-callback).
4.  [Reload the payment status in the in-app browser ViewController](#reload-the-payment-status-in-the-in-app-browser-viewcontroller).

> :warning: **Warning**: Incorrect implementation of the advanced flow can lead to payments not starting or incomplete payments due to universal linking issues.

### Step 1: Create an in-app browser ViewController

To replace launching the payment link in the basic implementation, create a UIViewController that contains a WKWebView to load the payment, such as [InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift).

### Step 2: Configure the WKWebView settings

Configure the delegate on the WKWebView.

```swift
private func setupWebView() {
    webView.navigationDelegate = self
}
```

### Step 3: Configure the WKWebView client callback

In the UIViewController, configure the WKWebView client to handle callbacks.

```swift
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
}
```

### Step 4: Reload the payment status in the in-app browser ViewController

There are a number of situations where the customer doesn’t return to the app through a deep link or a callback. For example, when an external app is required to complete the payment, the external app calls the deep link to relaunch your app. In some cases, this is unsuccessful:

-   iOS displays an alert to the customer when the browser opens a deep link. If the customer chooses to cancel, the deep link doesn't open after payment.
-   If a payment takes place asynchronously, the customer must return to the app manually. The app opens the last screen, even if the payment is already complete.

Therefore, it’s best practice to check whether the payment is complete when the customer returns to the app.

To check whether the payment is complete, reload the payment status when the ViewController opens.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    // ...
}

@objc func applicationWillEnterForeground(_ notification: Notification) {
    guard let paymentId = payment?.id else { return }

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
```

## Next steps

After implementing the advanced flow, your app handles Mollie payments natively. You can extend this flow by [including payment method selection in your app](IMPLEMENT_PAYMENT_METHODS.md).

## Resources

Go to **Checkout** → **Scenes** → **PaymentFlow** → **InAppBrowser** for relevant sample files, such as [InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift), which provides an example UIViewController containing the WKWebView.
