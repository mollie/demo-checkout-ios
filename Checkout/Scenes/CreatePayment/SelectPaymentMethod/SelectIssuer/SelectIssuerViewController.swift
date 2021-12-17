import UIKit

class SelectIssuerViewController: UIViewController {
    
    // MARK: Properties
    var collectionView: UICollectionView!
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Int, CheckoutItem>!
    
    // MARK: Creation
    let method: Method
    let issuers: [Issuer]
    let productInfo: ProductInfo
    private var createdPayment: Payment?
    
    init?(coder: NSCoder, method: Method, productInfo: ProductInfo) {
        self.method = method
        self.issuers = method.issuers ?? []
        self.productInfo = productInfo
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = R.string.localization.select_issuer_title()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localization.general_continue(), style: .plain, target: self, action: #selector(continueTapped))
        setupCollectionView()
        setupDataSources()
        createSnapshotCollectionView(issuers: issuers)
    }
    
    private func setupCollectionView() {
        let layout = createCollectionViewLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView?.register(R.nib.selectPaymentCollectionViewCell)
        view.addSubview(collectionView)
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
    
    private func setupDataSources() {
        collectionViewDataSource = UICollectionViewDiffableDataSource<Int, CheckoutItem>(collectionView: collectionView, cellProvider: { collectionView, indexPath, cellType -> SelectPaymentCollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.selectPaymentCollectionViewCell, for: indexPath) else { return .init() }
            cell.configure(with: cellType)
            return cell
        })
    }
    
    private func createSnapshotCollectionView(issuers: [Issuer]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CheckoutItem>()
        
        let cellTypes = issuers.map(CheckoutItem.issuer(issuer:))
        snapshot.appendSections([.zero])
        cellTypes.forEach { cellType in
            snapshot.appendItems([cellType], toSection: .zero)
        }
        collectionViewDataSource.apply(snapshot)
    }
    
    // MARK: Actions
    
    @objc func continueTapped() {
        guard let selectedCell = collectionView.indexPathsForSelectedItems?.first else { return }
        let cellType = collectionViewDataSource.itemIdentifier(for: selectedCell)
        guard let id = cellType?.selectableItem.id else { return }
        createPayment(issuerId: id)
    }
    
    // MARK: Logic
    
    private func createPayment(issuerId: String) {
        PaymentService.shared.createPayment(
            requestBody:
                CreatePayment(
                    method: method.id,
                    issuer: issuerId,
                    amount: productInfo.price,
                    description: productInfo.name
                )) { [weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let payment):
                self?.createdPayment = payment
                let paymentFlowNavigation = PaymentFlowNavigation(selectedPayment: payment)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    paymentFlowNavigation.executePayment(controller: self)
                }
            }
        }
    }
}
