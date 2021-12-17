import UIKit

enum ViewingOption: Int {
    case tableView = 0
    case collectionView
    
    var isTableViewHidden: Bool { self != .tableView }
    var isCollectionViewHidden: Bool { self != .collectionView }
}

class SelectPaymentViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var segmentControl: UISegmentedControl!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButton: UIBarButtonItem!
    
    // MARK: Properties
    private var tableView: UITableView!
    private var collectionView: UICollectionView!
    private var dataSource = SelectPaymentDataSource()
    
    private let selectedProduct: ProductInfo
    private var createdPayment: Payment?
    var selectedViewingOption: ViewingOption? {
        ViewingOption(rawValue: segmentControl.selectedSegmentIndex)
    }

    // MARK: Dependency Injection
    init?(coder: NSCoder, selectedProduct: ProductInfo) {
        self.selectedProduct = selectedProduct
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
        setupDataSources()
        getIssuers()
    }
    
    private func setupUI() {
        titleLabel.text = R.string.localization.select_issuer_title()
        descriptionLabel.text = R.string.localization.select_method_body()
        continueButton.isEnabled = false
        isModalInPresentation = true
    }
    
    private func setupTableView() {
        let insets = UIEdgeInsets(top: headerHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        tableView = UITableView(frame: containerView.bounds, style: .plain)
        tableView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView?.delegate = self
        tableView?.rowHeight = 56
        tableView?.contentInset = insets
        tableView?.scrollIndicatorInsets = insets
        tableView?.register(R.nib.selectPaymentTableViewCell)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshedTriggered), for: .valueChanged)
        tableView?.refreshControl = refreshControl
        containerView.addSubview(tableView)
    }
    
    private func setupCollectionView() {
        let insets = UIEdgeInsets(top: headerHeightConstraint.constant, left: 0, bottom: 0, right: 0)
        let layout = createCollectionViewLayout()
        collectionView = UICollectionView(frame: containerView.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.isHidden = true
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
        collectionView.backgroundColor = .clear
        collectionView?.register(R.nib.selectPaymentCollectionViewCell)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshedTriggered), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        containerView.addSubview(collectionView)
    }
    
    private func setupDataSources() {
        dataSource.delegate = self
        
        // Configure DiffableDataSource for the tableView
        dataSource.tableViewDataSource = UITableViewDiffableDataSource<Int, CheckoutItem>(tableView: tableView) { tableView, indexPath, cellType -> SelectPaymentTableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.selectPaymentTableViewCell, for: indexPath) else { return .init() }
            cell.configure(with: cellType)
            return cell
        }
        
        // Configure DiffableDataSource for the collectionView
        dataSource.collectionViewDataSource = UICollectionViewDiffableDataSource<Int, CheckoutItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, cellType -> SelectPaymentCollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.selectPaymentCollectionViewCell, for: indexPath) else { return .init() }
            cell.configure(with: cellType)
            return cell
        })
    }
    
    // MARK: Logic
    
    private func getIssuers() {
        MethodsService.shared.getActiveMethods(by: selectedProduct.price) { [weak self, weak dataSource] result in
            if case let .success(methods) = result {
                DispatchQueue.main.async { [weak self, weak dataSource] in
                    dataSource?.createSnapshot(with: methods)
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(126))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing: CGFloat = 3
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 0, trailing: 3)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: Actions
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        switch (selectedViewingOption, dataSource.selectedMethod) {
        case (.collectionView, .some(let method)) where method.hasIssuers:
            let storyboard = R.storyboard.createPayment()
            let identifier = R.storyboard.createPayment.selectIssuerCollectionViewController.identifier
            let vc = storyboard.instantiateViewController(identifier: identifier, creator: { [weak self] coder -> SelectIssuerViewController? in
                guard let self = self else { return nil }
                return SelectIssuerViewController(coder: coder, method: method, productInfo: self.selectedProduct)
            })
            navigationController?.pushViewController(vc, animated: true)
        default:
            PaymentService.shared.createPayment(
                requestBody: dataSource.getRequestBody(product: selectedProduct)) { [weak self] result in
                switch result {
                case .success(let payment):
                    let paymentFlowNavigation = PaymentFlowNavigation(selectedPayment: payment)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.createdPayment = payment
                        paymentFlowNavigation.executePayment(controller: self)
                    }
                case .failure(let error):
                    print(error)
                    break
                }
            }
        }
    }
    
    /// This function switches the currently selected viewing option, when switching, it configures the tableView / collectionView to sync the changes.
    /// - Parameter sender: some UISegmentedControl
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        // Show the correct viewing option
        guard let toViewingOption = ViewingOption(rawValue: segmentControl.selectedSegmentIndex) else { return }
        tableView.isHidden = toViewingOption.isTableViewHidden
        collectionView.isHidden = toViewingOption.isCollectionViewHidden
        
        // Syncronize data
        switch (to: toViewingOption, dataSource.selectedCell, dataSource.expandedMethod) {
        // MARK: - Switch to Table View
        case (to: .tableView, _, .some(let method)):
            let cellType = CheckoutItem.method(method: method)
            let index = dataSource.tableViewDataSource.indexPath(for: cellType)
            tableView.selectRow(at: index, animated: false, scrollPosition: .middle)
            
        case (to: .tableView, .method(let method), _) where method.hasIssuers:
            /// Expand the payment method
            let cellType = CheckoutItem.method(method: method)
            guard let index = dataSource.tableViewDataSource.indexPath(for: cellType) else { return }
            dataSource.expand(method: method, at: index.section)
            tableView.scrollToRow(at: index, at: .top, animated: true)
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
            
        case (to: .tableView, .some(let cellType), _):
            /// Select cellType
            let index = dataSource.tableViewDataSource.indexPath(for: cellType)
            tableView.selectRow(at: index, animated: false, scrollPosition: .middle)
            
        // MARK: - Switch to Collection View
        case (to: .collectionView, .issuer, .some(let method)), (.collectionView, .method(let method), _):
            let index = dataSource.collectionViewDataSource.indexPath(for: CheckoutItem.method(method: method))
            collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredVertically)
            
        case (to: .collectionView, _, .some(let method)):
            let cellType = CheckoutItem.method(method: method)
            let index = dataSource.collectionViewDataSource.indexPath(for: cellType)
            collectionView.selectItem(at: index, animated: false, scrollPosition: .centeredVertically)
            
        default: break
        }
        
        // Change continue button state
        if let expandedMethod = dataSource.expandedMethod {
            let cellType = CheckoutItem.method(method: expandedMethod)
            selected(cellType)
        } else if let cellType = dataSource.selectedCell {
            selected(cellType)
        }
    }
    
    @objc func refreshedTriggered() {
        getIssuers()
    }
}

// MARK: - UITableViewDelegate
extension SelectPaymentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellType = dataSource.tableViewDataSource.itemIdentifier(for: indexPath) else { return }
        
        switch cellType {
        case .method(let method) where method.hasIssuers:
            dataSource.expand(method: method, at: indexPath.section)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        case .method, .issuer:
            dataSource.toggleSelected(of: cellType)
        }
    }
}


// MARK: - UICollectionViewDelegate
extension SelectPaymentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellType = dataSource.collectionViewDataSource.itemIdentifier(for: indexPath) else { return }
        dataSource.toggleSelected(of: cellType)
    }
}

// MARK: - SelectIssuerDataSourceDelegate
extension SelectPaymentViewController: SelectIssuerDataSourceDelegate {
    
    func deselect(cellType: CheckoutItem) {
        switch selectedViewingOption {
        case .tableView:
            guard let tableViewIndex = dataSource.tableViewDataSource.indexPath(for: cellType) else { return }
            tableView.deselectRow(at: tableViewIndex, animated: true)
        case .collectionView:
            guard let collectionViewIndex = dataSource.collectionViewDataSource.indexPath(for: cellType) else { return }
            collectionView.deselectItem(at: collectionViewIndex, animated: true)
        default:
            break
        }
    }
    
    func selected(_ cellType: CheckoutItem?) {
        switch (selectedViewingOption, cellType) {
        // Table View
        case (.tableView, .method(let method)):
            continueButton.isEnabled = !method.hasIssuers
        case (.tableView, .some):
            continueButton.isEnabled = true
        case (.tableView, .none):
            continueButton.isEnabled = false
        // Collection View
        case (.collectionView, .none):
            continueButton.isEnabled = false
        case (.collectionView, .some):
            continueButton.isEnabled = true
        default:
            break
        }
    }
}
