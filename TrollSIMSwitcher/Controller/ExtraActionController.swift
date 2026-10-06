import Foundation

class ExtraActionController {
    
    static let instance = ExtraActionController()
    
    private init() {}
    
    // 切换开关状态
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func performExtraActions(toggle: Bool) -> Bool {
        
        if let slotID = CellularController.instance.getDataPreferredSlotID() {
            if toggle {
               return performExtraActions(slotID: slotID == 2 ? 1 : 2)
            } else {
                return performExtraActions(slotID: Int(slotID))
            }
        } else {
            return false
        }
    }
    
    // 使用Slot ID来执行操作
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func performExtraActions(slotID: Int) -> Bool {
        return performExtraActions(iccid: CellularController.instance.getSlotCardICCID(slotID: slotID))
    }
    
    // 使用ICCID来执行操作
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
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
        case .ToggleWiFi: return WiFiController.instance.toggleWiFiPowerState()
        case .EnableWiFiAutoJoin: return WiFiController.instance.setWiFiAutoJoin(on: true)
        case .DisableWiFiAutoJoin: return WiFiController.instance.setWiFiAutoJoin(on: false)
        case .ToggleWiFiAutoJoin: return WiFiController.instance.toggleWiFiAutoJoin()
        }
    }
    
}
