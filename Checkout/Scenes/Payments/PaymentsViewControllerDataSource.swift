import UIKit

class PaymentsViewControllerDataSource: NSObject {
    
    private(set) var items = [(key: String, value: [Payment])]()
    
    func set(items: [(key: String, value: [Payment])]) {
        self.items = items
    }
}

extension PaymentsViewControllerDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let groupedElement = items.map({$0.key})[section]
        return groupedElement
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = items.map({$0.key})[section]
        return items.first(where: {$0.key == section})?.value.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.paymentTableViewCell, for: indexPath) else { return .init() }
        
        let section = items.map({$0.key})[indexPath.section]
        guard let payments = items.first(where: {$0.key == section})?.value else { return cell }
        let payment = payments[indexPath.item]
        
        cell.configure(with: payment)
        return cell
    }
}
