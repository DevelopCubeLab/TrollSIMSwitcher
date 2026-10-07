import Foundation

class SIMSlot {
    let slot: Int // 所在卡槽
    let uuid: UUID // 卡槽的UUID
    let ICCID: String // 卡槽的ICCID
    let label: String // 卡标签
    let operatorName: String // 卡连接的运营商
    let phoneNumber: String? // 电话号码
    let registrationStatus: CoreTelephonyEnumMapper.RegistrationStatus // 注册状态
    let isEnabled: Bool // 是否启用
    let isDataPreferred: Bool // 是否首选的数据卡槽
    let supportedRates: [Int] // 支持的网络类型
    let currentRate: Int // 当前的网络类型
    
    init(slot: Int, uuid: UUID, ICCID: String, label: String, operatorName: String, phoneNumber: String?, registrationStatus: CoreTelephonyEnumMapper.RegistrationStatus, isEnabled: Bool, isDataPreferred: Bool, supportedRates: [Int], currentRate: Int) {
        self.slot = slot
        self.uuid = uuid
        self.ICCID = ICCID
        self.label = label
        self.operatorName = operatorName
        self.phoneNumber = phoneNumber
        self.registrationStatus = registrationStatus
        self.isEnabled = isEnabled
        self.isDataPreferred = isDataPreferred
        self.supportedRates = supportedRates
        self.currentRate = currentRate
    }
    
    func toString() -> String {
        return "SIMSlot(slot: \(slot), uuid: \(uuid), ICCID: \(ICCID), label: \(label), operatorName: \(operatorName), phoneNumber: \(phoneNumber ?? "nil"), registrationStatus: \(registrationStatus), isEnabled: \(isEnabled), isDataPreferred: \(isDataPreferred), supportedRates: \(supportedRates), currentRate: \(currentRate))"
    }
}
