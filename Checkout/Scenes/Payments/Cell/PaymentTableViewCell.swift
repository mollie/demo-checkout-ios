import UIKit

class PaymentTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentIconView: UIView! {
        didSet { paymentIconView.layer.cornerRadius = 8 }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusView: UIView! {
        didSet { statusView.layer.cornerRadius = 3 }
    }
    @IBOutlet weak var statusLabel: UILabel!
    
    func configure(with payment: Payment) {
        amountLabel.text = payment.amount.toCurrencyString(withSymbol: true)
        amountLabel.sizeToFit()
        layoutIfNeeded()
        
        statusLabel.text = payment.status.rawValue.uppercased()
        statusView.backgroundColor = payment.status.backgroundColor
        
        statusLabel.textColor = .systemBackground
        
        if let date = payment.createdAt {
            let dateFormatter = RelativeDateFormatterService.getFormatter(timeStyle: .short)
            dateLabel.text = dateFormatter.string(from: date)
        }
        descriptionLabel.text = payment.description
        descriptionLabel.sizeToFit()
    }
}
