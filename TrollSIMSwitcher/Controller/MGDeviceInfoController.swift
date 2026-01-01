import Foundation

class MGDeviceInfoController {
    
    // 单例实例
    static let instance = MGDeviceInfoController()
    
    // 存储IMEI
    var IMEIs: [IMEI] = []
    
    private typealias MGCopyAnswerFunc = @convention(c) (CFString) -> CFTypeRef?

    private let mGCopyAnswer: MGCopyAnswerFunc?

    private init() {
        // 加载libMobileGestalt
        let handle = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_NOW)
        if let sym = dlsym(handle, "MGCopyAnswer") {
            self.mGCopyAnswer = unsafeBitCast(sym, to: MGCopyAnswerFunc.self)
        } else {
            self.mGCopyAnswer = nil
        }
        getIMEIList()
    }

    /// 调用 MGCopyAnswer 的包装方法
    func MGCopyAnswer(_ key: String) -> Any? {
        guard let f = mGCopyAnswer else {
            NSLog("[MGDeviceInfo] MGCopyAnswer func == nil")
            return nil
        }
        return f(key as CFString)
    }

    /// 获取 IMEI1 & IMEI2
    func getIMEIList() {
        IMEIs = []
        
        fetchIMEI(id: 1, key: "InternationalMobileEquipmentIdentity")
        fetchIMEI(id: 2, key: "InternationalMobileEquipmentIdentity2")

        if IMEIs.isEmpty {
            NSLog("[MGDeviceInfo] 无 IMEI 数据")
        }
    }
    
    // 获取IMEI
    private func fetchIMEI(id: Int, key: String) {
        if let value = MGCopyAnswer(key) as? String, !value.isEmpty {
            IMEIs.append(IMEI(id: id, value: value))
        }
    }
}
