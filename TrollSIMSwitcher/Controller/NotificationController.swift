import Foundation
import UserNotifications

class NotificationController {
    // 单例模式
    static let instance = NotificationController()
    private init() {
        //
    }
    
    enum NotificationPostStyle {
        case normal        // 正常通知
        case silent        // 静默通知
        case followUp      // 回补（静默，主要进列表）
    }

    private let center = UNUserNotificationCenter.current()

    /// 通知标识
    /// 切换卡槽的标识符
    static let switchSlotGroupIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch.slot"
    static let switchToSlot1Identifier = "com.developlab.TrollSIMSwitcher.notification.switchToSlot1"
    static let switchToSlot2Identifier = "com.developlab.TrollSIMSwitcher.notification.switchToSlot2"
    /// 切换网络类型的标识符
    static let switchNetworkTypeGroupIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch.networkType"
//    static let switch2GIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch2G"
    static let switch3GIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch3G"
    static let switch4GIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch4G"
    static let switch5GIdentifier = "com.developlab.TrollSIMSwitcher.notification.switch5G"
    /// 长按通知的标识符
    static let disableNotificationCategoryID = "com.developlab.TrollSIMSwitcher.notification.disable.group"
    static let disableAllNotificationsActionID = "com.developlab.TrollSIMSwitcher.notification.disable.all"
    static let disableThisGroupNotificationsActionID = "com.developlab.TrollSIMSwitcher.notification.disable.thisGroup"

    // 获取切换网络类型的标识符
    static func getToggleNetworkTypeNotificationIdentifier(rate: Int64) -> String {
        switch rate {
//        case DataRates._2G.rawValue: return NotificationController.switch2GIdentifier
        case DataRates._3G.rawValue: return NotificationController.switch3GIdentifier
        case DataRates._4G.rawValue: return NotificationController.switch4GIdentifier
        case DataRates._5G.rawValue: return NotificationController.switch5GIdentifier
        default: return NotificationController.disableNotificationCategoryID
        }
    }
    
    /// 统一处理通知权限检查与请求
    /// - Note:
    ///   - 若当前为 `.notDetermined` 则会触发系统授权弹窗，并在用户选择后回调 `.authorized` 或 `.denied`
    ///   - 其它情况直接返回当前的 `authorizationStatus`
    func ensureAuthorization(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { [weak self] settings in
            guard let _ = self else { return }
            completion(settings.authorizationStatus)
        }
    }

    // MARK: - 申请权限
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        
        if #available(iOS 15.0, *) { // 大于等于iOS 15需要申请timeSensitive 来获得更好的体验
            center.requestAuthorization(options: [.alert, .sound, .badge, .timeSensitive, .criticalAlert]) { granted, _ in
                completion(granted)
            }
        } else { // 只申请普通通知权限和重要提醒的权限
            center.requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, _ in
                completion(granted)
            }
        }
    }

    func getSettings(_ completion: @escaping (UNNotificationSettings) -> Void) {
        center.getNotificationSettings { settings in completion(settings) }
    }
    
    func setupNotificationCategories() {
        // 关闭本组通知
        let disableThisGroupNotificationsAction = UNNotificationAction(
            identifier: Self.disableThisGroupNotificationsActionID,
            title: NSLocalizedString("DisableThisGroupNotifications", comment: "禁用本组通知"),
            options: [.foreground]
        )
        
        // 关闭全部通知
        let disableAllNotificationsAction = UNNotificationAction(
            identifier: Self.disableAllNotificationsActionID,
            title: NSLocalizedString("DisableAllNotifications", comment: "禁用全部通知"),
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: Self.disableNotificationCategoryID,
            actions: [disableThisGroupNotificationsAction, disableAllNotificationsAction],   // 长按菜单里的内容
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([category])
    }
    
    // 获取是否已经拿到重要通知权利
    func isCriticalNotificationEnabled( completion: @escaping (Bool) -> Void) {
        center.getNotificationSettings { settings in
            completion(settings.criticalAlertSetting == .enabled)
        }
    }

    // MARK: - 发送：快捷入口（参数化）
    /// - Parameters:
    ///   - title: 通知标题（例如："快速打开 App"）
    ///   - groupIdentifier 当前通知分组的ID
    ///   - actionIdentifier 当前通知的ID
    ///   - style 发送通知的类型
    ///   - preferTimeSensitive: 若系统允许则使用时效性
    func postNotification(
        title: String,
        groupIdentifier: String,
        actionIdentifier: String,
        style: NotificationPostStyle = .normal,
        preferTimeSensitive: Bool = true
    ) {
        // 用户全局关闭通知，直接不发通知
        guard SettingsUtils.instance.getEnableNotifications() else {
            return
        }

        let post: (UNNotificationSettings?) -> Void = { settings in
            let content = UNMutableNotificationContent() // 创建一个通知
            content.title = title // 标题
            content.categoryIdentifier = Self.disableNotificationCategoryID // 设置分类，方便禁用通知

            // 操作ID放在 userInfo
            content.userInfo = [
                "group": groupIdentifier,
                "action": actionIdentifier
            ]

            // 静默 / 回补策略
            switch style {
            case .normal:
                break
            case .silent, .followUp:
                content.sound = nil
            }

            // 先判断是否开启紧急通知
            if SettingsUtils.instance.getUseCriticalNotifications(), settings?.criticalAlertSetting == .enabled {
                if #available(iOS 15.0, *) {
                    content.sound = UNNotificationSound.defaultCriticalSound(withAudioVolume: 0.0) // 必须设置这个声音，但是其实是个没有声音的提示，但是这样可以激活重要通知
                } else {
                    // 必须设置这个声音，但是其实是个没有声音的提示，但是这样可以激活重要通知 iOS 14可能无法可靠的发送重要通知
                    content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(""), withAudioVolume: 0.0)
                }
                
            } else if #available(iOS 15.0, *) { // 实效性通知 Time Sensitive（iOS 15+）
                // 再判断是否开启实效性通知
                if preferTimeSensitive, settings?.timeSensitiveSetting == .enabled {
                    content.interruptionLevel = .timeSensitive
                }
            }

            // 覆盖同一组通知，防止点击以后还存在别的
            self.center.removeDeliveredNotifications(
                withIdentifiers: [groupIdentifier]
            )

            let request = UNNotificationRequest(
                identifier: groupIdentifier, // 分组ID
                content: content,
                trigger: nil
            )

            self.center.add(request, withCompletionHandler: nil) // 发通知
        }

        // 权限判断
        if #available(iOS 15.0, *) {
            getSettings { settings in
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    post(settings)
                default:
                    return
                }
            }
        } else {
            post(nil)
        }
    }

    // MARK: - 前台展示策略（供 AppDelegate 复用）
    func presentationOptions(for notification: UNNotification) -> UNNotificationPresentationOptions {
        return [.list]
    }
    
    // 清除全部通知
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()   // 移除所有未触发的
        center.removeAllDeliveredNotifications()        // 移除通知中心已显示的
    }
    
    // 清除一组的通知
    func clearNotifications(groupIdentifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [groupIdentifier])
        center.removeDeliveredNotifications(withIdentifiers: [groupIdentifier])
    }
    
    // 给外部访问的发送通知的方法，不需要每个地方都单独写了
    
    func sendNotifications(silentNotifications: Bool, groupIdentifier: String? = nil) {
        
        // 获取SIM卡数据
        let SIMSlotList = CoreTelephonyController.instance.getAllEnabledSlots()
        
        // 删除全部通知
        clearAllNotifications()
        
        // 创建通知的类型 是否静默发送到通知中心
        let postStyle: NotificationPostStyle = silentNotifications ? .followUp : .normal
        
        // 发送切换卡槽的通知
        if SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() {
            if let slot = SIMSlotList.first(where: {
                if let groupID = groupIdentifier {
                    if groupID == NotificationController.switchSlotGroupIdentifier {
                        return $0.isDataPreferred // 如果是切换数据流量卡 那就选择当前的卡，因为基带还没刷新
                    }
                }
                return !$0.isDataPreferred // 选择另一张卡，因为我们要切换过去
//                !$0.isDataPreferred
                
            }) { // 获取非首选数据卡
                let titleText: String
                if SettingsUtils.instance.getShowSlotLabel() {
                    titleText = String.localizedStringWithFormat(NSLocalizedString("SwitchFromTo", comment: ""), NSLocalizedString("CellularData", comment: ""), slot.label)
                } else {
                    titleText = String.localizedStringWithFormat(NSLocalizedString("SwitchFromTo", comment: ""), NSLocalizedString("CellularData", comment: ""), String.localizedStringWithFormat(NSLocalizedString("SlotNumber", comment: ""), slot.slot))
                }
                // 发送通知
               postNotification(title: titleText, groupIdentifier: NotificationController.switchSlotGroupIdentifier, actionIdentifier: slot.slot == 1 ? NotificationController.switchToSlot1Identifier : NotificationController.switchToSlot2Identifier, style: postStyle)
            }
        }
        // 发送切换蜂窝数据类型的通知
        if SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() {
            if let dataSlot = SIMSlotList.first(where: {
                if let groupID = groupIdentifier {
                    if groupID == NotificationController.switchSlotGroupIdentifier {
                        return !$0.isDataPreferred // 如果是切换数据流量卡 那就选择另外一个，否则就是选择自己
                    }
                }
                return $0.isDataPreferred
            }) { // 获取首选数据卡
                if dataSlot.supportedRates?.rates.count ?? 0 > 1 { // 超过一个网络类型时才发送通知
                    for rate in dataSlot.supportedRates?.rates as! [Int64] {
                        if rate != dataSlot.currentRate && rate != DataRates._2G.rawValue { // 不发送当前网络类型一致的通知,并且不发送切换到2G的通知，都什么年代了有人用2G？
                            // 发送通知
                            postNotification(title: String.localizedStringWithFormat(NSLocalizedString("SwitchFromTo", comment: ""), NSLocalizedString("NetworkType", comment: ""),  CellularUtils.getRateText(rate: Int(rate))), groupIdentifier: NotificationController.switchNetworkTypeGroupIdentifier, actionIdentifier: NotificationController.getToggleNetworkTypeNotificationIdentifier(rate: rate), style: postStyle)
                        }
                    }
                }
            }
        }
        
    }
    
}
