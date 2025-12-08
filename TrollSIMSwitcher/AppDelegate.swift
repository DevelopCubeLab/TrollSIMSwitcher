import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    // 用于存储启动时的快捷方式
    var pendingQuickAction: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        if #unavailable(iOS 14.0) { // 不支持iOS 14.0以下版本 直接退出程序
            exit(0)
        }
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = UINavigationController(rootViewController: MainViewController())
        window!.makeKeyAndVisible()
        
        // 检查是否通过快捷方式启动
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            pendingQuickAction = shortcutItem // 保存快捷方式
        }
        
        return true
    }
    
    // MARK: - App 激活后处理启动快捷方式
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if let item = pendingQuickAction {
            handleQuickAction(itemID: item.type)
            pendingQuickAction = nil
        }
        
        NotificationCenter.default.post(name: Notification.Name("CoreTelephonyUpdated"), object: nil)
    }
    
    // MARK: - 前台时的桌面快捷方式处理
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        handleQuickAction(itemID: shortcutItem.type)
        completionHandler(true)
    }
    
    // MARK: - 处理点击锁屏Widget的方法
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        handleQuickAction(itemID: userActivity.activityType)
        
        return true
    }
    
    // MARK: - 处理快捷操作
    private func handleQuickAction(itemID: String) {
        
        if let viewController = window?.rootViewController { //获取当前的View Controller
            switch itemID {
            case "TrollSIMSwitcherSlot1", SettingsUtils.SwitchToSlot1ID: // 切换到卡槽1
                if CoreTelephonyController.instance.setDataSlot(slot: 1) {
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case "TrollSIMSwitcherSlot2", SettingsUtils.SwitchToSlot2ID: // 切换到卡槽2
                if CoreTelephonyController.instance.setDataSlot(slot: 2) {
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case "TrollSIMSwitcherToggleSlot": // 切换到另一个卡槽
                if CoreTelephonyController.instance.toggleDataSlot() {
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case "TrollSIMSwitcherToggleNetworkType": // 自动切换4G/5G
                if CoreTelephonyController.instance.toggleDataPreferredRate() {
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case "TrollSIMSwitcher4G", SettingsUtils.SwitchTo4GID:    // 切换到4G
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._4G){
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case "TrollSIMSwitcher5G", SettingsUtils.SwitchTo5GID:    // 切换到5G
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._5G){
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case SettingsUtils.SwitchTo2GID: // 切换到2G
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._2G){
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            case SettingsUtils.SwitchTo3GID: // 切换到3G
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._3G){
                    UIUtils.exitApplicationAfterSwitching()
                } else {
                    UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
                }
            default: return
            }
        }
        
    }
    
}

