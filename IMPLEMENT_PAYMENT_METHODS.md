# Optional: Implement payment methods

Payment method selection can be implemented natively if wanted. This is completely optional because Mollie will request the payment method in web if the payment method isn't decided.

## Types

There are different types of payment types to implement, depending on the payment method:

1. Issuer selection (e.g. _iDeal_ payments)
2. Single selection (e.g. _PayPal_ payments)
3. Additional input (e.g. _Credit card_ payments)

> **Note:** The available payment methods may vary based on the `amount` of the payment. Make sure to retrieve the payment methods via the backend along with the `amount` of the payment.

### 1. Issuer selection

The payment method has multiple issuers of which one should be selected. Show the list of issuers to the user to select one.

<img src="images/FlowBasicWithMethodSelection.gif" alt="Payment method selection" width="24%" />

### 2. Single selection

The payment method has no issuers.

<img src="images/FlowBasicWithMethodSelectionSingle.gif" alt="Payment method single selection" width="24%" />

### 3. Additional input

The payment method allows additional input. Depending on the actual method, provide the additional inputs to the user and create the payment with these values.

> **Note:** Mollie Checkout currently does not demonstrate this case. Instead, the app creates the payment with this method and causes the Mollie website to request the additional input.

## Payment options

# Resources

[SelectPaymentViewController.swift](Checkout/Scenes/CreatePayment/SelectPaymentMethod/SelectPaymentViewController.swift) is an example where the user can choose between the list or grid layout:

| List | List + issuers | Grid |
|------|----------------|------|
| ![Select method - list](images/SelectMethodList.png "Select method - list") | ![Select method/issuer - list](images/SelectMethodListIssuer.png "Select method/issuer - list") | ![Select method - grid](images/SelectMethodGrid.png "Select method - grid") |

> **Note:** Typically an app shows these in either a list or a grid, Mollie Checkout provides both options for demonstration purposes.

