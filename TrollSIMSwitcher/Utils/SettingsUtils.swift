import Foundation
import UIKit

class SettingsUtils {
    
    // 单例实例
    static let instance = SettingsUtils()
    
    // 私有的 PlistManagerUtils 实例，用于管理特定的 plist 文件
    private let plistManager: PlistManagerUtils
    
    private init() {
        // 初始化
        self.plistManager = PlistManagerUtils.instance(for: "Settings")
    }
    
    static let SwitchToSlot1ID = "com.developlab.TrollSIMSwitcher.SwitchToSlot1"
    static let SwitchToSlot2ID = "com.developlab.TrollSIMSwitcher.SwitchToSlot2"
    static let SwitchNetworkID = "com.developlab.TrollSIMSwitcher.SwitchTo"
    static let SwitchTo2GID = "com.developlab.TrollSIMSwitcher.SwitchTo2G"
    static let SwitchTo3GID = "com.developlab.TrollSIMSwitcher.SwitchTo3G"
    static let SwitchTo4GID = "com.developlab.TrollSIMSwitcher.SwitchTo4G"
    static let SwitchTo5GID = "com.developlab.TrollSIMSwitcher.SwitchTo5G"
    
    private func setDefaultSettings() {
        
        if self.plistManager.isPlistExist() {
            return
        }
        
    }
    
    // 检查UnSandbox权限的方法
    static func checkUnSandboxPermission() -> Bool {
        let path = "/var/mobile/Library/Preferences"
        let writeable = access(path, W_OK) == 0
        return writeable
    }
    
    /// 获取是否开启兼容性切换模式
    func getEnableCompatibilitySwitchMode() -> Bool {
        return plistManager.getBool(key: "CompatibilitySwitchMode", defaultValue: false)
    }
    
    func setEnableCompatibilitySwitchMode(enable: Bool) {
        plistManager.setBool(key: "CompatibilitySwitchMode", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否显示卡槽标签
    func getShowSlotLabel() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .pad { // 这里其实可以被插件绕过，不过其实也无所谓
            return false
        }
        return plistManager.getBool(key: "ShowSlotLabel", defaultValue: true)
    }
    
    func setShowSlotLabel(enable: Bool) {
        if UIDevice.current.userInterfaceIdiom == .pad { // 防止iPad用户修改配置文件绕过限制，但是其实可以被插件绕过，不过其实也无所谓
            return
        }
        plistManager.setBool(key: "ShowSlotLabel", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否显示运营商名称
    func getShowOperatorName() -> Bool {
        return plistManager.getBool(key: "ShowOperatorName", defaultValue: true)
    }
    
    func setShowOperatorName(enable: Bool) {
        plistManager.setBool(key: "ShowOperatorName", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否显示电话号码
    func getShowPhoneNumber() -> Bool {
        return plistManager.getBool(key: "ShowPhoneNumber", defaultValue: false)
    }
    
    func setShowPhoneNumber(enable: Bool) {
        plistManager.setBool(key: "ShowPhoneNumber", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否切换后退出应用程序
    func getExitAfterQuickSwitching() -> Bool {
        return plistManager.getBool(key: "ExitAfterQuickSwitching", defaultValue: false)
    }
    
    func setExitAfterQuickSwitching(enable: Bool) {
        plistManager.setBool(key: "ExitAfterQuickSwitching", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否开启图标快捷方式
    func getEnableHomeScreenQuickActions() -> Bool {
        return plistManager.getBool(key: "EnableHomeScreenQuickActions", defaultValue: false)
    }
    
    func setEnableHomeScreenQuickActions(enable: Bool) {
        plistManager.setBool(key: "EnableHomeScreenQuickActions", value: enable)
        plistManager.apply()
    }
    
    /// 获取启动App时自动切换
    func getAutomaticallySwitchWhenStartingApp() -> Bool {
        return plistManager.getBool(key: "AutomaticallySwitchWhenStartingApp", defaultValue: false)
    }
    
    func setAutomaticallySwitchWhenStartingApp(enable: Bool) {
        plistManager.setBool(key: "AutomaticallySwitchWhenStartingApp", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否开启通知
    func getEnableNotifications() -> Bool {
        return plistManager.getBool(key: "EnableNotifications", defaultValue: false)
    }
    
    func setEnableNotifications(enable: Bool) {
        plistManager.setBool(key: "EnableNotifications", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否开启切换蜂窝数据流量卡通知
    func getEnableToggleCellularDataSlotNotifications() -> Bool {
        return plistManager.getBool(key: "EnableToggleCellularDataSlotNotifications", defaultValue: false)
    }
    
    func setEnableToggleCellularDataSlotNotifications(enable: Bool) {
        plistManager.setBool(key: "EnableToggleCellularDataSlotNotifications", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否开启切换网络类型通知
    func getEnableToggleNetworkTypeNotifications() -> Bool {
        return plistManager.getBool(key: "EnableToggleNetworkTypeNotifications", defaultValue: true)
    }
    
    func setEnableToggleNetworkTypeNotifications(enable: Bool) {
        plistManager.setBool(key: "EnableToggleNetworkTypeNotifications", value: enable)
        plistManager.apply()
    }
    
    // 设置主屏幕快捷方式
    func setHomeScreenQuickActions(application: UIApplication) {
        if getEnableHomeScreenQuickActions() { // 检查是否开启桌面图标快捷方式
            var shortcutItems: [UIApplicationShortcutItem] = []
            // 获取全部卡槽信息
            var SIMSlotList = CoreTelephonyController.instance.getAllSIMSlots()
            if  SIMSlotList.isEmpty { // 没拿到数据，要么是不支持的设备要么就是没权限
//                setEnableHomeScreenQuickActions(enable: false)
                application.shortcutItems = []
                return
            }
            if SIMSlotList.count > 1 { // 筛选掉未启用的卡槽信息
                SIMSlotList = SIMSlotList.filter { $0.isEnabled }
            }
            
            if SIMSlotList.count > 1 { // 双卡模式下才增加切换卡槽的选项
                for slot in SIMSlotList {
                    let titleText: String
                    if getShowSlotLabel() {
                        titleText = String.localizedStringWithFormat(NSLocalizedString("SwitchTo", comment: ""), slot.label)
                    } else {
                        titleText = String.localizedStringWithFormat(NSLocalizedString("SwitchTo", comment: ""), String.localizedStringWithFormat(NSLocalizedString("SlotNumber", comment: ""), slot.slot))
                    }
                    shortcutItems.append(
                        UIApplicationShortcutItem(
                            type: slot.slot == 1 ? SettingsUtils.SwitchToSlot1ID : SettingsUtils.SwitchToSlot2ID,
                            localizedTitle: titleText,
                            localizedSubtitle: nil,
                            icon: UIApplicationShortcutIcon(systemImageName: slot.slot == 1 ? "simcard" : "simcard.2"),
                            userInfo: nil
                        )
                    )
                }
            }
            // 切换网络类型的判断
            
            // 获取当前流量卡
            let slot = SIMSlotList.first { $0.isDataPreferred }
            
            for rate in slot?.supportedRates?.rates as! [Int] {
                let networkText = CellularUtils.getRateText(rate: rate)
                // 添加可以切换的网络类型
                shortcutItems.append(
                    UIApplicationShortcutItem(
                        type: SettingsUtils.SwitchNetworkID.appending(networkText),
                        localizedTitle: String.localizedStringWithFormat(NSLocalizedString("SwitchTo", comment: ""), networkText),
                        localizedSubtitle: nil,
                        icon: UIApplicationShortcutIcon(systemImageName: "antenna.radiowaves.left.and.right"),
                        userInfo: nil
                    ))
            }
            // 向系统提交当前的快捷方式
            application.shortcutItems = shortcutItems
            
        } else { // 禁用桌面快捷方式
            application.shortcutItems = []
        }
    }
    
}
