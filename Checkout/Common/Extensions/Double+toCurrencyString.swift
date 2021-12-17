import Foundation

fileprivate let numberFormatter = { () -> NumberFormatter in
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

extension Double {
    
    func toCurrencyString(withSymbol: Bool) -> String? {
        let formatter = numberFormatter
        if let currencyString = formatter.string(from: self.round(to: 2) as NSNumber) {
            return withSymbol
                ? "€" + currencyString
                : currencyString
        } else {
            return String(self)
        }
    }
}

extension String {
    
    func fromCurrencyToDouble() -> Double? {
        let formatter = numberFormatter
        return formatter.number(from: self) as? Double
    }
}
