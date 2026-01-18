import Foundation
import UIKit
import CoreTelephony

class CoreTelephonyController: NSObject, CoreTelephonyClientDelegate, CoreTelephonyClientDataDelegateInternal, CoreTelephonyClientRegistrationDelegateInternal, CTTelephonyNetworkInfoDelegate {
    
    // 单例实例
    static let instance = CoreTelephonyController()
    
    //CoreTelephonyClient 实例
    private let coreTelephonyClient = CoreTelephonyClient()
    private let networkInfo = CTTelephonyNetworkInfo()
    private let cellularPlanManager = CTCellularPlanManager.shared()
    
    private var IMEIs: [IMEI] = []
    private var plans: [CTCellularPlanItem] = []
    private var lastFetchPlansTimeStamp: Int = 0
    
    private override init() {
        
        super.init()
        IMEIs = MGDeviceInfoController.instance.IMEIs
        coreTelephonyClient?.setDelegate(self)
        networkInfo.delegate = self
        loadCellularPlans() // 获取一次蜂窝数据卡
    }

    // 根据slot获取当前插槽的上下文
    private func getServiceSubscriptionContext(slot: Int) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(slot: Int32(slot))
    }
    
    // 根据slot的uuid获取当前插槽的上下文
    private func getServiceSubscriptionContext(uuid: UUID) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(uuid: uuid)
    }
    
    // 获取当前首选卡槽的context
    func getDataPreferredContext() -> CTXPCServiceSubscriptionContext? {
        return coreTelephonyClient!.getPreferredDataSubscriptionContextSync(nil)
    }
    
    // 获取当前首选卡槽的ID
    func getDataPreferredSlotID() -> Int64 {
        return getDataPreferredContext()?.slotID ?? -1
    }
    
    // 获取当前首选卡槽的网络类型
    func getDataPreferredSlotRate() -> Int64 {
        return coreTelephonyClient!.getMaxDataRate(getDataPreferredContext(), error: nil)
    }
    
    // 获取当前首选卡槽支持的网络类型
    func getDataPreferredSlotSupportRates() -> [Int64] {
        if let supportedDataRates = coreTelephonyClient!.getSupportedDataRates(getDataPreferredContext(), error: nil) {
            return supportedDataRates.rates as! [Int64]
        }
        return []
    }
    
    // 加载全部数据流量卡
    private func loadCellularPlans() {
        
        // 缓存如果大于30s就去获取一次新的数据
        if (Int(Date().timeIntervalSince1970) - lastFetchPlansTimeStamp) > 30 {
            let sema = DispatchSemaphore(value: 0) // 创建一个信号量为 0 的锁

            cellularPlanManager?.planItems { items in
                self.plans = items ?? []
                sema.signal() // 继续线程
            }

//            sema.wait() // 挂起线程
            
            let result = sema.wait(timeout: .now() + 1.0)
            if result == .timedOut { // 处理超时的问题
                plans = []
            }
            
            lastFetchPlansTimeStamp = Int(Date().timeIntervalSince1970) // 把当前的时间戳写入，作为判断缓存的标志
        }
    }
    
    // 获取全部蜂窝数据卡
    func getCellularPlans() -> [CTCellularPlanItem] {
        loadCellularPlans()
        return plans
    }
    
    // 获取某个蜂窝数据卡
    func getCellularPlan(planID: String) -> CTCellularPlanItem? {
        loadCellularPlans()
        return plans.filter{ $0.identifier == planID }.first
    }
    
    // 设置蜂窝数据卡启用或者关闭
    func setCellularPlanEnable(planID: String, enable: Bool) -> Bool {
        let plan = getCellularPlan(planID: planID)
        if plan != nil {
            if !enable { // 前置检查
                if !canTurnOffCellularPlan() {
                    return false
                }
            }
            if plan?.isSelected == enable { // 同一个状态就不用切换了
                return true
            }
            cellularPlanManager?.didSelectPlanItem(plan, isEnable: enable)
            // 设置缓存失效，这样就可以立刻刷新数据卡数据
            lastFetchPlansTimeStamp = 0
            return true
        }
        return false
    }
    
    func toggleCellularPlanEnable(planID: String) -> Bool {
        let plan = getCellularPlan(planID: planID)
        if plan != nil {
            if (plan?.isSelected ?? false) { // 前置检查
                if !canTurnOffCellularPlan() {
                    return false
                }
            }
            cellularPlanManager?.didSelectPlanItem(plan, isEnable: !(plan?.isSelected ?? false))
            // 设置缓存失效，这样就可以立刻刷新数据卡数据
            lastFetchPlansTimeStamp = 0
            return true
        }
        return false
    }
    
    // 判断是否有已经启用的蜂窝数据套餐
    func hasAnyEnabledCellularPlan() -> Bool {
        return getCellularPlans().contains(where: { $0.isSelected })
    }
    
    /// 判断用户是否有权利管理蜂窝数据卡
    /// ⚠️ System limitation:
    /// Disabling the last active cellular plan via CTCellularPlanManager
    /// will cause CommCenter to enter an invalid state and crash the app.
    /// This operation is intentionally blocked in-app.
    /// Users may still disable all plans manually in Settings.
    func canManageCellularPlans() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad { // 1. iPad蜂窝版无法使用
            return false
        }
        if IMEIs.count < 2 { // 2. 没权限和单卡手机无法使用
            return false
        }
        if plans.count < 2 { // 3. 双卡手机但是就一张卡的用户无法使用
            return false
        }
        return true
    }
    
    // 判断是否可以关闭蜂窝数据套餐
    func canTurnOffCellularPlan() -> Bool {
        // 没有启用任何一张卡或者当前就启用了一张卡 那不能把最后一张卡关闭，否则app将无限闪退，直到用户从设置中随意打开一张卡为止
        if getCellularPlans().count == 1 || getCellularPlans().filter({ $0.isSelected }).count <= 1 {
            return false
        }
        return true
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
                if let rates = supportedDataRates?.rates as? [Int64] {
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
    
    // 获取全部已经启用的卡槽信息
    func getAllEnabledSlots() -> [SIMSlot] {
        var SIMSlotList = getAllSIMSlots()
        if SIMSlotList.count > 1 { // 解决下iPad没启用蜂窝数据的时候什么都不显示的情况
            // 筛选掉未启用的卡槽信息
            SIMSlotList = SIMSlotList.filter { $0.isEnabled }
        }
        return SIMSlotList
    }
    
    // 判断是否有已经启用的卡槽
    private func hasAnyEnabledSIMSlot() -> Bool {
        return getAllSIMSlots().contains(where: { $0.isEnabled })
    }
    
    // 切换卡槽流量
    func setDataSlot(SIMSlot: SIMSlot) -> Bool {
        return setDataSlot(slot: SIMSlot.slot)
    }
    
    // 切换卡槽流量
    func setDataSlot(slot: Int) -> Bool {
        if slot >= IMEIs.count + 1 { // 切换不能超过IMEI的最大容量，否则肯定失败
            return false
        }
        let controlSlot: Int
        // 获取是否开启兼容性模式
        if SettingsUtils.instance.getEnableCompatibilitySwitchMode() {
            controlSlot = slot == 1 ? 2 : 1
        } else {
            controlSlot = slot
        }
        // 获取需要切换卡槽的context
        if let context = getServiceSubscriptionContext(slot: controlSlot) {
            // 切换数据卡
            coreTelephonyClient!.setActiveUserDataSelection(context, error: nil)
            return true
        }
        return false
    }
    
    // 将流量卡切换到另一个卡槽
    func toggleDataSlot() -> Bool {
        // 如果只有一个启用的卡，那不需要切换
        if getAllSIMSlots().filter({ $0.isEnabled }).count < 2 {
            return false
        }
        // 获取当前的卡槽，设定到另一个卡槽
        let controlSlot = getDataPreferredSlotID() == 1 ? 2 : 1
        return setDataSlot(slot: controlSlot)
    }
    
    // 切换网络类型
    func setDataRate(SIMSlot: SIMSlot, selectRate: Int64) -> Bool {
        return setDataRate(slot: SIMSlot.slot, selectRate: selectRate)
    }
    
    // 切换指定卡槽的网络类型
    func setDataRate(slot: Int, selectRate: Int64) -> Bool {
        if let context = getServiceSubscriptionContext(slot: slot) {
            if let result = coreTelephonyClient!.setMaxDataRate(context, rate: selectRate) { // 这个私有方法只有错误的时候才会返回结果
                NSLog("[TrollSIMSwitcher] Switching the network type returns:\(result)")
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    // 切换当前数据流量的卡槽的网络类型
    func setDataPreferredRate(selectRate: Int64) -> Bool {
        if let context = getDataPreferredContext() {
            if let result = coreTelephonyClient!.setMaxDataRate(context, rate: selectRate) {
                NSLog("[TrollSIMSwitcher] Switching the network type returns:\(result)")
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    func setDataPreferredRate(selectRate: DataRates) -> Bool {
        return setDataPreferredRate(selectRate: selectRate.rawValue)
    }
    
    // 切换当前选择的卡的数据类型 例如4G 5G之间切换
    func toggleDataPreferredRate() -> Bool {
        var supportRates = getDataPreferredSlotSupportRates()
        
        if supportRates.count < 1 { // 没有获取到网络支持列表，直接返回失败
            return false
        }
        
        if supportRates.count == 1 { // 只支持一种网络类型，直接不需要切换，返回成功
            return true
        }
        
        // 排序一下最高的支持网络类型
        supportRates = supportRates.sorted()
        // 设置网络类型，如果是最高支持就切换到第二支持，如果第二支持就切换到最高支持
        return setDataPreferredRate(selectRate: getDataPreferredSlotRate() == supportRates.last! ? supportRates[supportRates.count - 2] : supportRates.last!)
    }
    
    // 回调 通知当前状态更改
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
