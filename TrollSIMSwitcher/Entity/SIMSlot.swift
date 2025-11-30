import Foundation

class SIMSlot {
    let slot: Int // 所在卡槽
    let uuid: UUID // 卡槽的UUID
    let label: String // 卡标签
    let operatorName: String // 卡当前运营商
    let phoneNumber: String? // 电话号码
    let registrationStatus: String // 注册状态
    let isEnabled: Bool // 是否启用
    let isDataPreferred: Bool // 是否首选的数据卡槽
    let supportedRates: CTSupportedMaxDataRates? // 支持的网络类型
    let currentRate: Int64 // 当前的网络类型
    let supports5G: Bool // 是否支持5G
    let IMEI: String? // 当前卡槽的IMEI
    
    init(slot: Int, uuid: UUID, label: String, operatorName: String, phoneNumber: String?, registrationStatus: String, isEnabled: Bool, isDataPreferred: Bool, supportedRates: CTSupportedMaxDataRates?, currentRate: Int64, supports5G: Bool, IMEI: String?) {
        self.slot = slot
        self.uuid = uuid
        self.label = label
        self.operatorName = operatorName
        self.phoneNumber = phoneNumber
        self.registrationStatus = registrationStatus
        self.isEnabled = isEnabled
        self.isDataPreferred = isDataPreferred
        self.supportedRates = supportedRates
        self.currentRate = currentRate
        self.supports5G = supports5G
        self.IMEI = IMEI
    }
    
    func toString() -> String {
            let imeiStr = IMEI ?? "无"
            
            // supportedRates 可能为 nil，CTSupportedMaxDataRates.rates 是 [Any]
            let ratesDesc: String = {
                if let r = supportedRates?.rates as? [NSNumber] {
                    return r.map { $0.stringValue }.joined(separator: ", ")
                }
                return "无"
            }()
            
            let readableCurrentRate: String = {
                switch currentRate {
                case 2: return "3G"
                case 3: return "4G/LTE"
                case 4: return "5G"
                case 5: return "5G SA"
                default: return "未知(\(currentRate))"
                }
            }()
            
            return """
            ---- SIM Slot \(slot) ----
            标签：\(label)
            UUID：\(uuid)
            当前运营商名称：\(operatorName)
            电话号码：\(phoneNumber ?? "无")
            注册状态：\(registrationStatus)
            是否启用：\(isEnabled ? "是" : "否")
            是否首选数据卡槽：\(isDataPreferred ? "是" : "否")
            当前网络：\(readableCurrentRate)
            支持的速率：\(ratesDesc)
            支持 5G：\(supports5G ? "是" : "否")
            IMEI：\(imeiStr)
            -------------------------
            """
        }
}
