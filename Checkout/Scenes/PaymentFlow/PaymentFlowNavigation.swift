import UIKit

class PaymentFlowNavigation {
    
    private let selectedPayment: Payment
    private weak var currentViewController: UIViewController? = nil
    
    init(selectedPayment: Payment) {
        self.selectedPayment = selectedPayment
    }
    
    func executePayment(controller: UIViewController) {
        currentViewController = controller
        switch (kPaymentFlow, selectedPayment.status) {
        case (.externalBrowser, let status) where status == .open:
            openExternalBrowser()
            
        case (.inAppBrowser, let status) where status == .open:
            openInAppBrowser()
        case (.choose, let status) where status == .open:
            let alertVC = R.storyboard.mollieAlert.customAlertViewController { coder -> MollieAlertViewController? in
                MollieAlertViewController(
                    coder: coder,
                    options: MollieAlertConfig.chooseBrowser,
                    delegate: self
                )
            }!

            controller.present(alertVC, animated: false, completion: nil)
        case (_, let status) where status != .open:
            let config = MollieAlertConfig(
                title: R.string.localization.payment_status_title(),
                description: R.string.localization.payment_status_description(selectedPayment.status.rawValue),
                primaryButton: .ok)
            
            let alertVC = R.storyboard.mollieAlert.customAlertViewController { coder -> MollieAlertViewController? in
                MollieAlertViewController(
                    coder: coder,
                    options: config,
                    delegate: self
                )
            }!
            controller.present(alertVC, animated: false, completion: nil)
        default: break
        }
    }
    
    private func openExternalBrowser() {
        guard
            let paymentURL = selectedPayment.url,
            let url = URL(string: paymentURL)
        else { return }

        UIApplication.shared.open(url)
        
        if let controller = self.currentViewController,
            self.isInCreatePayment(controller) == true {
            // Close payment creation screen
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    private func openInAppBrowser() {
        guard let inAppBrowserVC = R.storyboard.inAppBrowser.instantiateInitialViewController(creator: { coder -> InAppBrowserViewController? in
            InAppBrowserViewController(coder: coder, payment: self.selectedPayment)
        }) else { return }
        
        if let controller = currentViewController,
            isInCreatePayment(controller) {
            // Clear current stack
            controller.navigationController?.setViewControllers([inAppBrowserVC], animated: true)
        } else {
            // Push it to the stack
            currentViewController?.navigationController?.pushViewController(inAppBrowserVC, animated: true)
        }
    }
    
    private func isInCreatePayment(_ controller: UIViewController) -> Bool {
        return controller.navigationController?.viewControllers.contains(where: { $0 is CreatePaymentViewController }) == true
    }
}

// MARK: - MollieAlertDelegate
extension PaymentFlowNavigation : MollieAlertDelegate {
    
    func triggered(action: ButtonActionTriggerProtocol) {
        switch action {
        case PaymentTrigger.openWebBrowser(let type) where type == .externalBrowser:
            openExternalBrowser()
        
        case PaymentTrigger.openWebBrowser(let type) where type == .inAppBrowser:
            openInAppBrowser()
            
        default:
            break
        }
        
        currentViewController = nil
    }
}
