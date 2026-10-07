import Foundation

class CellularController {
    
    static let instance = CellularController()
    
    private let coreTelephonyController = CoreTelephonyController.instance
    private let cellularPlanManager = CTCellularPlanController.instance
    private let radioPreferencesController = RadioPreferencesController.instance
    
    private init() {}
    
    // 获取全部卡槽信息
    func getAllSIMSlots() -> [SIMSlot] {
        var slots: [SIMSlot] = []
        
        let slotCount = coreTelephonyController.getDeviceSlotCount() // 获取卡槽数量
        
        if slotCount == 0 { // 拒绝Wi-Fi版iPad或者证书签名情况
            return []
        }
        
        let dataPreferredSlotID = getDataPreferredSlotID()

        for slot in 1...slotCount {
            //获取当前卡槽信息
            if let context = coreTelephonyController.getServiceSubscriptionContext(slot: slot) {
                do {
                    // 获取当前卡槽位
                    let slotID = Int(context.slotID)
                    // 获取当前卡槽的UUID
                    let uuid = context.uuid ?? UUID()
                    // 获取当前卡槽的ICCID
                    let iccid = try coreTelephonyController.getSlotICCID(context: context) ?? ""
                    // 获取当前卡标签
                    let label = try coreTelephonyController.getSlotLabelText(context: context)
                    // 获取当前运营商的名称
                    let operatorName = try coreTelephonyController.getSlotLocalizedOperatorName(context: context)
                    // 获取当前卡的电话号码
                    let phoneNumber = try coreTelephonyController.getSlotPhoneNumber(context: context)
                    // 获取当前SIM卡状态
                    let isEnabled = try coreTelephonyController.getSlotSIMStatus(context: context) == "kCTSIMSupportSIMStatusReady"
                    // 获取当前注册状态
                    let registrationStatus = CoreTelephonyEnumMapper.mapRegistrationStatus(try coreTelephonyController.getSlotRegistrationStatus(context: context))
                    // 判断是否是当前的卡槽是首选流量卡
                    let isDataPreferred = dataPreferredSlotID == slotID
                    // 获取当前卡支持的网络类型
                    let supportedDataRates = coreTelephonyController.getSlotSupportRates(context: context).map { Int($0) }
                    // 获取当前卡设置的网络类型
                    let currentRate: Int = Int(try coreTelephonyController.getSlotSelectRate(context: context))
                    
                    // 将数据放入列表
                    slots.append(SIMSlot(slot: slotID, uuid: uuid, ICCID: iccid, label: label, operatorName: operatorName, phoneNumber: phoneNumber, registrationStatus: registrationStatus, isEnabled: isEnabled, isDataPreferred: isDataPreferred, supportedRates: supportedDataRates, currentRate: currentRate))
                    
                } catch let error as NSError {
                    NSLog("[TrollSIMSwitcher] getAllSIMSlots error slot: \(slot) message: \(error.code)  \(error.localizedDescription)")
                }
                
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
    
    // 获取设备是否开启了飞行模式
    func getDeviceAirplaneModeEnabled() -> Bool {
        return radioPreferencesController.getAirplaneMode()
    }
    
    // 获取当前首选卡槽的ID
    func getDataPreferredSlotID() -> Int? {
        do {
            return Int(try coreTelephonyController.getDataPreferredSlotID())
        } catch {
            return nil
        }
    }
    
    // 获取卡槽中卡的ICCID
    func getSlotCardICCID(slotID: Int) -> String {
        return coreTelephonyController.getSlotICCID(slotID: slotID) ?? ""
    }
    
    // 获取当前首选卡槽的网络类型
    func getDataPreferredSlotRate() -> Int? {
        do {
            return Int(try coreTelephonyController.getDataPreferredSlotRate())
        } catch {
            return nil
        }
    }
    
    // 切换卡槽流量
    func setDataSlot(SIMSlot: SIMSlot) -> Bool {
        return setDataSlot(slot: SIMSlot.slot)
    }
    
    // 切换卡槽流量
    func setDataSlot(slot: Int) -> Bool {
        // 判断卡槽ID是否符合要求
        guard slot == 1 || slot == 2 else {
            return false
        }
        let controlSlot: Int
        // 获取是否开启兼容性模式
        if SettingsUtils.instance.getEnableCompatibilitySwitchMode() {
            controlSlot = slot == 1 ? 2 : 1
        } else {
            controlSlot = slot
        }
        return coreTelephonyController.setDataSlot(slotID: controlSlot)
    }
    
    // 将流量卡切换到另一个卡槽
    func toggleDataSlot() -> Bool {
        // 如果只有一个启用的卡，那不需要切换
        if getAllEnabledSlots().count < 2 {
            return false
        }
        do {
            // 获取当前的卡槽，设定到另一个卡槽
            let targetSlot = try coreTelephonyController.getDataPreferredSlotID() == 1 ? 2 : 1
            return setDataSlot(slot: targetSlot)
        } catch {
            return false
        }
    }
    
    // 设置蜂窝数据卡的网络类型
    func setDataRate(SIMSlot: SIMSlot, selectRate: Int) -> Bool {
        return coreTelephonyController.setDataRate(slot: SIMSlot.slot, selectRate: Int64(selectRate))
    }
    
    // 设置首选蜂窝数据卡的网络类型
    func setDataPreferredRate(selectRate: DataRates) -> Bool {
        return coreTelephonyController.setDataPreferredRate(selectRate: Int64(selectRate.rawValue))
    }
    
    // 切换当前选择的卡的数据类型 例如4G 5G之间切换
    func toggleDataPreferredRate() -> Bool {
        do {
            var supportRates = try coreTelephonyController.getDataPreferredSlotSupportRates()
            
            if supportRates.count < 1 { // 没有获取到网络支持列表，直接返回失败
                return false
            }
            
            if supportRates.count == 1 { // 只支持一种网络类型，直接不需要切换，返回成功
                return true
            }
            
            // 排序一下最高的支持网络类型
            supportRates = supportRates.sorted()
            // 获取当前设置的网络类型
            let currentRate = try coreTelephonyController.getDataPreferredSlotRate()
            
            let targetRate: Int64
            // 设置网络类型，如果是最高支持就切换到第二支持，如果第二支持就切换到最高支持
            if currentRate == supportRates.last! {
                targetRate = supportRates[supportRates.count - 2]
            } else {
                targetRate = supportRates.last!
            }

            return coreTelephonyController.setDataPreferredRate(selectRate: targetRate)
            
        } catch {
            return false
        }
    }
    
    // 获取全部蜂窝数据卡
    func getCellularPlans() -> [CTCellularPlanItem] {
        return cellularPlanManager.getCellularPlans()
    }
    
    // 获取蜂窝数据套餐
    func getCellularPlan(planID: String) -> CTCellularPlanItem? {
        return cellularPlanManager.getCellularPlan(planID: planID)
    }
    
    func setCellularPlanEnable(planID: String, enable: Bool) -> Bool {
        return cellularPlanManager.setCellularPlanEnable(planID: planID, enable: enable)
    }
    
    func toggleCellularPlanEnable(planID: String) -> Bool {
        return cellularPlanManager.toggleCellularPlanEnable(planID: planID)
    }
    
    // 刷新蜂窝网络连接
    func refreshCellularConnection() -> Bool {
        if AppCapability.hasCommCenterSPI() {
            coreTelephonyController.refreshCellularConnection()
            return true
        } else {
            return false
        }
    }
    
}
