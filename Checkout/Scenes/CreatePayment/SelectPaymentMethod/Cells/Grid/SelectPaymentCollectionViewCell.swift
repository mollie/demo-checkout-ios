import UIKit
import Nuke

class SelectPaymentCollectionViewCell: UICollectionViewCell {

    // MARK: IBOutlets
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var selectedBarView: UIView!
    
    // MARK: Properties
    private let selectedIcon = UIImage(systemName: "checkmark.circle.fill")
    private let groupIcon = UIImage(systemName: "chevron.down")
    
    // MARK: Methods
    func configure(with item: CheckoutItem) {
        // Check selected state
        checkmarkImageView.isHidden = !isSelected
        selectedBarView.isHidden = !isSelected
        
        // Set common atributes
        titleLabel.text = item.selectableItem.title
        if let url = URL(string: item.selectableItem.image.size2x) {
            Nuke.loadImage(with: url, into: iconImageView)
        }
        
        // Apply shadows and corner radius
        innerView.layer.masksToBounds = true
        innerView.layer.cornerRadius = 15
        innerView.layer.shadowColor = UIColor.black.cgColor
        innerView.layer.shadowOpacity = 0.1
        innerView.layer.shadowRadius = 2
        innerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    override var isSelected: Bool {
        didSet {
            checkmarkImageView.isHidden = !isSelected
            selectedBarView.isHidden = !isSelected
        }
    }
}
