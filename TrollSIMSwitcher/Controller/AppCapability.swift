import Foundation
import UIKit

class AppCapability {
    
    /// 检查当前的安装环境是否有SPI权利
    static func hasCommCenterSPI() -> Bool {
        return EntitlementUtils.exists(["com.apple.CommCenter.fine-grained" , "spi"])
    }
    
    // 检查UnSandbox权限的方法
    static func checkUnSandboxPermission() -> Bool {
        let path = "/var/mobile/Library/Preferences"
        let writeable = access(path, W_OK) == 0
        return writeable
    }
}
