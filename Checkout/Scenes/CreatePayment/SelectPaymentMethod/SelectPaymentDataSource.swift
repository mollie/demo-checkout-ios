import UIKit

protocol SelectIssuerDataSourceDelegate: AnyObject {
    func selected(_ cellType: CheckoutItem?)
    func deselect(cellType: CheckoutItem)
}

class SelectPaymentDataSource {
    
    weak var delegate: SelectIssuerDataSourceDelegate?
    
    var tableViewDataSource: UITableViewDiffableDataSource<Int, CheckoutItem>!
    var collectionViewDataSource: UICollectionViewDiffableDataSource<Int, CheckoutItem>!
    
    private(set) var expandedMethod: Method? {
        didSet {
            if let method = expandedMethod {
                delegate?.selected(CheckoutItem.method(method: method))
            } else {
                delegate?.selected(nil)
            }
        }
    }
    private(set) var selectedCell: CheckoutItem? {
        didSet { delegate?.selected(selectedCell) }
    }
    var selectedIssuer: Issuer? {
        if case .issuer(let issuer) = selectedCell {
            return issuer
        } else {
            return nil
        }
    }
    
    var selectedMethod: Method? {
        guard expandedMethod == nil else { return expandedMethod }
        if case .method(let method) = selectedCell {
            return method
        } else {
            return nil
        }
    }
    
    func getRequestBody(product: ProductInfo) -> CreatePayment {
        CreatePayment(
            method: selectedMethod?.id,
            issuer: selectedIssuer?.id,
            amount: product.price,
            description: product.name)
    }
    
    func createSnapshot(with methods: [Method]) {
        createSnapshotForTableView(methods: methods)
        createSnapshotCollectionView(methods: methods)
    }
    
    func toggleSelected(of cellTypeToSelect: CheckoutItem) {
        if shouldCollapseCurrentMethod(newCellType: cellTypeToSelect) {
            collapse(method: expandedMethod)
        }
        
        if cellTypeToSelect == selectedCell {
            selectedCell = nil
            delegate?.deselect(cellType: cellTypeToSelect)
        } else {
            selectedCell = cellTypeToSelect
        }
    }
}

// MARK: TableView Methods
extension SelectPaymentDataSource {
    
    func expand(method: Method, at section: Int) {
        guard method != expandedMethod else { return collapse(method: method) }
        
        if let selectedCell = selectedCell {
            delegate?.deselect(cellType: selectedCell)
        }
        if let currentExpandedMethod = expandedMethod {
           collapse(method: currentExpandedMethod)
        }
        var currentSnapshot = tableViewDataSource.snapshot()
        
        // Append new items to the snapshot.
        guard let issuers = method.issuers?.map(CheckoutItem.issuer(issuer:)) else { return }
        
        currentSnapshot.appendItems(issuers, toSection: section)
        tableViewDataSource.apply(currentSnapshot)
        selectedCell = CheckoutItem.method(method: method)
        expandedMethod = method
    }
    
    private func collapse(method: Method?) {
        guard let issuers = method?.issuers?.map(CheckoutItem.issuer(issuer:)) else { return }
        var currentSnapshot = tableViewDataSource.snapshot()
        currentSnapshot.deleteItems(issuers)
        tableViewDataSource.apply(currentSnapshot)
        selectedCell = nil
        expandedMethod = nil
    }
    
    private func shouldCollapseCurrentMethod(newCellType: CheckoutItem) -> Bool {
        guard expandedMethod != nil else { return false }
        switch newCellType {
        case .issuer(let issuer):
            return expandedMethod?.issuers?.contains(issuer) == false
        case .method:
            return true
        }
    }
}

// MARK: Creating Snapshots
private extension SelectPaymentDataSource {
    
    func createSnapshotForTableView(methods: [Method]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CheckoutItem>()
        
        let cellTypes = methods.map(CheckoutItem.method(method:))
        let amountOfSections = (0..<methods.count).map { $0 }
        snapshot.appendSections(amountOfSections)
        zip(amountOfSections, cellTypes).forEach { index, cellType in
            snapshot.appendItems([cellType], toSection: index)
            if let method = selectedMethod, method == expandedMethod {
                let issuers = method.issuers?.map(CheckoutItem.issuer(issuer:)) ?? []
                snapshot.appendItems(issuers, toSection: index)
            }
        }
        tableViewDataSource.apply(snapshot)
    }
    
    func createSnapshotCollectionView(methods: [Method]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CheckoutItem>()
        
        let cellTypes = methods.map(CheckoutItem.method(method:))
        snapshot.appendSections([.zero])
        cellTypes.forEach { cellType in
            snapshot.appendItems([cellType], toSection: .zero)
        }
        collectionViewDataSource.apply(snapshot)
    }
}
