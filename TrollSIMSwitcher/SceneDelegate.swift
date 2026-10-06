import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        
        window = UIWindow(windowScene: windowScene)
        window!.rootViewController = UINavigationController(rootViewController: MainViewController())
        window!.makeKeyAndVisible()
        
        // 检查是否通过快捷方式启动
        if let shortcutItem = connectionOptions.shortcutItem {
            (UIApplication.shared.delegate as? AppDelegate)?.pendingQuickAction = shortcutItem
        }
        
        // 检查是否通过Widget启动
        if let userActivity = connectionOptions.userActivities.first {
            (UIApplication.shared.delegate as? AppDelegate)?.handleQuickAction(itemID: userActivity.activityType)
        }
        
    }
    
    // MARK: - App 激活后处理启动快捷方式
    func sceneDidBecomeActive(_ scene: UIScene) {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let item = appDelegate.pendingQuickAction {
            appDelegate.handleQuickAction(itemID: item.type)
            appDelegate.pendingQuickAction = nil
        }
        
        NotificationCenter.default.post(name: Notification.Name("CoreTelephonyUpdated"), object: nil)
    }
    
    // MARK: - 前台/后台时的桌面快捷方式处理
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        (UIApplication.shared.delegate as? AppDelegate)?.handleQuickAction(itemID: shortcutItem.type, windowScene: windowScene)
        completionHandler(true)
    }
    
    // MARK: - 处理点击锁屏Widget的方法
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        
        (UIApplication.shared.delegate as? AppDelegate)?.handleQuickAction(itemID: userActivity.activityType)
    }
    
}
