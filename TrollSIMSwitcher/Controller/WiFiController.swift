import Foundation
import CoreFoundation

class WiFiController {

    static let instance = WiFiController()

    private var manager: WiFiManagerRef?
    private var device: WiFiDeviceClientRef?

    private init() {
        refreshHandles()
    }

    private func refreshHandles() {
        manager = WiFiManagerClientCreate(kCFAllocatorDefault, 0)

        guard let manager = manager, let array = WiFiManagerClientCopyDevices(manager)?.takeRetainedValue(), CFArrayGetCount(array) > 0 else {
            device = nil
            return
        }

        device = unsafeBitCast(CFArrayGetValueAtIndex(array, 0), to: WiFiDeviceClientRef.self)
    }

    private func ensureDevice() -> WiFiDeviceClientRef? {
        if device == nil {
            refreshHandles()
        }
        return device
    }
    
    // 判断是否有Wi-Fi权利，证书签名肯定不行
    func getWiFiManagerPermission() -> Bool {
        return device != nil
    }

    // 获取Wi-Fi开关状态
    func getWiFiPowerState() -> Bool {
        refreshHandles() // 强制刷新 保证获取的是最新的Wi-Fi开关状态
        guard let device = ensureDevice() else {
            return false
        }
        return WiFiDeviceClientGetPower(device) != 0
    }

    // 设置Wi-Fi开关状态
    func setWiFiPowerState(on: Bool) -> Bool {
        
        // 每次都刷新，保证 device 是最新的 解决app在后台很久没操作，但是手动开启/关闭Wi-Fi后app无法切换Wi-Fi的bug
        refreshHandles()
        
        guard let device = ensureDevice() else { // 如果没有获取到Wi-Fi的控制器就不去操作
            return false
        }
        
        if getWiFiPowerState() == on { // 如果当前Wi-Fi状态和设定状态相同的话，取消切换
            return true
        }

        let target: Int32 = on ? 1 : 0 // 设置参数
        WiFiDeviceClientSetPower(device, target) // 设置Wi-Fi状态

        DispatchQueue.global().async { // 尝试两次 因为一次打开/关闭不了Wi-Fi
            for _ in 0..<2 {
                usleep(150_000) // 延迟再执行一次
                if self.getWiFiPowerState() == (target != 0) {
                    return
                }
                WiFiDeviceClientSetPower(device, target)
            }
        }
        return true
    }
    
    // 切换Wi-Fi开关状态
    func toggleWiFiPowerState() -> Bool {
        return setWiFiPowerState(on: !getWiFiPowerState())
    }
    
    // 获取WiFi Auto-Join 状态
    // 获取是否允许暂时关闭WiFi的连接，但是WiFi本身不关掉，不影响AirDrop和Handoff
    func getWiFiAutoJoinState() -> Bool {
        refreshHandles()

        guard let manager = manager else {
            return false
        }

        return WiFiManagerClientGetUserAutoJoinState(manager) != 0
    }

    // 启用WiFi Auto-Join
    // 是否允许暂时关闭WiFi的连接，但是WiFi本身不关掉，不影响AirDrop和Handoff
    func enableWiFiAutoJoin() -> Bool {
        refreshHandles()

        guard let manager = manager else {
            return false
        }

        WiFiManagerClientEnableUserAutoJoin(manager)

        return getWiFiAutoJoinState()
    }

    // 禁用WiFi Auto-Join
    func disableWiFiAutoJoin() -> Bool {
        refreshHandles()

        guard let manager = manager else {
            return false
        }

        WiFiManagerClientDisableUserAutoJoin(manager)

        return !getWiFiAutoJoinState()
    }

    // 设置WiFi Auto-Join
    // 是否允许暂时关闭WiFi的连接，但是WiFi本身不关掉，不影响AirDrop和Handoff
    func setWiFiAutoJoin(on: Bool) -> Bool {
        return on ? enableWiFiAutoJoin() : disableWiFiAutoJoin()
    }
    
    // 切换Wi-Fi连接状态
    func toggleWiFiAutoJoin() -> Bool {
        return setWiFiAutoJoin(on: !getWiFiAutoJoinState())
    }
    
    
}
