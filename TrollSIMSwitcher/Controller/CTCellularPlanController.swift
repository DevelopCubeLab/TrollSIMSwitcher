import Foundation

class CTCellularPlanController {
    
    // 单例对象
    static let instance = CTCellularPlanController()
    
    private let cellularPlanManager: CTCellularPlanManager = CTCellularPlanManager.shared()
 
    private var plans: [CTCellularPlanItem] = []
    private var lastFetchPlansTimeStamp: Int = 0
    
    private init() {
        //
    }
    
    // 加载全部数据流量卡
    private func loadCellularPlans() {
        
        // 缓存如果大于30s就去获取一次新的数据
        if (Int(Date().timeIntervalSince1970) - lastFetchPlansTimeStamp) > 30 {
            let sema = DispatchSemaphore(value: 0) // 创建一个信号量为 0 的锁

            cellularPlanManager.planItems { items in
                self.plans = items ?? []
                sema.signal() // 继续线程
            }

//            sema.wait() // 挂起线程
            
            let result = sema.wait(timeout: .now() + 1.0)
            if result == .timedOut { // 处理超时的问题
                plans = []
            }
            
            lastFetchPlansTimeStamp = Int(Date().timeIntervalSince1970) // 把当前的时间戳写入，作为判断缓存的标志
        }
    }
    
    // 获取全部蜂窝数据卡
    func getCellularPlans() -> [CTCellularPlanItem] {
        loadCellularPlans()
        return plans
    }
    
    // 获取某个蜂窝数据卡
    func getCellularPlan(planID: String) -> CTCellularPlanItem? {
        loadCellularPlans()
        return plans.first { $0.identifier == planID }
    }
    
    // 设置蜂窝数据卡启用或者关闭
    func setCellularPlanEnable(planID: String, enable: Bool) -> Bool {
        if let plan = getCellularPlan(planID: planID) {
            if plan.isSelected == enable { // 同一个状态就不用切换了
                return true
            }
            cellularPlanManager.didSelectPlanItem(plan, isEnable: enable)
            // 设置缓存失效，这样就可以立刻刷新数据卡数据
            lastFetchPlansTimeStamp = 0
            return true
        }
        return false
    }
    
    func toggleCellularPlanEnable(planID: String) -> Bool {
        if let plan = getCellularPlan(planID: planID) {
            return setCellularPlanEnable(planID: planID, enable: !plan.isSelected)
        }
        return false
    }
    
}
