import Foundation

class CoreTelephonyEnumMapper {
    // 注册状态枚举
    enum RegistrationStatus {
        case registeredHome          // 本地网络已注册
        case registeredRoaming       // 漫游已注册
        case notRegistered           // 未注册
        case searching               // 搜索中
        case denied                  // 被拒绝
        case emergencyOnly           // 仅紧急呼叫
        case modemRestart            // 基带服务重启中
        case unknown(raw: String?)
    }
    
    // 遍历注册状态枚举
    static func mapRegistrationStatus(_ raw: String?) -> RegistrationStatus {
        switch raw {

        case "kCTRegistrationStatusRegisteredHome":
            return .registeredHome

        case "kCTRegistrationStatusRegisteredRoaming":
            return .registeredRoaming

        case "kCTRegistrationStatusNotRegistered":
            return .notRegistered

        case "kCTRegistrationStatusSearching":
            return .searching

        case "kCTRegistrationStatusDenied":
            return .denied

        case "kCTRegistrationStatusEmergencyOnly":
            return .emergencyOnly

        case "kCTRegistrationStatusUnknown":
            return .modemRestart
            
        default:
            return .unknown(raw: raw)
        }
    }
    
    // 本地化输出注册状态
    static func localizedRegistrationStatusText(rawStatus: String?) -> String {
        return localizedRegistrationStatusText(status: mapRegistrationStatus(rawStatus))
    }
    
    // 本地化输出注册状态
    static func localizedRegistrationStatusText(status: CoreTelephonyEnumMapper.RegistrationStatus) -> String {
        switch status {
            
        case .registeredHome:
            return NSLocalizedString("RegistrationRegisteredHome", comment: "已注册（本地网络）")
        case .registeredRoaming:
            return NSLocalizedString("RegistrationRegisteredRoaming", comment: "已注册（漫游网络）")
        case .notRegistered:
            return NSLocalizedString("RegistrationNotRegistered", comment: "未注册")
        case .searching:
            return NSLocalizedString("RegistrationSearching", comment: "搜索网络中")
        case .denied:
            return NSLocalizedString("RegistrationDenied", comment: "网络拒绝注册")
        case .emergencyOnly:
            return NSLocalizedString("RegistrationEmergencyOnly", comment: "仅限紧急呼叫")
        case .modemRestart:
            return NSLocalizedString("Checking", comment: "") // 基带服务重启中
        case .unknown(let raw):
            return raw ?? NSLocalizedString("Unknown", comment: "未知")
            
        }
    }
}
