import Foundation

class RelativeDateFormatterService {
    
    static func getFormatter(timeStyle: DateFormatter.Style) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = timeStyle
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale.current
         
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }
}

