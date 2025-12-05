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
