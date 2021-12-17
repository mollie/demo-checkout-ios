import Foundation
import UIKit

class CreatePaymentViewController: UITableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var createPaymentLabel: UILabel!
    @IBOutlet weak var currencySymbolLabel: UILabel!
    @IBOutlet weak var createPaymentsBodyLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField! {
        didSet {
            amountTextField.delegate = self
        }
    }
    @IBOutlet weak var descriptionTextField: UITextField!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        amountTextField.placeholder = R.string.localization.create_payment_hint_amount()
        descriptionTextField.placeholder = R.string.localization.create_payment_hint_description()
        
        createPaymentLabel.text = R.string.localization.create_payment_title()
        createPaymentsBodyLabel.text = R.string.localization.create_payment_description()
        tableView.gestureRecognizers?.append(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
        
        currencySymbolLabel.text = "€"
        guard let randomProduct = RandomProducts.allCases.randomElement()?.productInfo else { return }
        amountTextField.text = randomProduct.price.toCurrencyString(withSymbol: false)
        descriptionTextField.text = randomProduct.name
    }
    
    // MARK: Actions
    @IBAction func cancelTapped(_ sender: Any) {
        if let presentingPresentationController = presentingViewController?.presentationController {
            presentingPresentationController.delegate?.presentationControllerDidDismiss?(presentingPresentationController)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createTapped(_ sender: Any) {
        guard let productInfo = getProductInfo() else { return }
        
        if kSelectPaymentMethod {
            let storyboard = R.storyboard.createPayment()
            let identifier = R.storyboard.createPayment.selectPaymentViewController.identifier
            let selectPaymentVC = storyboard.instantiateViewController(identifier: identifier) { coder -> SelectPaymentViewController? in
                SelectPaymentViewController(coder: coder, selectedProduct: productInfo)
            }
            navigationController?.pushViewController(selectPaymentVC, animated: true)
        } else {
            createPayment(from: productInfo) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let payment):
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let paymentFlowNavigation = PaymentFlowNavigation(selectedPayment: payment)
                        paymentFlowNavigation.executePayment(controller: self)
                    }
                }
            }
        }
    }
    
    @objc func backgroundTapped() {
        view.endEditing(true)
    }
}

// MARK: Privates
private extension CreatePaymentViewController {
    
    func getProductInfo() -> ProductInfo? {
        reformatTextField()
        guard let amount = amountTextField.text,
              let price = amount.fromCurrencyToDouble(),
              price > 0 else {
            let config = MollieAlertConfig(
                title: R.string.localization.create_payment_error_missing_amount_title(),
                description: R.string.localization.create_payment_error_missing_amount_body(),
                primaryButton: .ok)
            presentAlert(with: config)
            return nil
        }
        guard let description = descriptionTextField.text, description != ""
        else {
            let config = MollieAlertConfig(
                title: R.string.localization.create_payment_error_missing_description_title(),
                description: R.string.localization.create_payment_error_missing_description_body(),
                primaryButton: .ok)
            presentAlert(with: config)
            return nil
        }
        return ProductInfo(name: description, price: price.round(to: 2))
    }
    
    func createPayment(from product: ProductInfo, completion: @escaping ((Result<Payment, Error>) -> ())) {
        PaymentService.shared.createPayment(requestBody: CreatePayment(amount: product.price.round(to: 2), description: product.name)) { result in
            switch result {
            case .success(let payment):
                completion(.success(payment))
            case .failure(let error):
                completion(.failure(error))
                print(error)
            }
        }
    }
    
    func presentAlert(with alertConfig: MollieAlertConfig) {
        view.endEditing(true)
        let storyboard = R.storyboard.mollieAlert()
        let identifier = R.storyboard.mollieAlert.customAlertViewController.identifier
        let alertVC = storyboard.instantiateViewController(identifier: identifier) { coder -> MollieAlertViewController? in
            MollieAlertViewController(
                coder: coder,
                options: alertConfig,
                delegate: nil)
        }
        present(alertVC, animated: false, completion: nil)
    }
}

// MARK: UITextFieldDelegate
extension CreatePaymentViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        reformatTextField()
    }
    
    func reformatTextField() {
        guard let amountString = amountTextField.text, let amount = Double(amountString) else { return }
        amountTextField.text = amount.toCurrencyString(withSymbol: false)
    }
}
