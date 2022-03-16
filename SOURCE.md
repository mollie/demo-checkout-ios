# About the source

This page takes you through some of the source files you need to execute payments in your app.

## Setup

The demo app uses a number of libraries to simplify the setup.

- [Cocoapods](https://cocoapods.org/) manages dependencies.
- [R.swift](https://cocoapods.org/pods/R.swift) handles type-safe resources, such as colours, images, localised strings, storyboards, and so on. When you build the project, the `R.generated.swift` file is automatically generated.
- [Nuke](https://kean.blog/nuke/home): loads remote images.

To open the project, run the following commands.
- `pod install`
- `open Checkout.xcworkspace`

## Configuration

### Basic settings

You can modify the app’s basic settings in [Settings.swift](Checkout/App/Settings.swift).

-   `kBaseUrl` specifies the link used to communicate with your backend. This is needed to securely handle the API calls when executing the payment flow.
-   `kSelectPaymentMethod` indicates whether to use a custom payment method selection step.
    -   `false` means customers select the payment method in the browser when they execute the payment. 
    -   `true` enables you to customise the payment method selection. Customers select the payment method in your app before executing the payment in the web.
-   `kPaymentFlow` defines how to execute the payment.
    -   `.choose` displays an alert for the customer to choose their preferred flow.
    -   `.externalBrowser` uses the [basic implementation flow](FLOW_BASIC.md).
    -   `.inAppBrowser` uses the [advanced implementation flow](FLOW_ADVANCED.md).

> ✅  **Tip**: Run the app using different settings to discover your preferred implementation.

### Network and backend calls

The demo app uses [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) to communicate with the backend and execute the API calls needed for the payment flows.

 - [NetworkHelper.swift](Checkout/Networking/NetworkHelper.swift)
   contains the configuration.
 - [PaymentsService.swift](Checkout/Networking/Services/PaymentsService.swift)
   contains the backend payment calls:
	 - `PaymentsService.createPayment` creates a payment.
	 - `PaymentsService.getPayments()` retrieves a list of payments.
	 - `PaymentsService.getPayment(id)` retrieves the specified payment.
 - [MethodsService.swift](Checkout/Networking/Services/MethodsService.swift)
   contains the backend methods call:
	 - `MethodsService.getActiveMethods()` retrieves the payment methods. Only applies when `kSelectPaymentMethod` is `true`.

## App functionalities

The demo app uses various source files to handle its functionalities.

### Retrieve payments

There are two files that the app uses to retrieve payments.

[SplashViewController.swift](Checkout/Scenes/Splash/SplashViewController.swift) displays a loading screen while it retrieves the payments list. When it’s finished loading, it displays the payments list.
    
[PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift) retrieves and displays the payments list.

> :warning: **Note**: To ensure the latest payment statuses are shown, refresh the payments list in [PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift). This way, customers can see whether their payments were successful.

### Create payment

The API call to create a payment requires a `description` and an `amount`. In general, these values are determined by the ordered item. For demonstration purposes, the customer provides these values in [CreatePaymentViewController.swift](Checkout/Scenes/CreatePayment/CreatePaymentViewController.swift).

When the customer taps **Create**, the app continues to the select payment method step if `kSelectPaymentMethod` in [Settings.swift](Checkout/App/Settings.swift) is `true`. Otherwise, it saves the payment and proceeds to [the execution step](#execute-payment).

### Select payment method (optional)

If you customise the payment selection step, the app continues to the payment method on **Create**.

You can choose whether to display the payment methods and issuers in a list or a grid layout.

-   [SelectPaymentViewController.swift](Checkout/Scenes/CreatePayment/SelectPaymentMethod/SelectPaymentViewController.swift) implements the payment method selection natively.
-   [SelectIssuerViewController.swift](Checkout/Scenes/CreatePayment/SelectPaymentMethod/SelectIssuer/SelectIssuerViewController.swift) only applies when the customer selects a payment method through the grid layout.

### Execute payment

The app executes the payment according to the `kPaymentFlow` in [Settings.swift](Checkout/App/Settings.swift).

> :information_source: **Info**: The app contains the settings for both flows for demonstration purposes. You can also implement both flows and set `kPaymentFlow` to `.choose`. In this case, the app displays an alert that enables customers to choose whether to continue in the app or in their browser.

#### Basic implementation

In the basic implementation, the payment link opens in an external browser on the customer’s device.

To implement this flow, set `kPaymentFlow` to `.externalBrowser`.

[PaymentFlowNavigation.swift](Checkout/Scenes/PaymentFlow/PaymentFlowNavigation.swift) contains the `openExternalBrowser()` method.

#### Advanced implementation

In the advanced implementation, the payment link opens in a WKWebView inside the app.

To implement this flow, set `kPaymentFlow` to `.inAppBrowser`.

To access the WKWebView sample files, open **Checkout** → **Scenes** → **PaymentFlow** → **InAppBrowser**.

[InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift) contains the configuration to successfully handle payment pages. The WKNavigationDelegate is used to handle callbacks from the WKWebView.

> :warning: **Note**: You must override the `decidePolicy` to open deep links called from the WKWebView in native apps.

### Handle payment result

[SceneDelegate.swift](Checkout/App/SceneDelegate.swift) handles the incoming deep link.

[PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift) receives the deep link using the `PaymentsViewControllerDelegate.paymentCompleted` method, which is called by the SceneDelegate. It also reloads the payment when the user returns to the app, so that the latest payment statuses are displayed.

In the advanced implementation, there are various cases in which a customer completes their payment but isn't returned to the ViewController or the app. [InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift) therefore also refreshes the payments, to show the latest statuses when the customer returns to the app.
