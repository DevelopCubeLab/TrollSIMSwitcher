import SwiftUI
import CoreLocation
import WidgetKit

struct LockScreenEntry: TimelineEntry {
    let date: Date
}

struct SimpleLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> LockScreenEntry {
        return LockScreenEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LockScreenEntry) -> Void) {
        let entry = LockScreenEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LockScreenEntry>) -> Void) {
        let entry = LockScreenEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherSlot1: Widget {
    let kind: String = "TrollSIMSwitcherSlot1"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherSlot1View(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataCard", comment: ""))
        .description("SwitchToSlot1")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherSlot2: Widget {
    let kind: String = "TrollSIMSwitcherSlot2"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherSlot2View(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataCard", comment: ""))
        .description("SwitchToSlot2")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherToggleSlot: Widget {
    let kind: String = "TrollSIMSwitcherToggleSlot"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherToggleSlotView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataCard", comment: ""))
        .description("ToggleSlot")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcher4G: Widget {
    let kind: String = "TrollSIMSwitcher4G"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherSlot4GView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataType", comment: ""))
        .description("SwitchTo4G")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcher5G: Widget {
    let kind: String = "TrollSIMSwitcher5G"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherSlot5GView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataType", comment: ""))
        .description("SwitchTo5G")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherToggleNetworkType: Widget {
    let kind: String = "TrollSIMSwitcherToggleNetworkType"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherToggleNetworkTypeView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchDataType", comment: ""))
        .description("ToggleCellularNetworkType")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherTurnOnCellularPlan: Widget {
    let kind: String = "TrollSIMSwitcherTurnOnCellularPlan"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherTurnOnCellularPlanView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchCellularPlan", comment: ""))
        .description("TurnOnCellularPlan")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherTurnOffCellularPlan: Widget {
    let kind: String = "TrollSIMSwitcherTurnOffCellularPlan"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherTurnOffCellularPlanView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchCellularPlan", comment: ""))
        .description("TurnOffCellularPlan")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherToggleCellularPlan: Widget {
    let kind: String = "TrollSIMSwitcherToggleCellularPlan"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherToggleCellularPlanView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("SwitchCellularPlan", comment: ""))
        .description("ToggleCellularPlanStatus")
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct TrollSIMSwitcherRebootCommCenter: Widget {
    let kind: String = "TrollSIMSwitcherRebootCommCenter"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleLockScreenProvider()) { entry in
            TrollSIMSwitcherRebootCommCenterView(entry: entry)
        }
        .configurationDisplayName(NSLocalizedString("RebootCommCenter", comment: ""))
        .description("RebootCommCenterDescription")
        .supportedFamilies([.accessoryCircular])
    }
}

struct TrollSIMSwitcherSlot1View: View {
    var entry: LockScreenEntry
    
    var body: some View {
        ZStack {
            Image(systemName: "simcard")
                .resizable()
                .scaledToFit()
                .padding(14)
                .accessibilityLabel(Text("SwitchToSlot1")) // 无障碍化VoiceOver读取的描述
        }
        .applyLockScreenBackground() // 背景
    }
}

struct TrollSIMSwitcherSlot2View: View {
    var entry: LockScreenEntry
    
    var body: some View {
        ZStack {
            Image(systemName: "simcard.2")
                .resizable()
                .scaledToFit()
                .padding(14)
                .accessibilityLabel(Text("SwitchToSlot2")) // 无障碍化VoiceOver读取的描述
        }
        .applyLockScreenBackground() // 背景
    }
}

struct TrollSIMSwitcherToggleSlotView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "simcard.2")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "repeat")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

struct TrollSIMSwitcherSlot4GView: View {
    var entry: LockScreenEntry
    
    var body: some View {
        ZStack {
            Text("4G")
                .font(.system(size: 24, weight: .bold))
                .minimumScaleFactor(0.5)
                .padding(8)
        }
        .applyLockScreenBackground() // 背景
    }
}

struct TrollSIMSwitcherSlot5GView: View {
    var entry: LockScreenEntry
    
    var body: some View {
        ZStack {
            Text("5G")
                .font(.system(size: 24, weight: .bold))
                .minimumScaleFactor(0.5)
                .padding(8)
        }
        .applyLockScreenBackground() // 背景
    }
}

struct TrollSIMSwitcherToggleNetworkTypeView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "repeat")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

struct TrollSIMSwitcherTurnOnCellularPlanView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "simcard")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

struct TrollSIMSwitcherTurnOffCellularPlanView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "simcard")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

struct TrollSIMSwitcherToggleCellularPlanView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "simcard")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "power")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

struct TrollSIMSwitcherRebootCommCenterView: View {
    var entry: LockScreenEntry
    var body: some View {
        ZStack {
            // 主图标
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 32))
                .foregroundColor(.primary)

            // 右下角图标
            ZStack {
                Circle()
                    .fill(Color.white)  // 白色背景，防止图标透过去
                    .frame(width: 20, height: 20)

                Image(systemName: "power")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black) // 黑色反差最大
            }
            .offset(x: 12, y: 12) // 偏移位置
        }
        .frame(width: 44, height: 44)
        .applyLockScreenBackground()
    }
}

extension View {
    @ViewBuilder
    func applyLockScreenBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(Color.blue, for: .widget)
        } else { // iOS 16 fallback
            self.background(Color.clear)
        }
    }
}
