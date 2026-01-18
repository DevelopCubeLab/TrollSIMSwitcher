import Foundation
import AppIntents

/// 快捷指令的实现

// 切换数据流量至卡槽1
@available(iOS 16, *)
struct TrollSIMSwitcherSlot1Intent: AppIntent {
    static var title: LocalizedStringResource = "SwitchCellularDataToSlot1"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.setDataSlot(slot: 1)
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 切换数据流量至卡槽2
@available(iOS 16, *)
struct TrollSIMSwitcherSlot2Intent: AppIntent {
    static var title: LocalizedStringResource = "SwitchCellularDataToSlot2"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.setDataSlot(slot: 2)
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 切换数据流量至另一个卡槽
@available(iOS 16, *)
struct TrollSIMSwitcherToggleSlotIntent: AppIntent {
    static var title: LocalizedStringResource = "SwitchDataSIM"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.toggleDataSlot()
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 切换网络类型至4G
@available(iOS 16, *)
struct TrollSIMSwitcherNetwork4GIntent: AppIntent {
    static var title: LocalizedStringResource = "SwitchNetworkTypeTo4G"
//    static var description = IntentDescription("SwitchNetworkTypeTo4GDescription")

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._4G)
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 切换网络类型至5G
@available(iOS 16, *)
struct TrollSIMSwitcherNetwork5GIntent: AppIntent {
    static var title: LocalizedStringResource = "SwitchNetworkTypeTo5G"
//    static var description = IntentDescription("SwitchNetworkTypeTo5GDescription")

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.setDataPreferredRate(selectRate: ._5G)
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 切换数据流量至另一个卡槽
@available(iOS 16, *)
struct TrollSIMSwitcherToggleNetworkTypeIntent: AppIntent {
    static var title: LocalizedStringResource = "SwitchCellularNetworkMode"
    static var description = IntentDescription("SwitchCellularNetworkModeDescription")

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let result = CoreTelephonyController.instance.toggleDataPreferredRate()
        // 刷新通知
        NotificationController.instance.sendNotifications(silentNotifications: true)
        return .result(value: result)
    }
}

// 获取当前流量卡槽
@available(iOS 16, *)
struct TrollSIMSwitcherCurrentCellularDataSlotIntent: AppIntent {
    static var title: LocalizedStringResource = "GetCurrentCellularDataSlot"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Int> {
        let result = CoreTelephonyController.instance.getDataPreferredSlotID()
        return .result(value: Int(result))
    }
}

// 获取当前网络类型
@available(iOS 16, *)
struct TrollSIMSwitcherCurrentNetworkTypeIntent: AppIntent {
    static var title: LocalizedStringResource = "GetCurrentNetworkType"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let result = CellularUtils.getRateText(rate: Int(CoreTelephonyController.instance.getDataPreferredSlotRate()))
        return .result(value: result)
    }
}

// 打开在app中选定的蜂窝数据卡
@available(iOS 16, *)
struct TrollSIMSwitcherTurnOnCellularPlanIntent: AppIntent {
    static var title: LocalizedStringResource = "TurnOnCellularPlanText"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let planID = SettingsUtils.instance.getSelectCellularPlan1()
        let result: Bool
        if planID.isEmpty {
            result = false
        } else {
            result = CoreTelephonyController.instance.setCellularPlanEnable(planID: planID, enable: true)
        }
        return .result(value: result)
    }
}

// 关闭在app中选定的蜂窝数据卡
@available(iOS 16, *)
struct TrollSIMSwitcherTurnOffCellularPlanIntent: AppIntent {
    static var title: LocalizedStringResource = "TurnOffCellularPlanText"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let planID = SettingsUtils.instance.getSelectCellularPlan1()
        let result: Bool
        if planID.isEmpty || !CoreTelephonyController.instance.canTurnOffCellularPlan() {
            result = false
        } else {
            result = CoreTelephonyController.instance.setCellularPlanEnable(planID: planID, enable: false)
        }
        return .result(value: result)
    }
}

// 切换蜂窝数据卡的开关
@available(iOS 16, *)
struct TrollSIMSwitcherToggleCellularPlanIntent: AppIntent {
    static var title: LocalizedStringResource = "ToggleCellularPlanStatus"

    static var resultType: Bool.Type { Bool.self }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {
        let planID = SettingsUtils.instance.getSelectCellularPlan1()
        let result: Bool
        if planID.isEmpty || !CoreTelephonyController.instance.canTurnOffCellularPlan() {
            result = false
        } else {
            result = CoreTelephonyController.instance.setCellularPlanEnable(planID: planID, enable: false)
        }
        return .result(value: result)
    }
}

// 用户自定义打开/关闭/切换和自定义选择蜂窝数据卡
@available(iOS 16, *)
enum CellularPlanAction: String, AppEnum { // 定义操作
    case enable
    case disable
    case toggle

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "CellularPlanAction"
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .enable: "TurnOn",
            .disable: "TurnOff",
            .toggle: "Toggle"
        ]
    }
}

@available(iOS 16, *)
struct CellularPlanEntity: AppEntity { // 定义蜂窝数据卡给用户选择

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "CellularPlan"
    }

    static var defaultQuery = CellularPlanQuery()

    let id: String
    let name: String

    // required by InstanceDisplayRepresentable
    var displayRepresentation: DisplayRepresentation {
        let title = name.isEmpty ? "UnknownCarrier" : name
        return DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: title)
        )
    }

    // （可选）有些版本会需要显式指定 idKey
    static var idKey: KeyPath<CellularPlanEntity, String> { \.id }
}

@available(iOS 16, *)
struct CellularPlanQuery: EntityQuery { // 创建一个查询

    func entities(for identifiers: [String]) async throws -> [CellularPlanEntity] {
        let plans = CoreTelephonyController.instance.getCellularPlans()
        return plans
            .filter { identifiers.contains($0.identifier) }
            .map {
                CellularPlanEntity(
                    id: $0.identifier,
                    name: $0.carrierName ?? "UnknownCarrier"
                )
            }
    }

    func suggestedEntities() async throws -> [CellularPlanEntity] {
        let plans = CoreTelephonyController.instance.getCellularPlans()
        return plans.map {
            CellularPlanEntity(
                id: $0.identifier,
                name: $0.carrierName ?? "UnknownCarrier"
            )
        }
    }
}

@available(iOS 16, *)
struct TrollSIMSwitcherManageCellularPlanIntent: AppIntent {

    static var title: LocalizedStringResource = "ManageCellularPlan"

    static var description = IntentDescription("ManageCellularPlanDescription")

    // 用户选择：操作
    @Parameter(title: "Action")
    var action: CellularPlanAction

    // 用户选择：哪张卡
    @Parameter(title: "CellularPlan")
    var plan: CellularPlanEntity

    static var resultType: Bool.Type { Bool.self }

    func perform() async throws -> some IntentResult & ReturnsValue<Bool> {

        let controller = CoreTelephonyController.instance

        let result: Bool
        switch action {
        case .enable:
            result = controller.setCellularPlanEnable(planID: plan.id, enable: true)

        case .disable:
            result = controller.setCellularPlanEnable(planID: plan.id, enable: false)

        case .toggle:
            result = controller.toggleCellularPlanEnable(planID: plan.id)
        }

        return .result(value: result)
    }
}
