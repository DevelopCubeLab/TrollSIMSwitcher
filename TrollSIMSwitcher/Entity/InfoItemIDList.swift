import Foundation

enum HomeItemGroupID {
    static let cellularDataGroup = 0
    static let networkTypeGroup = 1
    static let cellularPlanGroup = 2
    static let maintenanceGroup = 3
    static let optionsGroup = 4
    static let shortcutsGroup = 5
    static let notificationsGroup = 6
    static let aboutGroup = 7
}

enum HomeItemID {
    static let slot1 = 1 // ID不要变
    static let slot2 = 2 // ID不要变
    static let refreshCellularConnection = 3
    static let rebootCommCenter = 4
    static let cellularPlan = 5
    static let selectCellularPlan = 6
    static let sendNotification = -7
    static let goToNotificationSettings = -8
    static let versionCode = 9
    static let githubLink = 10
    static let havocLink = 11
}

// 主界面切换开关的tag
enum SettingsSwitchViewTag {
    static let EnableCompatibilitySwitchMode = 0
    static let ShowSlotLabel = 1
    static let ShowOperatorName = 2
    static let ShowPhoneNumber = 3
    static let EnableHomeScreenQuickActions = 4
    static let ExitAfterQuickSwitching = 5
    static let EnableNotifications = 6
    static let EnableToggleCellularDataSlotNotifications = 7
    static let EnableToggleNetworkTypeNotifications = 8
    static let EnableToggleCellularPlanNotifications = 9
    static let UseCriticalNotifications = 10
    static let ShowAlertWhenTurningOffCellularPlan = 11
}
