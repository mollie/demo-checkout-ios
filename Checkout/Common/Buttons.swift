import UIKit

enum MollieButtonType {
    case primary
    case secondary
    
    var backgroundColor: UIColor? {
        switch self {
        case .primary:
            return .systemBlue
        case .secondary:
            return .secondarySystemFill
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .label
        }
    }
}

class BaseButton: UIButton {
    
    public var type: MollieButtonType = .primary
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        // setup UI
        clipsToBounds = true
        layer.cornerRadius = 12
        titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        
        // Setup actions
        sendActions(for: .touchDown)
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchCancel), for: .touchDragOutside)
        addTarget(self, action: #selector(touchDown), for: .touchUpInside)
    }
    
    func resetState() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.backgroundColor = self?.type.backgroundColor
        }
    }
    
    func set(color: MollieButtonType) {
        self.type = color
        setTitleColor(color.textColor, for: [])
        backgroundColor = color.backgroundColor
    }
    
    // MARK: Actions
    @objc func touchDown() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) { [weak self] in
            guard let self = self else { return }
            self.backgroundColor = self.type == .primary ?  R.color.darkBlue() : .systemGray4
        }
    }
    
    @objc func touchCancel() {
        resetState()
    }
}

class PrimaryButton: BaseButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func setup() {
        super.setup()
        set(color: .primary)
    }
}


class SecondaryButton: BaseButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func setup() {
        super.setup()
        set(color: .secondary)
    }
}
