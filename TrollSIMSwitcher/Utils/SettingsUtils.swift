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
        return plistManager.getBool(key: "ShowSlotLabel", defaultValue: true)
    }
    
    func setShowSlotLabel(enable: Bool) {
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
    
    /// 获取是否显示卡槽标签
    func getShowPhoneNumber() -> Bool {
        return plistManager.getBool(key: "ShowPhoneNumber", defaultValue: false)
    }
    
    func setShowPhoneNumber(enable: Bool) {
        plistManager.setBool(key: "ShowPhoneNumber", value: enable)
        plistManager.apply()
    }
    
    /// 获取启动App时自动切换
    func getExitAfterSwitching() -> Bool {
        return plistManager.getBool(key: "ExitAfterSwitching", defaultValue: false)
    }
    
    func setExitAfterSwitching(enable: Bool) {
        plistManager.setBool(key: "ExitAfterSwitching", value: enable)
        plistManager.apply()
    }
    
    /// 获取是否切换后退出应用程序
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
    
}
