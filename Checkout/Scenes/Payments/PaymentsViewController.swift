import UIKit

enum PaymentFlow {
    case externalBrowser
    case inAppBrowser
    case choose
}

enum PaymentTrigger: ButtonActionTriggerProtocol {
    case openWebBrowser(type: PaymentFlow)
}

protocol PaymentsViewControllerDelegate: AnyObject {
    func paymentCompleted()
}

class PaymentsViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var welcomeContentView: UIView!
    @IBOutlet weak var welcomeTitle: UILabel! {
        didSet { welcomeTitle.text = R.string.localization.payments_empty_title() }
    }
    @IBOutlet weak var welcomeDescription: UILabel! {
        didSet { welcomeDescription.text = R.string.localization.payments_empty_description() }
    }
    @IBOutlet weak var welcomeButton: PrimaryButton! {
        didSet { welcomeButton.setTitle(R.string.localization.payments_create_new(), for: []) }
    }
    
    // MARK: Properties
    private let dataSource = PaymentsViewControllerDataSource()
    private var selectedPayment: Payment?
    private let payments: [Payment]
    
    init?(coder: NSCoder, payments: [Payment]) {
        self.payments = payments
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        navigationItem.title = R.string.localization.payments_title()
        setupTableView()
        display(payments: payments)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPayments()
    }

    @objc func applicationWillEnterForeground(_ notification: Notification) {
        refreshPayments()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.register(R.nib.paymentTableViewCell)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshPayments), for: .valueChanged)
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
    }
    
    private func display(payments: [Payment]) {
        
        let dateFormatter = RelativeDateFormatterService.getFormatter(timeStyle: .none)
        
        let grouped = Dictionary(grouping: payments) { payment -> String in
            dateFormatter.string(from: payment.createdAt ?? Date())
        }
    
        DispatchQueue.main.async { [weak self, weak dataSource] in
            self?.tableView.refreshControl?.endRefreshing()
            dataSource?.set(items: grouped.sorted(by: { $0.value.first?.createdAt ?? Date() > $1.value.first?.createdAt ?? Date() }))
            self?.tableView.reloadData()
            self?.welcomeContentView.isHidden = !payments.isEmpty
        }
    }
    
    // MARK: Actions
    @IBAction func createTapped(_ sender: Any) {
        guard let navigationVC = R.storyboard.createPayment.instantiateInitialViewController() else { return }
        navigationVC.presentationController?.delegate = self // Set the delegate
        present(navigationVC, animated: true, completion: nil)
    }
    
    @objc func refreshPayments() {
        getPayments()
    }
    
    private func getPayments() {
        PaymentService.shared.getPayments { [weak self] result in
            switch result {
            case .success(let payments):
                self?.display(payments: payments)
            case .failure(let error):
                print(error)
                self?.display(payments: [])
            }
        }
    }
    
    private func openSelectedPayment() {
        guard let payment = selectedPayment else { return }
        let paymentFlowNavigation = PaymentFlowNavigation(selectedPayment: payment)
        paymentFlowNavigation.executePayment(controller: self)
    }
}

// MARK: UITableViewDelegate
extension PaymentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = dataSource.items.map({$0.key})[indexPath.section]
        guard let payments = dataSource.items.first(where: {$0.key == section})?.value else { return }
        let payment = payments[indexPath.item]
        selectedPayment = payment
        openSelectedPayment()
    }
}

// MARK: UIAdaptivePresentationControllerDelegate
extension PaymentsViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        refreshPayments()
    }
}

// MARK: - PaymentsViewControllerDelegate
// Retrieves callbacks from the deep-link
extension PaymentsViewController: PaymentsViewControllerDelegate {
    
    func paymentCompleted() {
        refreshPayments()
        presentedViewController?.dismiss(animated: true, completion: nil)
        navigationController?.popToRootViewController(animated: true)
    }
}
