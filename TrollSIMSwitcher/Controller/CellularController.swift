import Foundation

class CellularController {
    
    static let instance = CellularController()
    
    private let coreTelephonyController = CoreTelephonyController.instance
    private let cellularPlanManager = CTCellularPlanController.instance
    
    private init() {}
    
    // 获取全部卡槽信息
    func getAllSIMSlots() -> [SIMSlot] {
        return coreTelephonyController.getAllSIMSlots()
    }
    
    // 获取全部已经启用的卡槽信息
    func getAllEnabledSlots() -> [SIMSlot] {
        return coreTelephonyController.getAllEnabledSlots()
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
        return coreTelephonyController.getSlotCardICCID(slotID: slotID) ?? ""
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
        if coreTelephonyController.getAllEnabledSlots().count < 2 {
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
    func setDataRate(SIMSlot: SIMSlot, selectRate: Int64) -> Bool {
        return coreTelephonyController.setDataRate(SIMSlot: SIMSlot, selectRate: selectRate)
    }
    
    // 设置首选蜂窝数据卡的网络类型
    func setDataPreferredRate(selectRate: DataRates) -> Bool {
        return coreTelephonyController.setDataPreferredRate(selectRate: selectRate.rawValue)
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
            
//            return coreTelephonyController.setDataPreferredRate(selectRate: try coreTelephonyController.getDataPreferredSlotRate() == supportRates.last! ? supportRates[supportRates.count - 2] : supportRates.last!)
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
