import Foundation

struct ProductInfo {
    let name: String
    let price: Double
}

enum RandomProducts: String, CaseIterable {
    case walkman = "Walkman"
    case goldfish = "Goldfish"
    case backToTheFutureDVD = "Back to the future DVD"
    case runningShoes = "Running shoes"
    case haircutForMenAppointment = "Haircut for men - appointment"
    case electricVehicle = "Electric Vehicle"
    case comicBook = "Comic book"
    case gameConsole = "Game console"
    case drone = "Drone"
    case encyclopedia = "Encyclopedia"
    case robotArm = "Robot arm"
    case virtualRealityHeadset = "Virtual reality headset"
    case smartwatch = "Smartwatch"
    case spencer = "Spencer"
    
    var productInfo: ProductInfo {
        switch self {
        case .walkman:
            return ProductInfo(name: self.rawValue, price: 19.99)
        case .goldfish:
            return ProductInfo(name: self.rawValue, price: 2.99)
        case .backToTheFutureDVD:
            return ProductInfo(name: self.rawValue, price: 6)
        case .runningShoes:
            return ProductInfo(name: self.rawValue, price: 49)
        case .haircutForMenAppointment:
            return ProductInfo(name: self.rawValue, price: 29.95)
        case .electricVehicle:
            return ProductInfo(name: self.rawValue, price: 49_999)
        case .comicBook:
            return ProductInfo(name: self.rawValue, price: 7.5)
        case .gameConsole:
            return ProductInfo(name: self.rawValue, price: 495)
        case .drone:
            return ProductInfo(name: self.rawValue, price: 900)
        case .encyclopedia:
            return ProductInfo(name: self.rawValue, price: 28.99)
        case .robotArm:
            return ProductInfo(name: self.rawValue, price: 1_459)
        case .virtualRealityHeadset:
            return ProductInfo(name: self.rawValue, price: 599)
        case .smartwatch:
            return ProductInfo(name: self.rawValue, price: 379.95)
        case .spencer:
            return ProductInfo(name: self.rawValue, price: 28.75)
        }
    }
}
