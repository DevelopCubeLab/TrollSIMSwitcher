import Foundation
import CoreTelephony

class CoreTelephonyController: NSObject, CoreTelephonyClientDelegate, CoreTelephonyClientDataDelegateInternal, CoreTelephonyClientRegistrationDelegateInternal, CTTelephonyNetworkInfoDelegate {
    
    // 单例实例
    static let instance = CoreTelephonyController()
    
    //CoreTelephonyClient 实例
    private let coreTelephonyClient = CoreTelephonyClient()
    private let networkInfo = CTTelephonyNetworkInfo()
    
    private var IMEIs: [IMEI] = []
    
    private override init() {
        
        super.init()
        IMEIs = MGDeviceInfoController.instance.IMEIs
        coreTelephonyClient?.setDelegate(self)
        networkInfo.delegate = self
    }

    // 根据slot获取当前插槽的上下文
    private func getServiceSubscriptionContext(slot: Int) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(slot: Int32(slot))
    }
    
    // 根据slot的uuid获取当前插槽的上下文
    private func getServiceSubscriptionContext(uuid: UUID) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(uuid: uuid)
    }
    
    // 获取当前首选的卡槽ID
    func getDataPreferredSlotID() -> Int64 {
        return coreTelephonyClient!.getPreferredDataSubscriptionContextSync(nil)?.slotID ?? -1
    }
    
    // 获取所有SIM卡卡槽信息
    func getAllSIMSlots() -> [SIMSlot] {
        var slots: [SIMSlot] = []
        
        if IMEIs.isEmpty { // 拒绝Wi-Fi版iPad或者证书签名情况
            return slots
        }
        
        let slotCount = max(1, IMEIs.count) // 获取卡槽数量

        for slot in 1...slotCount {
            //获取当前卡槽信息
            if let context = getServiceSubscriptionContext(slot: slot) {
                // 获取当前卡槽位
                let slot = Int(context.slotID)
                // 获取当前卡槽的UUID
                let uuid = context.uuid ?? UUID()
                // 获取当前卡标签
                let label = coreTelephonyClient!.copyLabel(context, error: nil) ?? NSLocalizedString("Unknown", comment: "未知")
                // 获取当前运营商的名称
                let operatorName = coreTelephonyClient!.getLocalizedOperatorName(context, error: nil) ?? NSLocalizedString("Unknown", comment: "未知")
                // 获取当前卡的电话号码
//                let phoneNumber = coreTelephonyClient!.getPhoneNumber(context, error: nil)?.number ?? NSLocalizedString("Unknown", comment: "未知")
                let phoneNumber = coreTelephonyClient!.getPhoneNumber(context, error: nil)?.displayPhoneNumber ?? NSLocalizedString("Unknown", comment: "未知")
                // 获取当前SIM卡状态
                let isEnabled = coreTelephonyClient!.getSIMStatus(context, error: nil) == "kCTSIMSupportSIMStatusReady"
                // 获取当前信号注册状态
                let registrationStatus = coreTelephonyClient!.copyRegistrationStatus(context, error: nil) ?? NSLocalizedString("Unknown", comment: "未知")
                // 判断是否是当前的卡槽是首选流量卡
                let isDataPreferred = getDataPreferredSlotID() == slot
                // 获取当前卡支持的网络类型
                let supportedDataRates = coreTelephonyClient!.getSupportedDataRates(context, error: nil)
                // 判断是否支持5G
//                let supported5G = coreTelephonyClient!.getSupports5G(context, error: nil) // 获取不到 永远返回false
                var supported5G = false
                if let rates = supportedDataRates?.rates as? [NSNumber] {
                    supported5G = rates.contains(DataRates._5G.rawValue)
                }
                // 获取当前卡设置的网络类型
                let currentRate = coreTelephonyClient!.getMaxDataRate(context, error: nil)
                // 获取当前卡槽的IMEI
                let IMEIValue = IMEIs.indices.contains(slot - 1) ? IMEIs[slot - 1].value : ""
                
                slots.append(SIMSlot(slot: slot, uuid: uuid, label: label, operatorName: operatorName, phoneNumber: phoneNumber, registrationStatus: registrationStatus, isEnabled: isEnabled, isDataPreferred: isDataPreferred, supportedRates: supportedDataRates, currentRate: currentRate, supports5G: supported5G, IMEI: IMEIValue))
                
            } else { // 未获取到卡槽上下文，跳过
                continue
            }
        }
        
        return slots
    }
    
    // 切换卡槽流量
    func setDataSlot(slot: SIMSlot) -> Bool {
        
//        if slot.isDataPreferred { // 已经是首选的数据流量卡了就不要去切换了
//            return true
//        }
        let controlSlot: Int
        // 获取是否开启兼容性模式
        if SettingsUtils.instance.getEnableCompatibilitySwitchMode() {
            controlSlot = slot.slot == 1 ? 2 : 1
        } else {
            controlSlot = slot.slot
        }
        // 获取需要切换卡槽的context
//        if let context = getServiceSubscriptionContext(slot: slot.slot == 1 ? 2 : 1) {
        if let context = getServiceSubscriptionContext(slot: controlSlot) {
            // 切换数据卡
            coreTelephonyClient!.setActiveUserDataSelection(context, error: nil)
            
            return true
        }
        
        return false
    }
    
    // 切换网络类型
    func setDataRate(slot: SIMSlot, selectRate: Int64) -> Bool {
        if let context = getServiceSubscriptionContext(slot: slot.slot) {
            if let result = coreTelephonyClient!.setMaxDataRate(context, rate: selectRate) {
                NSLog("[TrollSIMSwitcher] 切换网络类型：\(result)") // result是返回的错误
                return false
            } else {
                return true
            }
        }
        
        return false
    }
    
    private func notifyUpdate() {
        NotificationCenter.default.post(
            name: Notification.Name("CoreTelephonyUpdated"),
            object: nil
        )
    }
    
//    func subscriptionInfoDidChange() {
//        NSLog("[TrollSIMSwitcher] subscriptionInfoDidChange")
////        notifyUpdate()
//    }
//
//    func activeSubscriptionsDidChange() {
//        NSLog("[TrollSIMSwitcher] activeSubscriptionsDidChange")
////        notifyUpdate()
//    }
//
//    func simLessSubscriptionsDidChange() {
//        NSLog("[TrollSIMSwitcher] simLessSubscriptionsDidChange")
////        notifyUpdate()
//    }
//
//    func dualSimCapabilityDidChange() {
//        NSLog("[TrollSIMSwitcher] dualSimCapabilityDidChange")
////        notifyUpdate()
//    }
    
    func currentDataServiceDescriptorChanged(_ desc: Any?) { // 当前数据卡刷新
        NSLog("[TrollSIMSwitcher] currentDataServiceDescriptorChanged")
        notifyUpdate()
    }

    func regDataModeChanged(_ client: Any?, dataMode: Int32) { // 更改蜂窝网络类型的回调
        NSLog("[TrollSIMSwitcher] regDataModeChanged")
        notifyUpdate()
    }

//    func preferredDataSimChanged(_ x: Any?) {
//        NSLog("[TrollSIMSwitcher] preferredDataSimChanged")
////        notifyUpdate()
//    }
    
}
