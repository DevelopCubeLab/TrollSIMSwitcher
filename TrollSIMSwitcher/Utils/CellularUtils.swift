import Foundation

class CellularUtils {
    
    static func getRateText(rate: Int) -> String {
        switch rate {
            case 1: return "2G"
            case 2: return "3G"
            case 3: return "4G"
            case 4: return "5G"
            default: return NSLocalizedString("Unknown", comment: "")
        }
    }
    
}
