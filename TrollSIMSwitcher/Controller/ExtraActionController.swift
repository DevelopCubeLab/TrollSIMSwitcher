import Foundation

class ExtraActionController {
    
    static let instance = ExtraActionController()
    
    private init() {}
    
    func performExtraActions(toggle: Bool) -> Bool {
        
        do {
            let slotID = try CoreTelephonyController.instance.getDataPreferredSlotID()
            if toggle {
               return performExtraActions(slotID: slotID == 2 ? 1 : 2)
            } else {
                return performExtraActions(slotID: Int(slotID))
            }
        } catch {
            return false
        }
    }
    
    // 使用Slot ID来执行操作
    func performExtraActions(slotID: Int) -> Bool {
        return performExtraActions(iccid: CoreTelephonyController.instance.getSlotCardICCID(slotID: slotID))
    }
    
    // 使用ICCID来执行操作
    func performExtraActions(iccid: String) -> Bool {
        // 从设置中获取当前的状态
        let actions = SettingsUtils.instance.getSwitchSlotExtraActions(iccid: iccid)
        var result = true
        for action in actions {
            if !performExtraActions(action: action) {
                result = false
            }
        }
        return result
    }
    
    // 执行操作 主要给快捷指令用户单独选的情况
    func performExtraActions(action: ExtraAction) -> Bool {
        switch action {
        case .None: return true
        case .TurnOnWiFi: return WiFiController.instance.setWiFiPowerState(on: true)
        case .TurnOffWiFi: return WiFiController.instance.setWiFiPowerState(on: false)
        case .EnableWiFiConnect: return WiFiController.instance.setUserAutoJoin(on: true)
        case .DisableWiFiConnect: return WiFiController.instance.setUserAutoJoin(on: false)
        }
    }
    
}
