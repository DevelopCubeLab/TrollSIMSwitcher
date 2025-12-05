import Foundation
import UIKit

class UIUtils {
    
    // 通用弹窗提示
    static func showAlert(message: String, in viewController: UIViewController) {
        let alert = UIAlertController(
            title: NSLocalizedString("Alert", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        let closeAction = UIAlertAction(
            title: NSLocalizedString("Close", comment: ""),
            style: .cancel,
            handler: nil
        )
        alert.addAction(closeAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // 操作后返回主界面
    static func exitApplicationAfterSwitching() {
        // 处理退出
        if SettingsUtils.instance.getExitAfterQuickSwitching() {
            UIApplication.shared.perform(#selector(NSXPCConnection.suspend)) // 返回桌面
        }
    }
}
