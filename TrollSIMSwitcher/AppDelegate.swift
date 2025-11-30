import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        if #unavailable(iOS 14.0) { // 不支持iOS 14.0以下版本 直接退出程序
            exit(0)
        }
        
        // 设置通知代理
        UNUserNotificationCenter.current().delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = UINavigationController(rootViewController: MainViewController())
        window!.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - App 激活后处理启动快捷方式
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name("CoreTelephonyUpdated"), object: nil)
    }
}

