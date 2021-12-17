import Foundation

struct MollieAlertConfig {
    let title: String
    let description: String
    let primaryButton: AlertButton
    var secondaryButton: AlertButton? = nil
    
    static let chooseBrowser =
        MollieAlertConfig(
            title: R.string.localization.payments_checkout_select_flow_title(),
            description: R.string.localization.payments_checkout_select_flow_description(),
            primaryButton: AlertButton(
                title: R.string.localization.payments_checkout_select_flow_external_browser(),
                type: .primary,
                action: PaymentTrigger.openWebBrowser(type: .externalBrowser)),
            secondaryButton: AlertButton(
                title: R.string.localization.payments_checkout_select_flow_in_app_browser(), type: .secondary,
                action: PaymentTrigger.openWebBrowser(type: .inAppBrowser)))
}

struct AlertButton {
    let title: String
    let type: MollieButtonType
    let action: ButtonActionTriggerProtocol?
    static let ok = AlertButton(title: R.string.localization.general_ok(), type: .primary, action: nil)
}
