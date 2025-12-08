import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let versionCode = "1.0"
    
    private var tableView = UITableView()
    
    private var tableCellList = [[], [],
                                 [NSLocalizedString("CompatibilitySwitchMode", comment: ""),
                                  NSLocalizedString("ShowSlotLabel", comment: ""),
                                  NSLocalizedString("ShowOperatorName", comment: ""),
                                  NSLocalizedString("ShowPhoneNumber", comment: "")],
                                 [NSLocalizedString("HomeScreenQuickActions", comment: ""),
                                  NSLocalizedString("ExitAfterQuickSwitching", comment: "")],
//                                 [],
                                 [NSLocalizedString("Version", comment: ""), "GitHub"]]
    
    private var SIMSlotList: [SIMSlot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = NSLocalizedString("CFBundleDisplayName", comment: "")
        
        loadSIMSlots()
        
        // iOS 15 之后的版本使用新的UITableView样式
        if #available(iOS 15.0, *) {
            tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            tableView = UITableView(frame: .zero, style: .grouped)
        }

        // 设置表格视图的代理和数据源
        tableView.delegate = self
        tableView.dataSource = self
        
        // 注册表格单元格
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        // 将表格视图添加到主视图
        view.addSubview(tableView)

        // 设置表格视图的布局
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 设置监听器
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSIMList),
            name: Notification.Name("CoreTelephonyUpdated"),
            object: nil
        )
    }
    
    // 更新数据和更新UI
    @objc private func updateSIMList() {
        DispatchQueue.main.async {
            self.loadSIMSlots()
            self.tableView.reloadData()
        }
    }
    
    // ViewController销毁的时候取消监听器
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CoreTelephonyUpdated"), object: nil)
    }
    
    // 加载卡槽信息
    private func loadSIMSlots() {
        SIMSlotList = []
        // 获取全部卡槽信息
        SIMSlotList = CoreTelephonyController.instance.getAllSIMSlots()
        if SIMSlotList.count > 1 { // 解决下iPad没启用蜂窝数据的时候什么都不显示的情况
            // 筛选掉未启用的卡槽信息
            SIMSlotList = SIMSlotList.filter { $0.isEnabled }
        }
        // 设置快捷方式
        SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
    }

    // MARK: - 设置总分组数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableCellList.count
    }
    
    // MARK: - 设置每个分组的Cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return SIMSlotList.count
        } else if section == 1 {
            if let preferred = SIMSlotList.first(where: { $0.isDataPreferred }) { // 获取首选数据卡
                return preferred.supportedRates?.rates.count ?? 0
            } else {
                return 0
            }
        }
        return tableCellList[section].count
    }
    
    // MARK: - 设置每个分组的顶部标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return NSLocalizedString("CellularData", comment: "")
        } else if section == 1 {
            return NSLocalizedString("NetworkType", comment: "")
        } else if section == 2 {
            return NSLocalizedString("Options", comment: "")
        } else if section == 3 {
            return NSLocalizedString("Shortcuts", comment: "")
        } else if section == 4 {
            return NSLocalizedString("About", comment: "")
        }
        return nil
    }
    
    // MARK: - 设置每个分组的底部标题 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
#if DEBUG
//        if section == 0 {
//            var text = ""
//            for slot in SIMSlotList {
//                text = text.appending(slot.toString()).appending("\n")
//            }
//            return text
        
//        }
#endif
        if section == 2 {
            return String.localizedStringWithFormat(NSLocalizedString("EnableCompatibilityModeMessage", comment: ""), NSLocalizedString("CompatibilitySwitchMode", comment: ""))
        }
        return nil
    }
    
    // MARK: - 构造每个Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        
        if indexPath.section == 0 { // 卡槽选择
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            let slot = SIMSlotList[indexPath.row] // 获取当前卡槽数据
            if SettingsUtils.instance.getShowSlotLabel() { // 设置卡槽名称
                cell.textLabel?.text = slot.label
            } else {
                cell.textLabel?.text = String.localizedStringWithFormat(NSLocalizedString("SlotNumber", comment: ""), (indexPath.row + 1))
            }
            if SettingsUtils.instance.getShowOperatorName() { // 显示运营商名称
                if !slot.operatorName.isEmpty {
                    cell.textLabel?.text = "\(cell.textLabel?.text ?? "") - \(slot.operatorName)"
                } else if slot.registrationStatus == "kCTRegistrationStatusNotRegistered" { // 无服务
                    cell.textLabel?.text = "\(cell.textLabel?.text ?? "") - \(NSLocalizedString("NoService", comment: ""))"
                } else if slot.registrationStatus == "kCTRegistrationStatusEmergencyOnly" { // 仅限紧急呼叫
                    cell.textLabel?.text = "\(cell.textLabel?.text ?? "") - \(NSLocalizedString("EmergencyOnly", comment: ""))"
                }
            }
            if SettingsUtils.instance.getShowPhoneNumber() { // 显示电话号码
                cell.detailTextLabel?.text = SIMSlotList[indexPath.row].phoneNumber
                // 改变下detailTextLabel的颜色和字体大小，尽量接近系统设置中的显示风格
                cell.detailTextLabel?.textColor = .secondaryLabel
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
            }
            if SIMSlotList[indexPath.row].isDataPreferred { // 给首选数据卡画上对勾
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if indexPath.section == 1 { // 网络类型选择
            
            if let preferred = SIMSlotList.first(where: { $0.isDataPreferred }) { // 获取首选数据卡
                cell.textLabel?.text = CellularUtils.getRateText(rate: preferred.supportedRates?.rates[indexPath.row] as! Int) // 文本化显示网络类型
                
                if preferred.currentRate == preferred.supportedRates?.rates[indexPath.row] as! Int64 { // 给首选网络类型画上对勾
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
        } else if indexPath.section == 2 { // 选项
            cell.textLabel?.text = tableCellList[indexPath.section][indexPath.row]
            cell.textLabel?.numberOfLines = 0 // 允许换行
            let switchView = UISwitch(frame: .zero)
            switchView.tag = indexPath.row // 设置识别id
            if indexPath.row == 0 { // 获取设置兼容模式
                switchView.isOn = SettingsUtils.instance.getEnableCompatibilitySwitchMode() // 从配置文件中获取状态
                if SIMSlotList.count < 1 { // 只有单卡的情况
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
            } else if indexPath.row == 1 { // 显示卡槽标签
                if UIDevice.current.userInterfaceIdiom == .pad { // 这里其实可以被插件绕过，不过其实也无所谓
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
                switchView.isOn = SettingsUtils.instance.getShowSlotLabel() // 从配置文件中获取状态
            } else if indexPath.row == 2 { // 显示运营商名称
                switchView.isOn = SettingsUtils.instance.getShowOperatorName() // 从配置文件中获取状态
            } else if indexPath.row == 3 { // 显示电话号码
                switchView.isOn = SettingsUtils.instance.getShowPhoneNumber() // 从配置文件中获取状态
            }
            // 开光状态改变的回调
            switchView.addAction(UIAction { [weak self] action in
                self?.onSwitchChanged(action.sender as! UISwitch)
            }, for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            
        } else if indexPath.section == 3 { // 快捷方式
            cell.textLabel?.text = tableCellList[indexPath.section][indexPath.row]
            cell.textLabel?.numberOfLines = 0 // 允许换行
            let switchView = UISwitch(frame: .zero)
            if indexPath.row == 0 { // 桌面快捷方式
                switchView.tag = 4 // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableHomeScreenQuickActions() // 从配置文件中获取状态
            } else if indexPath.row == 1 { // 快速切换后自动退出应用程序
                switchView.tag = 5 // 设置识别id
                switchView.isOn = SettingsUtils.instance.getExitAfterQuickSwitching() // 从配置文件中获取状态
            }
            // 开光状态改变的回调
            switchView.addAction(UIAction { [weak self] action in
                self?.onSwitchChanged(action.sender as! UISwitch)
            }, for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
//        } else if indexPath.section == 4 { // 通知设置
            //
        } else if indexPath.section == 4 { // 关于
            if indexPath.row == 0 {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                cell.textLabel?.text = tableCellList[indexPath.section][indexPath.row]
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Unknown", comment: "未知")
                if version != MainViewController.versionCode { // 判断版本号是不是有人篡改
                    cell.detailTextLabel?.text = MainViewController.versionCode
                } else {
                    cell.detailTextLabel?.text = version
                }
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.textLabel?.text = tableCellList[indexPath.section][indexPath.row]
                cell.textLabel?.numberOfLines = 0 // 允许换行
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default // 启用选中效果
            }
        }
        
        return cell
    }
    
    // MARK: - Cell的点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 { // 切换数据流量卡
            if CoreTelephonyController.instance.setDataSlot(SIMSlot: SIMSlotList[indexPath.row]) {
                // 没有回调
            }
        } else if indexPath.section == 1 { // 切换网络类型
            
            if let preferred = SIMSlotList.first(where: { $0.isDataPreferred }) { // 获取首选数据卡
                let selectRate = preferred.supportedRates?.rates[indexPath.row]
                if CoreTelephonyController.instance.setDataRate(SIMSlot: SIMSlotList.first(where: { $0.isDataPreferred })!, selectRate: selectRate as! Int64) {
                    // 取消之前的选择 因为等待数据刷新大概需要1秒，会导致操作不连贯，不符合直觉，所以先在UI操作下，等待系统自动刷新数据
                    if let indices = preferred.supportedRates?.rates.indices {
                        for i in indices {
                            tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section))?.accessoryType = .none
                        }
                    }
                    // 选择当前的网络类型
                    tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                }
            }

        } else if indexPath.section == 4 { // 关于
            if indexPath.row == 1 {
                if let url = URL(string: "https://github.com/DevelopCubeLab/TrollSIMSwitcher") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func onSwitchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            SettingsUtils.instance.setEnableCompatibilitySwitchMode(enable: sender.isOn)
        } else if sender.tag == 1 {
            SettingsUtils.instance.setShowSlotLabel(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        } else if sender.tag == 2 {
            SettingsUtils.instance.setShowOperatorName(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        } else if sender.tag == 3 {
            SettingsUtils.instance.setShowPhoneNumber(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else if sender.tag == 4 {
            SettingsUtils.instance.setEnableHomeScreenQuickActions(enable: sender.isOn)
            // 设置快捷方式
            SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
        } else if sender.tag == 5 {
            SettingsUtils.instance.setExitAfterQuickSwitching(enable: sender.isOn)
        }
    }
    
    private func onClickToNotificationSettings() {
        // iOS 16+ 有官方通知设置跳转
        if #available(iOS 16.0, *) {
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
        } else {
            // iOS 15 以及更早靠 openSettingsURLString 跳转到 App 设置页
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

}

