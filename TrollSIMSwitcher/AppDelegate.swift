import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
        
        return true
    }
    
    // MARK: - 创建和加载默认的Scene
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        
        return configuration
    }
    
    // MARK: - 处理快捷操作
    func handleQuickAction(itemID: String, windowScene: UIWindowScene? = nil) {
        
        // 获取当前的 View Controller
        let viewController = (windowScene ?? UIApplication.shared.connectedScenes.first {
            $0.activationState == .foregroundActive
        } as? UIWindowScene)?.windows.first(where: {
            $0.isKeyWindow
        })?.rootViewController
        
        var switchSlot: Bool = false
        var switchSuccessful: Bool = true
        
        switch itemID {
        case "TrollSIMSwitcherSlot1", SettingsUtils.SwitchToSlot1ID: // 切换到卡槽1
            if CellularController.instance.setDataSlot(slot: 1) {
                switchSlot = true
                // 执行点击后的操作
                switchSuccessful = ExtraActionController.instance.performExtraActions(slotID: 1)
            } else {
                switchSuccessful = false
            }
        case "TrollSIMSwitcherSlot2", SettingsUtils.SwitchToSlot2ID: // 切换到卡槽2
            if CellularController.instance.setDataSlot(slot: 2) {
                switchSlot = true
                // 执行点击后的操作
                switchSuccessful = ExtraActionController.instance.performExtraActions(slotID: 2)
            } else {
                switchSuccessful = false
            }
        case "TrollSIMSwitcherToggleSlot": // 切换到另一个卡槽
            if CellularController.instance.toggleDataSlot() {
                switchSlot = true
                // 执行点击后的操作
                switchSuccessful = ExtraActionController.instance.performExtraActions(toggle: true)
            } else {
                switchSuccessful = false
            }
        case "TrollSIMSwitcherToggleNetworkType": // 自动切换4G/5G
            switchSuccessful = CellularController.instance.toggleDataPreferredRate()
        case "TrollSIMSwitcher4G", SettingsUtils.SwitchTo4GID:    // 切换到4G
            switchSuccessful = CellularController.instance.setDataPreferredRate(selectRate: ._4G)
        case "TrollSIMSwitcher5G", SettingsUtils.SwitchTo5GID:    // 切换到5G
            switchSuccessful = CellularController.instance.setDataPreferredRate(selectRate: ._5G)
        case SettingsUtils.SwitchTo2GID: // 切换到2G
            switchSuccessful = CellularController.instance.setDataPreferredRate(selectRate: ._2G)
        case SettingsUtils.SwitchTo3GID: // 切换到3G
            switchSuccessful = CellularController.instance.setDataPreferredRate(selectRate: ._3G)
        case "TrollSIMSwitcherTurnOnCellularPlan": // 打开蜂窝数据卡
            switchSuccessful = CellularController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: true)
        case "TrollSIMSwitcherTurnOffCellularPlan": // 关闭蜂窝数据卡
            switchSuccessful = CellularController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: false)
        case "TrollSIMSwitcherToggleCellularPlan": // 切换蜂窝数据卡状态
            switchSuccessful = CellularController.instance.toggleCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1())
        case "TrollSIMSwitcherRebootCommCenter": // 重启基带服务
            let deviceController = DeviceController()
            switchSuccessful = deviceController.rebootCommCenter()
        case "TrollSIMSwitcherRefreshCellularConnection": // 刷新蜂窝网络信号
            switchSuccessful = CellularController.instance.refreshCellularConnection()
        default: return
        }
        
        if switchSlot { // 补发通知
            NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: NotificationController.switchSlotGroupIdentifier)
        } else {
            // 补发普通通知
            NotificationController.instance.sendNotifications(silentNotifications: true)
        }
        
        if switchSuccessful {
            UIUtils.exitApplicationAfterAction()
        } else if let viewController {
            UIUtils.showAlert(message: NSLocalizedString("ActionFailed", comment: ""), in: viewController)
        }
    }
    
    // MARK: 前台也显示通知（横幅/列表），没有声音就不会响
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(NotificationController.instance.presentationOptions(for: notification))
    }

    // MARK: 点击通知的回调
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let request = response.notification.request
        let userInfo = request.content.userInfo

        let systemActionID = response.actionIdentifier
        let groupID = userInfo["group"] as? String
        let actionID = userInfo["action"] as? String

        switch systemActionID {
        
        case UNNotificationDefaultActionIdentifier: // 用户点击通知本体
            var slotID: Int?
            switch actionID {
            case NotificationController.switchToSlot1Identifier:
                if CellularController.instance.setDataSlot(slot: 1) {
                    // 执行点击后的操作
                    ExtraActionController.instance.performExtraActions(slotID: 1)
                    slotID = 1
                    // 判断是否退出app
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.switchToSlot2Identifier:
                if CellularController.instance.setDataSlot(slot: 2) {
                    // 执行点击后的操作
                    ExtraActionController.instance.performExtraActions(slotID: 2)
                    slotID = 2
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.switch3GIdentifier:
                if CellularController.instance.setDataPreferredRate(selectRate: DataRates._3G) {
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.switch4GIdentifier:
                if CellularController.instance.setDataPreferredRate(selectRate: DataRates._4G) {
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.switch5GIdentifier:
                if CellularController.instance.setDataPreferredRate(selectRate: DataRates._5G) {
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.turnOnCellularPlanIdentifier:
                if CellularController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: true) {
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.turnOffCellularPlanIdentifier:
                if CellularController.instance.setCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1(), enable: false) {
                    UIUtils.exitApplicationAfterAction()
                }
            case NotificationController.refreshCellularConnectionIdentifier:
                if CellularController.instance.refreshCellularConnection() {
                    UIUtils.exitApplicationAfterAction()
                }
            default: break
            }
            // 补发通知
            NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: groupID, switchedSlotID: slotID)
            
        case NotificationController.disableThisGroupNotificationsActionID: // 禁用当前的分组通知
            if let groupID {
                if groupID == NotificationController.switchSlotGroupIdentifier { // 关闭切换蜂窝网络的通知
                    SettingsUtils.instance.setEnableToggleCellularDataSlotNotifications(enable: false)
                } else if groupID == NotificationController.switchNetworkTypeGroupIdentifier { // 关闭切换蜂窝类型的通知
                    SettingsUtils.instance.setEnableToggleNetworkTypeNotifications(enable: false)
                } else if groupID == NotificationController.switchCellularPlanGroupIdentifier { // 关闭切换蜂窝数据卡的通知
                    SettingsUtils.instance.setEnableToggleCellularPlanNotifications(enable: false)
                } else if groupID == NotificationController.maintenanceGroupIdentifier { // 关闭维护的通知
                    SettingsUtils.instance.setEnableRefreshCellularConnectionNotifications(enable: false)
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
