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
        // 注册通知分类
        NotificationController.instance.setupNotificationCategories()
        
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
            var switchSlot: Bool = false
            var switchSuccessful: Bool = true
            
            switch itemID {
            case "TrollSIMSwitcherSlot1", SettingsUtils.SwitchToSlot1ID: // 切换到卡槽1
                if CoreTelephonyController.instance.setDataSlot(slot: 1) {
                    switchSlot = true
                    switchSuccessful = true
                } else {
                    switchSuccessful = false
                }
            case "TrollSIMSwitcherSlot2", SettingsUtils.SwitchToSlot2ID: // 切换到卡槽2
                if CoreTelephonyController.instance.setDataSlot(slot: 2) {
                    switchSlot = true
                    switchSuccessful = true
                } else {
                    switchSuccessful = false
                }
            case "TrollSIMSwitcherToggleSlot": // 切换到另一个卡槽
                if CoreTelephonyController.instance.toggleDataSlot() {
                    switchSlot = true
                    switchSuccessful = true
                } else {
                    switchSuccessful = false
                }
            case "TrollSIMSwitcherToggleNetworkType": // 自动切换4G/5G
                switchSuccessful = CoreTelephonyController.instance.toggleDataPreferredRate()
            case "TrollSIMSwitcher4G", SettingsUtils.SwitchTo4GID:    // 切换到4G
                switchSuccessful = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._4G)
            case "TrollSIMSwitcher5G", SettingsUtils.SwitchTo5GID:    // 切换到5G
                switchSuccessful = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._5G)
            case SettingsUtils.SwitchTo2GID: // 切换到2G
                switchSuccessful = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._2G)
            case SettingsUtils.SwitchTo3GID: // 切换到3G
                switchSuccessful = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._3G)
            case "TrollSIMSwitcherTurnOnCellularPlan": // 打开蜂窝数据卡
                switchSuccessful = CoreTelephonyController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: true)
            case "TrollSIMSwitcherTurnOffCellularPlan": // 关闭蜂窝数据卡
                switchSuccessful = CoreTelephonyController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: false)
            case "TrollSIMSwitcherToggleCellularPlan": // 切换蜂窝数据卡状态
                switchSuccessful = CoreTelephonyController.instance.toggleCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1())
            default: return
            }
            
            if switchSlot { // 补发通知
                NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: NotificationController.switchSlotGroupIdentifier)
            } else {
                // 补发普通通知
                NotificationController.instance.sendNotifications(silentNotifications: true)
            }
            if switchSuccessful {
                UIUtils.exitApplicationAfterSwitching()
            } else {
                UIUtils.showAlert(message: NSLocalizedString("SwitchFailed", comment: ""), in: viewController)
            }
        }
        
    }
    
    // MARK: 前台也显示通知（横幅/列表），没有声音就不会响
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(NotificationController.instance.presentationOptions(for: notification))
    }

    // MARK: 点击通知的回调
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let request = response.notification.request
        let userInfo = request.content.userInfo

        let systemActionID = response.actionIdentifier
        let groupID = userInfo["group"] as? String
        let actionID = userInfo["action"] as? String

        switch systemActionID {
        
        case UNNotificationDefaultActionIdentifier: // 用户点击通知本体

            switch actionID {
            case NotificationController.switchToSlot1Identifier:
                if CoreTelephonyController.instance.setDataSlot(slot: 1) {
                    // 判断是否退出app
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.switchToSlot2Identifier:
                if CoreTelephonyController.instance.setDataSlot(slot: 2) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.switch3GIdentifier:
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: DataRates._3G) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.switch4GIdentifier:
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: DataRates._4G) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.switch5GIdentifier:
                if CoreTelephonyController.instance.setDataPreferredRate(selectRate: DataRates._5G) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.turnOnCellularPlanIdentifier:
                if CoreTelephonyController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: true) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            case NotificationController.turnOffCellularPlanIdentifier:
                if CoreTelephonyController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: false) {
                    UIUtils.exitApplicationAfterSwitching()
                }
            default: break
            }
            // 补发通知
            NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: groupID)
            
        case NotificationController.disableThisGroupNotificationsActionID: // 禁用当前的分组通知
            if let groupID {
                if groupID == NotificationController.switchSlotGroupIdentifier { // 关闭切换蜂窝网络的通知
                    SettingsUtils.instance.setEnableToggleCellularDataSlotNotifications(enable: false)
                } else if groupID == NotificationController.switchNetworkTypeGroupIdentifier { // 关闭切换蜂窝类型的通知
                    SettingsUtils.instance.setEnableToggleNetworkTypeNotifications(enable: false)
                } else if groupID == NotificationController.switchCellularPlanGroupIdentifier { // 关闭切换蜂窝数据卡的通知
                    SettingsUtils.instance.setEnableToggleCellularPlanNotifications(enable: false)
                }
            }

        case NotificationController.disableAllNotificationsActionID: // 禁用全部通知
            // 关闭通知
            SettingsUtils.instance.setEnableNotifications(enable: false)
            // 删除全部通知
            NotificationController.instance.clearAllNotifications()

        case UNNotificationDismissActionIdentifier: // 用户划掉通知
            break

        default:
            break
        }
        
        completionHandler()
    }
    
}

