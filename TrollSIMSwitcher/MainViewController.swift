import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let versionCode = "1.1"
    
    private var tableView = UITableView()
    
    private var tableCellList = [[], [],
                                 [NSLocalizedString("CompatibilitySwitchMode", comment: ""),
                                  NSLocalizedString("ShowSlotLabel", comment: ""),
                                  NSLocalizedString("ShowOperatorName", comment: ""),
                                  NSLocalizedString("ShowPhoneNumber", comment: "")],
                                 [NSLocalizedString("HomeScreenQuickActions", comment: ""),
                                  NSLocalizedString("ExitAfterQuickSwitching", comment: "")],
                                 [],
                                 [NSLocalizedString("Version", comment: ""), "GitHub", "Havoc"]]
    
    private static let notificationsAtSection = 4
    private static let aboutAtSection = 5
    
    private var SIMSlotList: [SIMSlot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = NSLocalizedString("CFBundleDisplayName", comment: "")
        
        loadSIMSlots()
        // 判断用户是否开启通知权限
        updateNotificationsCell()
        
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
        // 获取全部已经启用的卡槽信息
        SIMSlotList = CoreTelephonyController.instance.getAllEnabledSlots()
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
        } else if section == MainViewController.notificationsAtSection {
            return NSLocalizedString("Notifications", comment: "")
        } else if section == 5 {
            return NSLocalizedString("About", comment: "")
        }
        return nil
    }
    
    // MARK: - 设置每个分组的底部标题 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            return String.localizedStringWithFormat(NSLocalizedString("EnableCompatibilityModeMessage", comment: ""), NSLocalizedString("CompatibilitySwitchMode", comment: ""))
        } else if section == MainViewController.notificationsAtSection {
            return NSLocalizedString("NotificationsFooterMessage", comment: "")
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
//            switchView.tag = indexPath.row // 设置识别id
            if indexPath.row == 0 { // 获取设置兼容模式
                switchView.tag = SettingsSwitchViewTag.EnableCompatibilitySwitchMode.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableCompatibilitySwitchMode() // 从配置文件中获取状态
                if SIMSlotList.count < 1 { // 只有单卡的情况
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
            } else if indexPath.row == 1 { // 显示卡槽标签
                switchView.tag = SettingsSwitchViewTag.ShowSlotLabel.rawValue // 设置识别id
                if UIDevice.current.userInterfaceIdiom == .pad { // 这里其实可以被插件绕过，不过其实也无所谓
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
                switchView.isOn = SettingsUtils.instance.getShowSlotLabel() // 从配置文件中获取状态
            } else if indexPath.row == 2 { // 显示运营商名称
                switchView.tag = SettingsSwitchViewTag.ShowOperatorName.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getShowOperatorName() // 从配置文件中获取状态
            } else if indexPath.row == 3 { // 显示电话号码
                switchView.tag = SettingsSwitchViewTag.ShowPhoneNumber.rawValue // 设置识别id
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
                switchView.tag = SettingsSwitchViewTag.EnableHomeScreenQuickActions.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableHomeScreenQuickActions() // 从配置文件中获取状态
            } else if indexPath.row == 1 { // 快速切换后自动退出应用程序
                switchView.tag = SettingsSwitchViewTag.ExitAfterQuickSwitching.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getExitAfterQuickSwitching() // 从配置文件中获取状态
            }
            // 开光状态改变的回调
            switchView.addAction(UIAction { [weak self] action in
                self?.onSwitchChanged(action.sender as! UISwitch)
            }, for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if indexPath.section == MainViewController.notificationsAtSection { // 通知设置
            cell.textLabel?.text = tableCellList[indexPath.section][indexPath.row]
            cell.textLabel?.numberOfLines = 0 // 允许换行
            let switchView = UISwitch(frame: .zero)
            if indexPath.row == 0 {
                switchView.tag = SettingsSwitchViewTag.EnableNotifications.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableNotifications() // 从配置文件中获取状态
            } else if indexPath.row == 1 {
                if tableCellList[MainViewController.notificationsAtSection].count == 2 { // 如果只有两条的情况，那就说明禁用了通知
                    cell.textLabel?.textColor = .systemBlue // 文本设置成蓝色
                    return cell
                }
                // 开启切换蜂窝数据流量卡通知
                switchView.tag = SettingsSwitchViewTag.EnableToggleCellularDataSlotNotifications.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() // 从配置文件中获取状态
                if SIMSlotList.count < 1 { // 只有单卡的情况
                    if SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() {
                        SettingsUtils.instance.setEnableToggleCellularDataSlotNotifications(enable: false) // 如果之前开启，现在条件不满足了，则关闭这组通知
                    }
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
            } else if indexPath.row == 2 {
                // 切换网络类型通知
                switchView.tag = SettingsSwitchViewTag.EnableToggleNetworkTypeNotifications.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() // 从配置文件中获取状态
                let preferred = SIMSlotList.first(where: { $0.isDataPreferred })
                if preferred != nil || SIMSlotList.isEmpty { // 获取首选数据卡
                    if preferred?.supportedRates?.rates.count ?? 0 < 2 { // 少于两个网络类型则不支持这组通知，没有什么意义
                        if SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() {
                            SettingsUtils.instance.setEnableToggleNetworkTypeNotifications(enable: false) // 如果之前开启，现在条件不满足了，则关闭这组通知
                        }
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                        switchView.isEnabled = false // 禁用开关
                    }
                }
            } else if indexPath.row == 3 {
                // 使用重要通知
                switchView.tag = SettingsSwitchViewTag.UseCriticalNotifications.rawValue // 设置识别id
                switchView.isOn = SettingsUtils.instance.getUseCriticalNotifications() // 从配置文件中获取状态
            } else if indexPath.row == 4 || indexPath.row == 5 {
                cell.textLabel?.textColor = .systemBlue // 文本设置成蓝色
                return cell
            }
            // 开光状态改变的回调
            switchView.addAction(UIAction { [weak self] action in
                self?.onSwitchChanged(action.sender as! UISwitch)
            }, for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if indexPath.section == MainViewController.aboutAtSection { // 关于
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
                // 补发通知
                NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: NotificationController.switchSlotGroupIdentifier)
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
                    // 补发普通通知
                    NotificationController.instance.sendNotifications(silentNotifications: true)
                }
            }

        } else if indexPath.section == MainViewController.notificationsAtSection {
            if indexPath.row == 1 && tableCellList[MainViewController.notificationsAtSection].count < 3 { // 跳转到通知设置
                self.onClickToNotificationSettings()
            } else if indexPath.row == 4 { // 发送通知
                self.onClickSendNotification()
            } else if indexPath.row == 5 { // 跳转到通知设置
                self.onClickToNotificationSettings()
            }
        } else if indexPath.section == MainViewController.aboutAtSection { // 关于
            if indexPath.row == 1 {
                if let url = URL(string: "https://github.com/DevelopCubeLab/TrollSIMSwitcher") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else if indexPath.row == 2 {
                if let url = URL(string: "https://havoc.app/package/trollsimswitch") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    private func onSwitchChanged(_ sender: UISwitch) {
        if sender.tag == SettingsSwitchViewTag.EnableCompatibilitySwitchMode.rawValue {
            SettingsUtils.instance.setEnableCompatibilitySwitchMode(enable: sender.isOn)
        } else if sender.tag == SettingsSwitchViewTag.ShowSlotLabel.rawValue {
            SettingsUtils.instance.setShowSlotLabel(enable: sender.isOn)
            // 设置快捷方式
            SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
            // 补发普通通知
            NotificationController.instance.sendNotifications(silentNotifications: true)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        } else if sender.tag == SettingsSwitchViewTag.ShowOperatorName.rawValue {
            SettingsUtils.instance.setShowOperatorName(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        } else if sender.tag == SettingsSwitchViewTag.ShowPhoneNumber.rawValue {
            SettingsUtils.instance.setShowPhoneNumber(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        } else if sender.tag == SettingsSwitchViewTag.EnableHomeScreenQuickActions.rawValue {
            SettingsUtils.instance.setEnableHomeScreenQuickActions(enable: sender.isOn)
            // 设置快捷方式
            SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
        } else if sender.tag == SettingsSwitchViewTag.ExitAfterQuickSwitching.rawValue {
            SettingsUtils.instance.setExitAfterQuickSwitching(enable: sender.isOn)
        } else if sender.tag == SettingsSwitchViewTag.EnableNotifications.rawValue {
            if sender.isOn {
                // 判断通知权限
                NotificationController.instance.ensureAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .notDetermined: // 未授权
                            sender.setOn(false, animated: true)
                            // 授权
                            NotificationController.instance.requestAuthorization { granted in
                                DispatchQueue.main.async {
                                    if !granted { // 拒绝授权
                                        sender.setOn(false, animated: true)
                                        SettingsUtils.instance.setEnableNotifications(enable: false)
                                        UIUtils.showAlert(message: NSLocalizedString("NotificationsPermissionDenied", comment: "通知权限已拒绝"), in: self)
                                    } else {
                                        sender.setOn(true, animated: true)
                                        SettingsUtils.instance.setEnableNotifications(enable: true)
                                    }
                                    self.updateNotificationsCell()
                                }
                                
                            }
                            return
                        case .authorized, .provisional, .ephemeral: // 已授权
                            SettingsUtils.instance.setEnableNotifications(enable: true)
                            sender.setOn(true, animated: true)
                        case .denied: // 已拒绝
                            UIUtils.showAlert(
                                message: NSLocalizedString("NotificationsPermissionGoToSettings", comment: "通知权限已拒绝"),
                                in: self
                            )
                            sender.setOn(false, animated: true)
                        @unknown default:
                            sender.setOn(false, animated: true)
                        }
                        self.updateNotificationsCell()
                    }
                    
                }
            } else {
                // 用户关闭通知开关 → 仅更新设置
                SettingsUtils.instance.setEnableNotifications(enable: false)
                // 把所有通知删除
                NotificationController.instance.clearAllNotifications()
                updateNotificationsCell()
            }
        } else if sender.tag == SettingsSwitchViewTag.EnableToggleCellularDataSlotNotifications.rawValue {
            SettingsUtils.instance.setEnableToggleCellularDataSlotNotifications(enable: sender.isOn)
            // 刷新通知
            NotificationController.instance.sendNotifications(silentNotifications: true)
        } else if sender.tag == SettingsSwitchViewTag.EnableToggleNetworkTypeNotifications.rawValue {
            SettingsUtils.instance.setEnableToggleNetworkTypeNotifications(enable: sender.isOn)
            // 刷新通知
            NotificationController.instance.sendNotifications(silentNotifications: true)
        } else if sender.tag == SettingsSwitchViewTag.UseCriticalNotifications.rawValue {
            if sender.isOn {
                
                NotificationController.instance.requestAuthorization { _ in // 再次申请权限
                        NotificationController.instance.isCriticalNotificationEnabled { enabled in

                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else {
                                    return
                                }
                                
                                if enabled { // 拿到了重要通知权限
                                    SettingsUtils.instance.setUseCriticalNotifications(enable: true)
                                    // 刷新通知
                                    NotificationController.instance.sendNotifications(silentNotifications: true)
                                    
                                } else { // 没拿到 提示用户开启
                                    sender.setOn(false, animated: true)
                                    SettingsUtils.instance.setUseCriticalNotifications(enable: false)
                                    UIUtils.showAlert(message: NSLocalizedString("CriticalAlertMessage", comment: ""), in: self)
                                }
                            }
                        }
                    }
                
            } else {
                SettingsUtils.instance.setUseCriticalNotifications(enable: false)
                // 刷新通知
                NotificationController.instance.sendNotifications(silentNotifications: true)
            }
            
        }
    }
    
    // 更新通知的cell
    private func updateNotificationsCell() {
        // 第一次先清空
        tableCellList[MainViewController.notificationsAtSection] = []
        tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("Enable", comment: ""))
        
        // 判断是否关闭了重要通知
        if SettingsUtils.instance.getUseCriticalNotifications() {
            NotificationController.instance.isCriticalNotificationEnabled { enabled in
                if !enabled {
                    SettingsUtils.instance.setUseCriticalNotifications(enable: false)
                }
            }
        }
        
        // 必须等待权限查询完才能更新 UI
        NotificationController.instance.ensureAuthorization { status in
            DispatchQueue.main.async {
                self.tableCellList[MainViewController.notificationsAtSection] = []
                self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("Enable", comment: ""))
                switch status {
                case .authorized, .provisional, .ephemeral:
                    if SettingsUtils.instance.getEnableNotifications() { // 用户开启开关 + 已授权
                        // 切换流量卡的通知
                        self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("ToggleCellularDataSlotNotifications", comment: ""))
                        // 切换网络类型的通知
                        self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("ToggleNetworkTypeNotifications", comment: ""))
                        self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("UseCriticalNotifications", comment: ""))
                        self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("SendNotifications", comment: ""))
                        self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("GoToNotificationSettings", comment: ""))
                    }
                case .denied:
                    self.tableCellList[MainViewController.notificationsAtSection].append(NSLocalizedString("GoToNotificationSettings", comment: ""))
                    if SettingsUtils.instance.getEnableNotifications() { // 如果用户去设置里给通知关闭了，那开关也给关闭
                        SettingsUtils.instance.setEnableNotifications(enable: false)
                    }
                case .notDetermined:
                    break
                @unknown default:
                    break
                }

                self.tableView.reloadSections([MainViewController.notificationsAtSection], with: .none)
            }
        }
    }
    
    // 发送通知
    private func onClickSendNotification() {
        
        if !SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() && !SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() {
            // 没有开启任何通知，发出提示
            UIUtils.showAlert(message: NSLocalizedString("NoNotificationEnabledMessage", comment: ""), in: self)
            return
        }
        // 显示提示
        UIUtils.showAlert(message: NSLocalizedString("SendNotificationMessage", comment: "发送通知成功"), in: self)
        // 发送通知
        NotificationController.instance.sendNotifications(silentNotifications: false)
        
    }
    
    /// 跳转到通知设置
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

