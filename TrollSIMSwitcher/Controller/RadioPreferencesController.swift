import Foundation

class RadioPreferencesController {
    
    /// 单例实例
    static let instance = RadioPreferencesController()
    
    /// 私有构造方法
    private init() {
        //
    }
    
    /// 获取飞行模式状态
    /// 无需额外权利
    func getAirplaneMode() -> Bool {
        return RadiosPreferences().airplaneMode
    }
    
    /// 设置飞行状态模式
    /// 需要额外权利
    /*
     <key>com.apple.SystemConfiguration.SCPreferences-write-access</key>
     <array>
         <string>com.apple.radios.plist</string>
     </array>
     */
    func setAirplaneMode(mode: Bool) {
        RadiosPreferences().airplaneMode = mode
    }
    
}
