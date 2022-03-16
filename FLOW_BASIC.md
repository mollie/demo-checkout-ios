# Implementing the basic flow

<img align="right" src="images/FlowBasic.gif" alt="Basic flow" width="24%" />

The basic implementation is the same as executing a payment in the web, using a browser on the customer’s device.

## Behaviour

When customers create a payment in your app, they receive a payment link. The link launches an external browser on the device where the customer selects their payment method and completes the payment. Depending on the selected payment method, the device might launch a native app from the browser to complete the payment.

After the payment is processed, a deep link takes the customer back to the app to see the payment result. The app refreshes the payments to show their latest statuses.

> ✅ **Tip**: We recommend this flow if you want to add Mollie payments to your app with minimum effort.

## Implementation

The basic flow consists of the following steps:

1.  [Create a payment](#step-1-create-a-payment)
2.  [Execute the payment](#step-2-execute-the-payment)
3.  [Handle the completed payment](#step-3-handle-the-completed-payment)
4.  [Refresh the payment status](#step-4-refresh-the-payment-status).

### Step 1: Create a payment

To create a payment, execute the backend call that creates a payment specifying a `description` and an `amount`.

This returns a payment object which contains the URL needed to execute the payment.

> ⚠️ **Note**: You must define the payment `amount` in a secure environment (the backend). Mollie Checkout for iOS only uses user input here for demonstration purposes.

### Step 2: Execute the payment

To navigate the customer to the checkout, open the URL from the create payment response.

```swift
UIApplication.shared.open(paymentUrl)
```

### Step 3: Handle the completed payment

In general, the payment result returns through a [deep link](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app) that is configured by the backend when the payment was created.

The demo app uses `mollie-checkout` as its deep link.

To navigate customers back to your app after they complete their payment, follow the steps below.

1. To define the URL scheme for your deep link, go to **Project Settings** → **Info** and add the URL scheme under **URL Types**.
<img src="images/SetupUrlScheme.png" alt="URL scheme definition" width="50%" />

2. Handle the incoming deep link in SceneDelegate.

```swift
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    // Get payment id
    guard
        let urlContext = URLContexts.first,
        let paymentId = Int(urlContext.url.lastPathComponent)
    else { return }
   
    // Refresh the PaymentsViewController's data
    guard
        let navigation = window?.rootViewController as? UINavigationController,
        let paymentsDelegate = navigation.viewControllers.compactMap({ $0 as? PaymentsViewControllerDelegate }).first
    else { return }
    paymentsDelegate.paymentCompleted()
}
```
3.  When PaymentsViewController receives a callback through the delegate, close modals, return to the root ViewController, and refresh the full payments list.

```swift
extension PaymentsViewController: PaymentsViewControllerDelegate {
    
    func paymentCompleted() {
        refreshPayments()
        presentedViewController?.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
}
```

### Step 4: Refresh the payment status

In some cases, customers can successfully complete their payment without returning to the app through the deep link. You should therefore refresh payments when customers return to the app, so that they see the latest statuses.

Refresh the payments when the app enters the foreground.

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    // ...
}

@objc func applicationWillEnterForeground(_ notification: Notification) {
    refreshPayments()
}
```

We recommend refreshing the payments on `viewWillAppear()` as well, in case the payment status changes while the customer navigates inside the app.

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshPayments()
}
```

#### Using modals

From iOS 13, you can present UIViewControllers in modals. They overlap the current UIViewController, which remains visible in the background.

In this case, `viewWillAppear()` isn't called when the modal is dismissed. You can implement `UIAdaptivePresentationControllerDelegate` to solve this.

```swift
@IBAction func createTapped(_ sender: Any) {
    guard let navigationVC = R.storyboard.createPayment.instantiateInitialViewController() else { return }
    navigationVC.presentationController?.delegate = self // Set the delegate
    present(navigationVC, animated: true, completion: nil)
}

extension PaymentsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refreshPayments()
    }
}
```

When the modal is closed programmatically, `viewWillAppear()` and `presentationControllerDidDismiss()` aren't called. To solve this, we call them manually when the modal is dismissed in the demo app.

```swift
@IBAction func cancelTapped(_ sender: Any) {
    if let presentingPresentationController = presentingViewController?.presentationController {
        presentingPresentationController.delegate?.presentationControllerDidDismiss?(presentingPresentationController)
    }
    dismiss(animated: true, completion: nil)
}
```

## Next steps

After implementing the basic flow, your app can handle Mollie payments using an external browser. You can further customise this flow through two additional implementations:
-   [Including payment method selection](IMPLEMENT_PAYMENT_METHODS.md) in your app.  
-   [Implement the advanced flow](FLOW_ADVANCED.md) to handle payments in a customisable in-app browser.

## Resources

Refer to the following source files for relevant samples:
-   [PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift): refresh payments and handle a completed payment.
-   [CreatePaymentViewController.swift](Checkout/Scenes/CreatePayment/CreatePaymentViewController.swift): create a payment.
