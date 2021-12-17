import UIKit

// Anything that conforms to this protocol will be called in a delegate
protocol ButtonActionTriggerProtocol { }

protocol MollieAlertDelegate: AnyObject {
    func triggered(action: ButtonActionTriggerProtocol)
}

class MollieAlertViewController: UIViewController {
    
    init?(coder: NSCoder, options: MollieAlertConfig, delegate: MollieAlertDelegate?) {
        self.config = options
        self.delegate = delegate
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var contentViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView! {
        didSet {
            contentView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = config.title
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel! {
        didSet {
            descriptionLabel.text = config.description
        }
    }
    @IBOutlet weak var primaryButton: PrimaryButton! {
        didSet {
            primaryButton.setTitle(config.primaryButton.title, for: [])
        }
    }
    @IBOutlet weak var secondaryButton: SecondaryButton! {
        didSet {
            if let button = config.secondaryButton {
                secondaryButton.setTitle(button.title, for: [])
            } else {
                secondaryButton.isHidden = true
            }
        }
    }
    
    // MARK: Properties
    private var delegate: MollieAlertDelegate?
    private let config: MollieAlertConfig
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animateIn()
    }
    
    func setupUI() {
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped)))
    }
    
    // MARK: Actions
    @IBAction func primaryButtonTapped(_ sender: Any) {
        animateOut(completion: { [weak delegate, config] in
            if let action = config.primaryButton.action {
                delegate?.triggered(action: action)
            }
            delegate = nil
        })
    }
    
    @IBAction func secondaryButtonTapped(_ sender: Any) {
        animateOut(completion: { [weak delegate, config] in
            if let action = config.secondaryButton?.action {
                delegate?.triggered(action: action)
            }
            delegate = nil
        })
    }
    
    @objc func backgroundTapped() {
        animateOut(completion: nil)
        delegate = nil
    }
}

// MARK: Privates
private extension MollieAlertViewController {
    
    func animateIn() {
        backgroundView.alpha = .zero
        contentViewCenterYConstraint.constant = UIScreen.main.bounds.height
        view.layoutIfNeeded()
        contentView.isHidden = false
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundView.alpha = 0.5
            self?.contentViewCenterYConstraint.constant = .zero
            self?.view.layoutIfNeeded()
        }
    }
    
    func animateOut(completion: ((() -> Void)?)) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.backgroundView.alpha = .zero
            self?.contentViewCenterYConstraint.constant = UIScreen.main.bounds.height
            self?.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: completion)
        }
    }
}
