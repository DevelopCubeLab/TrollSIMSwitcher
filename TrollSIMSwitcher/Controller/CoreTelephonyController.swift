import Foundation
import CoreTelephony

class CoreTelephonyController: NSObject, CoreTelephonyClientDelegate, CoreTelephonyClientDataDelegateInternal, CoreTelephonyClientRegistrationDelegateInternal, CTTelephonyNetworkInfoDelegate {
    
    // 单例实例
    static let instance = CoreTelephonyController()
    
    // CoreTelephonyClient 实例
    private let coreTelephonyClient: CoreTelephonyClient = CoreTelephonyClient()
    // 创建CTServerConnection 实例
    private let connection: CTServerConnectionRef
    private let networkInfo = CTTelephonyNetworkInfo()
    
    private override init() {
        // 创建 CTServerConnection 连接
        self.connection = _CTServerConnectionCreate(kCFAllocatorDefault, nil, nil)
        super.init()
        coreTelephonyClient.setDelegate(self)
        networkInfo.delegate = self
    }
    
    /// 获取设备的卡槽数量
    /// 用于判断设备有几个IMEI
    /// 返回卡槽数量
    func getDeviceSlotCount() -> Int {
        do {
            return try getDeviceInfoList().meInfoList.count
        } catch {
            return 0
        }
    }
    
    // 获取全部IMEI列表
    private func getDeviceIMEI(number: Int) -> String? {
        // 获取是否存在设备信息
        guard let list = try? getDeviceInfoList().meInfoList else {
            return nil
        }
        
        let index = number - 1
        // 判断获取的IMEI是否越界
        guard index >= 0 && index < list.count else {
            return nil
        }
        // 获取IMEI并且返回
        return list[index].imei
    }
    
    /// 获取设备的IMEI 1
    /// 支持蜂窝网络的机器+有权限会返回
    func getDeviceIMEI1() -> String? {
        return getDeviceIMEI(number: 1)
    }
    
    /// 获取设备的IMEI 2
    /// 部分设备无IMEI 2
    /// 比如老款设备XS之前的设备，还有CH/A的 XS、SE 2、SE 3、12 mini、13 mini，还有蜂窝版iPad
    func getDeviceIMEI2() -> String? {
        return getDeviceIMEI(number: 2)
    }
    
    /// 获取设备基本信息的列表
    /// 包括卡槽的基本IMEI信息
    /// 包括EID和MEID(老设备可选)
    /// 获取卡槽的设备信息用 getSlotMobileEquipmentInfo
    /// 无权限时抛异常 错误代码 1
    func getDeviceInfoList() throws -> CTMobileEquipmentInfoList {
        return try coreTelephonyClient.getMobileEquipmentInfo()
    }

    // 根据slot获取当前插槽的Context
    func getServiceSubscriptionContext(slot: Int) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(slot: Int32(slot))
    }
    
    // 根据slot的uuid获取当前插槽的Context
    func getServiceSubscriptionContext(uuid: UUID) -> CTXPCServiceSubscriptionContext? {
        return CTXPCServiceSubscriptionContext(uuid: uuid)
    }
    
    // 获取当前首选卡槽的context
    func getDataPreferredContext() throws -> CTXPCServiceSubscriptionContext {
        return try coreTelephonyClient.getPreferredDataSubscriptionContextSync()
    }
    
    // 获取当前首选卡槽的ID
    func getDataPreferredSlotID() throws -> Int64 {
        return try getDataPreferredContext().slotID
    }
    
    // 获取当前首选卡槽的网络类型
    func getDataPreferredSlotRate() throws -> Int64 {
        return try getSlotSelectRate(context: getDataPreferredContext())
    }
    
    // 获取当前首选卡槽支持的网络类型
    func getDataPreferredSlotSupportRates() throws -> [Int64] {
        if let rates = try coreTelephonyClient.getSupportedDataRates(getDataPreferredContext()).rates as? [Int64] {
            return rates
        }
        return []
    }
    
    /// 获取卡槽首选网络类型
    /// 返回值 1 = 2G
    /// 返回值 2 = 3G
    /// 返回值 3 = 4G
    /// 返回值 4 = 5G
    func getSlotSelectRate(context: CTXPCServiceSubscriptionContext) throws -> Int64 {
        var error: NSError? // 创建一个接收错误信息的对象
        let result = coreTelephonyClient.getMaxDataRate(context, error: &error)
        if let error = error { // 判断是否有错误 有错误就抛异常给上层
            throw error
        }
        return result
    }
    
    /// 获取卡槽支持并且可选择的网络类型
    /// 返回值 1 = 2G
    /// 返回值 2 = 3G
    /// 返回值 3 = 4G
    /// 返回值 4 = 5G
    /// 不允许更改网络类型的SIM卡/运营商返回nil
    func getSlotSupportRates(context: CTXPCServiceSubscriptionContext) -> [Int64] {
        do {
            return try coreTelephonyClient.getSupportedDataRates(context).rates as? [Int64] ?? []
        } catch {
            return []
        }
    }
    
    /// 获取当前卡槽的ICCID
    func getSlotICCID(context: CTXPCServiceSubscriptionContext) throws -> String? {
        return try coreTelephonyClient.copySIMIdentity(context)
    }
    
    // 获取卡槽中卡的ICCID
    func getSlotICCID(slotID: Int) -> String? {
        do {
            if let context = getServiceSubscriptionContext(slot: slotID) {
                return try getSlotICCID(context: context)
            }
        } catch {
            return nil
        }
        return nil
    }
    
    /// 获取当前卡槽的卡标签
    /// 返回卡标签的文字
    func getSlotLabelText(context: CTXPCServiceSubscriptionContext) throws -> String {
        return try coreTelephonyClient.copyLabel(context)
    }
    
    /// 获取当前卡槽的电话号码信息
    /// 无权限时抛异常 错误代码 13
    /// 当前卡槽没有卡并且设备内就只有过一张卡的情况抛异常 错误代码 2
    @available(iOS 13.0, *)
    func getSlotPhoneNumberInfo(context: CTXPCServiceSubscriptionContext) throws -> CTPhoneNumberInfo {
        return try coreTelephonyClient.getPhoneNumber(context)
    }
    
    /// 获取当前卡槽的电话号码
    /// 低版本兼容方法 直接拿完整的 CTXPCServiceSubscriptionContext.phoneNumber 获取
    @available(iOS 13.0, *)
    func getSlotPhoneNumber(context: CTXPCServiceSubscriptionContext) throws -> String {
        return try getSlotPhoneNumberInfo(context: context).displayPhoneNumber
    }
    
    /// 获取本地化的网络运营商名称
    /// 无权限时抛异常 错误代码 1
    /// NSLocalizedString("Unknown", comment: "未知")
    func getSlotLocalizedOperatorName(context: CTXPCServiceSubscriptionContext) throws -> String {
        return try coreTelephonyClient.getLocalizedOperatorName(context)
    }
    
    /// 获取当前的卡槽的SIM卡状态
    /// 具体key和含义在 CoreTelephonyEnumMapper.mapSIMStatus
    /// 无权限时抛异常 错误代码 1
    func getSlotSIMStatus(context: CTXPCServiceSubscriptionContext) throws -> String {
        return try coreTelephonyClient.getSIMStatus(context)
    }
    
    /// 获取卡槽中的SIM卡类型
    /// 实体SIM卡 返回值 = 1
    /// Apple SIM 返回值 = 1
    /// eSIM 返回值 = 2
    /// 无权限 返回值 = 0 并且抛异常 错误代码 1
    /// iOS 14设备无权限抛异常 错误代码 13
    /// 基带服务重启时 返回值 = 0 不抛异常
    /// Apple SIM 官方文档 @See https://support.apple.com/en-us/104990
    /// iOS 18系统开始不再支持任何Apple SIM的iPad
    func getSlotSIMType(context: CTXPCServiceSubscriptionContext) throws -> Int64 {
        var error: NSError? // 创建一个接收错误信息的对象
        let result = coreTelephonyClient.isEsim(for: context, error: &error)
        if let error = error { // 判断是否有错误 有错误就抛异常给上层
            throw error
        }
        return result
    }
    
    /// 获取卡槽当前卡注册状态
    /// 返回值 kCTRegistrationStatusRegisteredHome     = 本地网络注册
    /// 返回值 kCTRegistrationStatusRegisteredRoaming  = 漫游网络注册
    /// 返回值 kCTRegistrationStatusSearching          = 正在搜索
    /// 返回值 kCTRegistrationStatusDenied             = 被网络拒绝注册
    /// 返回值 kCTRegistrationStatusEmergencyOnly      = 仅限紧急呼叫
    /// 返回值 kCTRegistrationStatusUnknown            = 未知注册状态
    /// 无权限/模拟器返回nil 抛异常 错误代码1
    func getSlotRegistrationStatus(context: CTXPCServiceSubscriptionContext) throws -> String {
        return try coreTelephonyClient.copyRegistrationStatus(context)
    }
    
    // 设置蜂窝数据首选卡
    func setActiveUserDataSelection(context: CTXPCServiceSubscriptionContext) throws {
        var error: NSError? // 创建一个接收错误信息的对象
        coreTelephonyClient.setActiveUserDataSelection(context, error: &error)
        if let error = error { // 判断是否有错误 有错误就抛异常给上层
            throw error
        }
    }
    
    /// 刷新蜂窝网络信号
    /// 无权限设备会被CommCenter抛弃请求
    func refreshCellularConnection() {
        // 设置原因
        let reason = "UserTriggeredReload" as CFString
        // 发送请求
        _CTServerConnectionResetModem(connection, reason)
    }
    
    // 设置蜂窝数据卡
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func setDataSlot(slotID: Int) -> Bool {
        if slotID <= 0 || slotID >= getDeviceSlotCount() + 1 { // 切换不能超过IMEI的最大容量，否则肯定失败
            return false
        }
        // 获取需要切换卡槽的context
        if let context = getServiceSubscriptionContext(slot: slotID) {
            do {
                // 切换数据卡
                try setActiveUserDataSelection(context: context)
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    // 切换指定卡槽的网络类型
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func setDataRate(slot: Int, selectRate: Int64) -> Bool {
        if let context = getServiceSubscriptionContext(slot: slot) {
            return coreTelephonyClient.setMaxDataRate(context, rate: selectRate) == nil // 这个私有方法只有错误的时候才会返回结果
        }
        return false
    }
    
    // 切换当前数据流量的卡槽的网络类型
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func setDataPreferredRate(selectRate: Int64) -> Bool {
        do {
            let context = try getDataPreferredContext()
            return coreTelephonyClient.setMaxDataRate(context, rate: selectRate) == nil // 这个私有方法只有错误的时候才会返回结果
        } catch {
            return false
        }
    }
    
    // 回调 通知当前状态更改
    private func notifyUpdate() {
        NotificationCenter.default.post(
            name: Notification.Name("CoreTelephonyUpdated"),
            object: nil
        )
    }
    
//    func subscriptionInfoDidChange() {
//        NSLog("[TrollSIMSwitcher] subscriptionInfoDidChange")
////        notifyUpdate()
//    }
//
//    func activeSubscriptionsDidChange() {
//        NSLog("[TrollSIMSwitcher] activeSubscriptionsDidChange")
////        notifyUpdate()
//    }
//
//    func simLessSubscriptionsDidChange() {
//        NSLog("[TrollSIMSwitcher] simLessSubscriptionsDidChange")
////        notifyUpdate()
//    }
//
//    func dualSimCapabilityDidChange() {
//        NSLog("[TrollSIMSwitcher] dualSimCapabilityDidChange")
////        notifyUpdate()
//    }
    
    func currentDataServiceDescriptorChanged(_ desc: Any?) { // 当前数据卡刷新
        NSLog("[TrollSIMSwitcher] currentDataServiceDescriptorChanged")
        notifyUpdate()
    }

    func regDataModeChanged(_ client: Any?, dataMode: Int32) { // 更改蜂窝网络类型的回调
        NSLog("[TrollSIMSwitcher] regDataModeChanged")
        notifyUpdate()
    }

//    func preferredDataSimChanged(_ x: Any?) {
//        NSLog("[TrollSIMSwitcher] preferredDataSimChanged")
////        notifyUpdate()
//    }
    
}
