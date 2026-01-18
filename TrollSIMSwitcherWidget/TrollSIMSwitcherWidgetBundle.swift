import WidgetKit
import SwiftUI

@main
struct TrollSIMSwitcherWidgetBundle: WidgetBundle {
    var body: some Widget {
        TrollSIMSwitcherSlot1()
        TrollSIMSwitcherSlot2()
        TrollSIMSwitcherToggleSlot()
        TrollSIMSwitcher4G()
        TrollSIMSwitcher5G()
        TrollSIMSwitcherToggleNetworkType()
        TrollSIMSwitcherTurnOnCellularPlan()
        TrollSIMSwitcherTurnOffCellularPlan()
        TrollSIMSwitcherToggleCellularPlan()
    }
}
