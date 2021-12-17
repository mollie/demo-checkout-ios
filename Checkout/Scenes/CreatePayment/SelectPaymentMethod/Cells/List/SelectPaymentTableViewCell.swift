import UIKit
import Nuke

class SelectPaymentTableViewCell: UITableViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    
    // MARK: Properties
    private let selectedIcon = UIImage(systemName: "checkmark.circle.fill")
    private let groupIcon = UIImage(systemName: "chevron.down")
    private var cellType: CheckoutItem?
    
    // MARK: Methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch cellType {
        case .issuer, .none:
            stateImageView.image = selected ? selectedIcon : nil
        case .method(let method):
            stateImageView.image = method.hasIssuers
                ? groupIcon
                : selected ? selectedIcon : nil
        }
    }
    
    func configure(with item: CheckoutItem) {
        self.cellType = item
        
        // Setup common attributes
        titleLabel.text = item.selectableItem.title
        if let url = URL(string: item.selectableItem.image.size2x) {
            Nuke.loadImage(with: url, into: iconImageView)
        }
        
        // Setup CheckoutItem specific attributes
        switch item {
        case .issuer:
            backgroundColor = .secondarySystemBackground
            stateImageView.image = isSelected ? selectedIcon : nil
        case .method(let method):
            backgroundColor = .systemBackground
            stateImageView.image = method.hasIssuers
                ? groupIcon
                : isSelected ? selectedIcon : nil
        }
    }
}
