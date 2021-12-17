# Source explained

## Setup

The demo app uses a few libraries for simplicity:

- [Cocoapods](): dependency manager in use.
- [R.swift](): for type-safe usage of resources (colors, images, localized strings, storyboards etc.). Note that when building the project the `R.generated.swift` file will be generated for you.
- [Nuke](): for loading remote images

Opening the project:

- `pod install`
- `open Checkout.xcworkspace`

## Settings

The demo app comes with a few configured settings in [Settings.swift](Checkout/App/Settings.swift). These settings can be modified to check out the flow when running the demo app.

We recommend trying out the different options of the available settings when running the app to get a feeling about which flow is preferred in your case.

| Setting | Description |
| ------- | ----------- |
| `kBaseUrl` | The base url of the backend in use. |
| `kSelectPaymentMethod` | Indicates whether to select the payment method directly when creating a payment. <br> This value defines how **creating** and **executing** the payment works in the demo app. |
| `kPaymentFlow` | Defines the flow that is used when executing a payment. |

## Networking

In this demo app we use the standard URLRequest to communicate to the backend:

- [NetworkHelper.swift](Checkout/Networking/NetworkHelper.swift): Network configuration
- [PaymentsService.swift](Checkout/Networking/Services/PaymentsService.swift): Definitions of backend payment calls
- [MethodsService.swift](Checkout/Networking/Services/MethodsService.swift): Definition of backend methods call

Within the ApiService there are 4 calls:

- `PaymentsService.createPayment(payment)`: Used to create a new payment.
- `PaymentsService.getPayments()`: Used to retrieve the list of payments.
- `PaymentsService.getPayment(id)`: Only used to retrieve a single payment.
- `MethodsService.getActiveMethods()`: Only needed when `kSelectPaymentMethod` is `true`.

# User flow

## 1: Splash

The [SplashViewController.swift](Checkout/Scenes/Splash/SplashViewController.swift) retrieves the payments list and proceeds when these are loaded.

## 2: List payments

In [PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift) the payments are retrieved and shown.

> **Note:** Refreshing the payments list when the user returns to the app is recommended to make sure the user always sees the latest state of their payments.

## 3: Create payment

The bare minimum needed to create a payment is a `description` and the `amount`. Usually these values are determined based on what is being bought. For demonstration purposes, in [CreatePaymentViewController.swift](Checkout/Scenes/CreatePayment/CreatePaymentViewController.swift) the user provides these values.

Next when clicking **Create** button, the app continues depending on `kSelectPaymentMethod`:

- When `true`, see [3A](#3a-optional-selecting-the-payment-method)
- When `false`, see [3B](#3b-payment-saved)

> **Note:** Selecting the payment method when creating the payment is completely optional. Creating a payment only with the `description` and `amount` will allow the user to select the payment method later when executing the payment.

### 3A Optional: Selecting the payment method

In [SelectPaymentViewController.swift](Checkout/Scenes/CreatePayment/SelectPaymentMethod/SelectPaymentViewController.swift) the payment method selection is implemented natively. In case the payment method has issuers, selecting the issuer is also required. When selecting **Continue**, the app proceeds to **3B**.

The demo app provides a segment selection on top to switch between the list and grid layout for selecting the method and issuer. You can choose which layout is preferred in your app.

> **Note:** [SelectIssuerViewController.swift](Checkout/Scenes/CreatePayment/SelectPaymentMethod/SelectIssuer/SelectIssuerViewController.swift) is only used when using the grid layout.

### 3B: Payment saved

The payment is saved with the values, proceeding to the next step: executing the payment.

## 4: Executing the payment

The demo app determines the payment flow based on `kPaymentFlow`:

- When `.externalBrowser`, see [4A](#4a-external-browser-flow)
- When `.internalBrowser`, see [4B](#4b-in-app-browser-flow)
- When `.choose`, see [4C](#4c-choose-flow)

### 4A: External browser flow

The url is opened via the external browser. Checkout the method `openExternalBrowser()` in [PaymentFlowNavigation.swift](Checkout/Scenes/PaymentFlow/PaymentFlowNavigation.swift).

### 4B: In-app browser flow

The url is opened within a WKWebView inside [InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift). The WKWebView is configured to successfully handle the payment pages.

The WKNavigationDelegate is used to handle the callbacks from the WKWebView. Overriding the `decidePolicy` method is **required** to handle called deeplinks from the WKWebView that should be opened in the native apps.

### 4C: Choose flow

With this setting the app will show an alert, giving the user the choice to use the **5A: External browser flow** or the **5B: In-app browser flow**.

## 5: Payment result

In [SceneDelegate.swift](Checkout/App/SceneDelegate.swift) the incoming deeplink is being handled.

The [PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift) receives the deeplink via the `PaymentsViewControllerDelegate.paymentCompleted` method, which is called by the SceneDelegate. 

Also, the [PaymentsViewController.swift](Checkout/Scenes/Payments/PaymentsViewController.swift) reloads the payment when the user returns to the app to ensure that the latest state of the payments are shown.

### 5A: In-app browser flow

When using the in-app browser flow, the [InAppBrowserViewController.swift](Checkout/Scenes/PaymentFlow/InAppBrowser/InAppBrowserViewController.swift) also refreshes the state of the payment when the user returns to the app. This is because with the in-app browser flow, there are various cases where the payment is completed but did not return to that ViewController or to the app.
