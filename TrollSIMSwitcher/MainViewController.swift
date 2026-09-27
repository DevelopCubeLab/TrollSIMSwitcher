import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let versionCode = "1.3"
    
    private var tableView = UITableView()
    
    private var tableCellList: [InfoItemGroup] = []

    private static let notificationsAtSection = 6
    
    private var SIMSlotList: [SIMSlot] = []
    
    // 是否长按展开了菜单
    private var isContextMenuVisible = false
    
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
            if !self.isContextMenuVisible { // 只有菜单没有展开的时候才刷新Cell
                self.tableView.reloadData()
            }
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
        SIMSlotList = CellularController.instance.getAllEnabledSlots()
        // 清空列表信息
        tableCellList = []
        // 蜂窝网络分组
        let cellularDataInfoGroup = InfoItemGroup(id: HomeItemGroupID.cellularDataGroup, titleText: NSLocalizedString("CellularData", comment: ""))
        // 网络类型分组
        let networkTypeInfoGroup = InfoItemGroup(id: HomeItemGroupID.networkTypeGroup, titleText: NSLocalizedString("NetworkType", comment: ""))
        for slot in SIMSlotList {
            // 将当前的蜂窝数据选项加入信息组
            cellularDataInfoGroup.addItem(InfoItem(id: slot.slot, text: "", selected: slot.isDataPreferred))
            if slot.isDataPreferred { // 判断是否是首选蜂窝数据卡
                // 获取首选蜂窝数据卡的网络类型
                if let rates = slot.supportedRates?.rates {
                    for case let rate as Int in rates {
                        // 把网络类型的选项加入信息组
                        networkTypeInfoGroup.addItem(InfoItem(id: rate, text: CellularUtils.getRateText(rate: rate), selected: rate == slot.currentRate))
                    }
                }
            }
        }
        tableCellList.append(cellularDataInfoGroup)
        tableCellList.append(networkTypeInfoGroup)
        // 蜂窝数据卡分组
        let cellularPlanInfoGroup = InfoItemGroup(id: HomeItemGroupID.cellularPlanGroup, titleText: NSLocalizedString("CellularPlan", comment: ""))
        cellularPlanInfoGroup.addItem(InfoItem(id: HomeItemID.cellularPlan, text: NSLocalizedString("SelectCellularPlan", comment: "")))
        cellularPlanInfoGroup.addItem(InfoItem(id: HomeItemID.selectCellularPlan, text: NSLocalizedString("SelectCellularPlan", comment: "")))
        tableCellList.append(cellularPlanInfoGroup)
        // 维护分组
        let maintenanceInfoGroup = InfoItemGroup(id: HomeItemGroupID.maintenanceGroup, titleText: NSLocalizedString("Maintenance", comment: ""), items: [
            InfoItem(id: HomeItemID.refreshCellularConnection, text: NSLocalizedString("RefreshCellularConnection", comment: "")),
            InfoItem(id: HomeItemID.rebootCommCenter, text: NSLocalizedString("RebootCommCenter", comment: ""))
        ])
        tableCellList.append(maintenanceInfoGroup)
        
        // 选项分组
        let optionsInfoGroup = InfoItemGroup(id: HomeItemGroupID.optionsGroup, titleText: NSLocalizedString("Options", comment: ""), items: [
            InfoItem(id: SettingsSwitchViewTag.EnableCompatibilitySwitchMode, text: NSLocalizedString("CompatibilitySwitchMode", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.ShowSlotLabel, text: NSLocalizedString("ShowSlotLabel", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.ShowOperatorName, text: NSLocalizedString("ShowOperatorName", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.ShowPhoneNumber, text: NSLocalizedString("ShowPhoneNumber", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.ShowAlertWhenTurningOffCellularPlan, text: NSLocalizedString("ShowAlertWhenTurningOffCellularPlan", comment: ""))
        ], footerText: String.localizedStringWithFormat(NSLocalizedString("EnableCompatibilityModeMessage", comment: ""), NSLocalizedString("CompatibilitySwitchMode", comment: "")))
        tableCellList.append(optionsInfoGroup)
        
        // 快捷切换分组
        let shortcutsInfoGroup = InfoItemGroup(id: HomeItemGroupID.shortcutsGroup, titleText: NSLocalizedString("Shortcuts", comment: ""), items: [
            InfoItem(id: SettingsSwitchViewTag.EnableHomeScreenQuickActions, text: NSLocalizedString("HomeScreenQuickActions", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.ExitAfterQuickSwitching, text: NSLocalizedString("ExitAfterQuickSwitching", comment: ""))
        ], footerText: nil)
        tableCellList.append(shortcutsInfoGroup)
        
        // 通知分组
        let notificationsInfoGroup = InfoItemGroup(id: HomeItemGroupID.notificationsGroup, titleText: NSLocalizedString("Notifications", comment: ""), items: [
            InfoItem(id: SettingsSwitchViewTag.EnableNotifications, text: NSLocalizedString("Enable", comment: ""))
        ], footerText: NSLocalizedString("NotificationsFooterMessage", comment: ""))
        
        if SettingsUtils.instance.getEnableNotifications() { // 如果开启了通知就直接添加上通知选项
            notificationsInfoGroup.addItems(self.getNotificationItems())
        }
        
        tableCellList.append(notificationsInfoGroup)
        
        let aboutInfoGroup = InfoItemGroup(id: HomeItemGroupID.aboutGroup, titleText: NSLocalizedString("About", comment: ""), items: [
            InfoItem(id: HomeItemID.versionCode, text: NSLocalizedString("Version", comment: "")),
            InfoItem(id: HomeItemID.githubLink, text: "GitHub"),
            InfoItem(id: HomeItemID.havocLink, text: "Havoc")
        ])
        
        tableCellList.append(aboutInfoGroup)
        // 刷新通知分组
        updateNotificationsCell()
        
        // 设置快捷方式
        SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
    }

    // MARK: - 设置总分组数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableCellList.count
    }
    
    // MARK: - 设置每个分组的Cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellList[section].items.count
    }
    
    // MARK: - 设置每个分组的顶部标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableCellList[section].titleText
    }
    
    // MARK: - 设置每个分组的底部标题 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableCellList[section].footerText
    }
    
    // MARK: - 构造每个Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        // 设置文本
        cell.textLabel?.text = tableCellList[indexPath.section].items[indexPath.row].text
        cell.textLabel?.numberOfLines = 0 // 允许换行
        
        // 获取分组ID
        let groupID = tableCellList[indexPath.section].id
        // 获取item
        let item = tableCellList[indexPath.section].items[indexPath.row]
        
        if groupID == HomeItemGroupID.cellularDataGroup { // 卡槽选择
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
            if item.selected { // 给首选数据卡画上对勾
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if groupID == HomeItemGroupID.networkTypeGroup { // 网络类型选择
            if item.selected { // 给首选网络类型画上对勾
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else if groupID == HomeItemGroupID.cellularPlanGroup { // 开关某一张卡
            if item.id == HomeItemID.cellularPlan { // 开关
                if SettingsUtils.instance.getSelectCellularPlan1().isEmpty { // 当前没有去选择数据套餐
                    cell.textLabel?.text = NSLocalizedString("NoCellularPlanSelected", comment: "")
                    // 禁用选择
                    cell.selectionStyle = .none
                    cell.isUserInteractionEnabled = false
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                } else {
                    // 设置开关卡槽
                    if let cellularPlan = CellularController.instance.getCellularPlan(planID: SettingsUtils.instance.getSelectCellularPlan1()) {
                        let cellularPlanText: String
                        if SettingsUtils.instance.getShowSlotLabel() { // 是否显示卡标签
                            cellularPlanText = cellularPlan.label
                        } else {
                            cellularPlanText = cellularPlan.carrierName == "" ? NSLocalizedString("UnknownCarrier", comment: "") : cellularPlan.carrierName
                        }
                        if cellularPlan.isSelected {
                            cell.textLabel?.text = String.localizedStringWithFormat(NSLocalizedString("TurnOffCellularPlan", comment: ""), cellularPlanText)
                            cell.textLabel?.textColor = .systemRed //文本变成红色
                        } else {
                            cell.textLabel?.text = String.localizedStringWithFormat(NSLocalizedString("TurnOnCellularPlan", comment: ""), cellularPlanText)
                            cell.textLabel?.textColor = .systemBlue //文本变成蓝色
                        }
                    } else { // 比如用户选择了某张卡，但是这张卡被移除了
                        cell.textLabel?.text = NSLocalizedString("NoCellularPlanFound", comment: "")
                        // 删除失效配置
                        SettingsUtils.instance.removeSelectCellularPlan1()
                        // 禁用选择
                        cell.selectionStyle = .none
                        cell.isUserInteractionEnabled = false
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                    }
                }
            } else {
                cell.accessoryType = .disclosureIndicator
            }
        } else if groupID == HomeItemGroupID.maintenanceGroup { // 维护
            cell.textLabel?.textColor = .systemBlue // 文本设置成蓝色
        } else if groupID == HomeItemGroupID.optionsGroup || groupID == HomeItemGroupID.shortcutsGroup || groupID == HomeItemGroupID.notificationsGroup { // 选项 快捷方式 通知分组
            
            if item.id == HomeItemID.sendNotification || item.id == HomeItemID.goToNotificationSettings { // 两个特例 发送通知 和 跳转到通知设置
                cell.textLabel?.textColor = .systemBlue // 文本设置成蓝色
                return cell
            }
            
            let switchView = UISwitch(frame: .zero)
            switchView.tag = item.id // 设置识别id
            switch item.id {
            case SettingsSwitchViewTag.EnableCompatibilitySwitchMode:
                switchView.isOn = SettingsUtils.instance.getEnableCompatibilitySwitchMode() // 从配置文件中获取状态
                if SIMSlotList.count < 1 { // 只有单卡的情况
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
            case SettingsSwitchViewTag.ShowSlotLabel:
                if UIDevice.current.userInterfaceIdiom == .pad { // 这里其实可以被插件绕过，不过其实也无所谓
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
                switchView.isOn = SettingsUtils.instance.getShowSlotLabel() // 从配置文件中获取状态
            case SettingsSwitchViewTag.ShowOperatorName:
                switchView.isOn = SettingsUtils.instance.getShowOperatorName() // 从配置文件中获取状态
            case SettingsSwitchViewTag.ShowPhoneNumber:
                switchView.isOn = SettingsUtils.instance.getShowPhoneNumber() // 从配置文件中获取状态
            case SettingsSwitchViewTag.ShowAlertWhenTurningOffCellularPlan:
                switchView.isOn = SettingsUtils.instance.getShowAlertWhenTurningOffCellularPlan() // 从配置文件中获取状态
            case SettingsSwitchViewTag.EnableHomeScreenQuickActions:
                switchView.isOn = SettingsUtils.instance.getEnableHomeScreenQuickActions() // 从配置文件中获取状态
            case SettingsSwitchViewTag.ExitAfterQuickSwitching:
                switchView.isOn = SettingsUtils.instance.getExitAfterQuickSwitching() // 从配置文件中获取状态
            case SettingsSwitchViewTag.EnableNotifications:
                switchView.isOn = SettingsUtils.instance.getEnableNotifications() // 从配置文件中获取状态
            case SettingsSwitchViewTag.EnableToggleCellularDataSlotNotifications:
                switchView.isOn = SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() // 从配置文件中获取状态
                if SIMSlotList.count < 1 { // 只有单卡的情况
                    cell.textLabel?.textColor = .lightGray //文本变成灰色
                    switchView.isEnabled = false // 禁用开关
                }
            case SettingsSwitchViewTag.EnableToggleNetworkTypeNotifications:
                switchView.isOn = SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() // 从配置文件中获取状态
                let preferred = SIMSlotList.first(where: { $0.isDataPreferred })
                if preferred != nil || SIMSlotList.isEmpty { // 获取首选数据卡
                    if preferred?.supportedRates?.rates.count ?? 0 < 2 { // 少于两个网络类型则不支持这组通知，没有什么意义
                        cell.textLabel?.textColor = .lightGray //文本变成灰色
                        switchView.isEnabled = false // 禁用开关
                    }
                }
            case SettingsSwitchViewTag.EnableToggleCellularPlanNotifications:
                switchView.isOn = SettingsUtils.instance.getEnableToggleCellularPlanNotifications() // 从配置文件中获取状态
            case SettingsSwitchViewTag.UseCriticalNotifications:
                switchView.isOn = SettingsUtils.instance.getUseCriticalNotifications() // 从配置文件中获取状态
            default:
                break
            }
            // 开光状态改变的回调
            switchView.addAction(UIAction { [weak self] action in
                self?.onSwitchChanged(action.sender as! UISwitch)
            }, for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            
        } else if groupID == HomeItemGroupID.aboutGroup { // 关于
            if item.id == HomeItemID.versionCode {
                cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
                cell.textLabel?.text = tableCellList[indexPath.section].items[indexPath.row].text
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? NSLocalizedString("Unknown", comment: "未知")
                if version != MainViewController.versionCode { // 判断版本号是不是有人篡改
                    cell.detailTextLabel?.text = MainViewController.versionCode
                } else {
                    cell.detailTextLabel?.text = version
                }
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default // 启用选中效果
            }
        }
        
        return cell
    }
    
    // MARK: - Cell的点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 获取分组ID
        let groupID = tableCellList[indexPath.section].id
        // 获取item
        let item = tableCellList[indexPath.section].items[indexPath.row]
        
        if groupID == HomeItemGroupID.cellularDataGroup { // 切换数据流量卡
            if CellularController.instance.setDataSlot(SIMSlot: SIMSlotList[indexPath.row]) {
                // 执行点击后的操作
                _ = ExtraActionController.instance.performExtraActions(iccid: SIMSlotList[indexPath.row].ICCID)
                // 补发通知
                NotificationController.instance.sendNotifications(silentNotifications: true, groupIdentifier: NotificationController.switchSlotGroupIdentifier, switchedSlotID: SIMSlotList[indexPath.row].slot)
            }
        } else if groupID == HomeItemGroupID.networkTypeGroup { // 切换网络类型
            
            if let preferred = SIMSlotList.first(where: { $0.isDataPreferred }) { // 获取首选数据卡
                let selectRate = preferred.supportedRates?.rates[indexPath.row]
                if CellularController.instance.setDataRate(SIMSlot: SIMSlotList.first(where: { $0.isDataPreferred })!, selectRate: selectRate as! Int64) {
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

        } else if groupID == HomeItemGroupID.cellularPlanGroup { // 管理蜂窝数据卡
            if item.id == HomeItemID.cellularPlan { // 关闭或者打开某个卡
                if SettingsUtils.instance.getShowAlertWhenTurningOffCellularPlan() {
                    if let cellularPlan = CellularController.instance.getCellularPlan(planID: SettingsUtils.instance.getSelectCellularPlan1()) {
                        if cellularPlan.isSelected { // 禁用某张卡
                            
                            // 获取卡名称
                            let cellularPlanText: String
                            if SettingsUtils.instance.getShowSlotLabel() { // 是否显示卡标签
                                cellularPlanText = cellularPlan.label
                            } else {
                                cellularPlanText = cellularPlan.carrierName == "" ? NSLocalizedString("UnknownCarrier", comment: "") : cellularPlan.carrierName
                            }
                            
                            // 设置一个弹窗
                            let alert = UIAlertController(
                                title: NSLocalizedString("Alert", comment: ""),
                                message: String.localizedStringWithFormat(NSLocalizedString("TurnOffCellularPlanAlertMessage", comment: ""), cellularPlanText),
                                preferredStyle: .alert
                            )

                            // "确定" 按钮（红色，左边）
                            let deleteAction = UIAlertAction(title: NSLocalizedString("TurnOff", comment: ""), style: .destructive) { _ in
                                if CellularController.instance.setCellularPlanEnable(planID: cellularPlan.identifier, enable: false) {
                                    // 刷新当前的cell
                                    tableView.reloadSections(IndexSet(integer: 2), with: .none)
                                    // 补发普通通知
                                    NotificationController.instance.sendNotifications(silentNotifications: true)
                                }
                            }

                            // "取消" 按钮（蓝色，右边）
                            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

                            // 添加按钮，iOS 会自动按照规范排列
                            alert.addAction(deleteAction) // 红色
                            alert.addAction(cancelAction) // 蓝色

                            // 显示弹窗
                            present(alert, animated: true, completion: nil)
                            
                        } else { // 开启蜂窝数据卡不需要弹窗提醒
                            if CellularController.instance.setCellularPlanEnable(planID: cellularPlan.identifier, enable: true) {
                                // 刷新当前的cell
                                tableView.reloadSections(IndexSet(integer: 2), with: .none)
                                // 补发普通通知
                                NotificationController.instance.sendNotifications(silentNotifications: true)
                            }
                            
                        }
                    } else { // 设置了某个蜂窝数据套餐卡，但是删除了这张卡
                        // 那就恢复到默认设置
                        SettingsUtils.instance.removeSelectCellularPlan1()
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                } else { // 不弹出警告的时候直接切换
                    if CellularController.instance.toggleCellularPlanEnable(planID: SettingsUtils.instance.getSelectCellularPlan1()) {
                        // 刷新当前的cell
                        tableView.reloadSections(IndexSet(integer: 2), with: .none)
                        // 补发普通通知
                        NotificationController.instance.sendNotifications(silentNotifications: true)
                    }
                    
                }
                
            } else if item.id == HomeItemID.selectCellularPlan { // 打开卡槽设置
                self.navigationController!.pushViewController(SelectCellularPlanViewController(), animated: true)
            }
        } else if groupID == HomeItemGroupID.maintenanceGroup { // 维护
            if item.id == HomeItemID.refreshCellularConnection { // 刷新蜂窝网络信号
                refreshCellularConnection()
            } else if item.id == HomeItemID.rebootCommCenter { // 重启基带服务
                
                // 设置一个弹窗
                let alert = UIAlertController(
                    title: NSLocalizedString("Alert", comment: ""),
                    message: NSLocalizedString("RebootCommCenterMessage", comment: ""),
                    preferredStyle: .alert
                )

                // "确定" 按钮（红色，左边）
                let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .destructive) { _ in
                    let deviceController = DeviceController()
                    if deviceController.rebootCommCenter() {
                        UIUtils.showAlert(message: NSLocalizedString("WaitingForRefresh", comment: ""), in: self)
                    } else {
                        UIUtils.showAlert(message: NSLocalizedString("NoPermission", comment: ""), in: self)
                    }
                }

                // "取消" 按钮（蓝色，右边）
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

                // 添加按钮，iOS 会自动按照规范排列
                alert.addAction(confirmAction) // 红色
                alert.addAction(cancelAction) // 蓝色

                // 显示弹窗
                present(alert, animated: true, completion: nil)
            }
        } else if groupID == HomeItemGroupID.notificationsGroup {
            if item.id == HomeItemID.sendNotification { // 发送通知
                self.onClickSendNotification()
            } else if item.id == HomeItemID.goToNotificationSettings { // 跳转到通知设置
                self.onClickToNotificationSettings()
            }
        } else if groupID == HomeItemGroupID.aboutGroup { // 关于
            if item.id == HomeItemID.githubLink {
                if let url = URL(string: "https://github.com/DevelopCubeLab/TrollSIMSwitcher") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            } else if item.id == HomeItemID.havocLink {
                if let url = URL(string: "https://havoc.app/package/trollsimswitch") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    // MARK: - 长按 Cell 的菜单 (UIContextMenuConfiguration)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        if tableCellList[indexPath.section].id == HomeItemGroupID.cellularDataGroup {
            
            let iccid = SIMSlotList[indexPath.row].ICCID
            
            let currentAction = SettingsUtils.instance.getSwitchSlotExtraActions(iccid: iccid).first ?? .None
            
            let noneAction = UIAction(
                title: NSLocalizedString("None", comment: ""),
                image: nil,
                state: currentAction == .None ? .on : .off
            ) { _ in
                SettingsUtils.instance.setSwitchSlotExtraActions(
                    iccid: iccid,
                    actions: [.None]
                )
            }
            
            let turnOffWiFiAction = UIAction(
                title: NSLocalizedString("TurnOffWi-Fi", comment: ""),
                image: UIImage(systemName: "wifi.slash"),
                state: currentAction == .TurnOffWiFi ? .on : .off
            ) { _ in
                SettingsUtils.instance.setSwitchSlotExtraActions(
                    iccid: iccid,
                    actions: [.TurnOffWiFi]
                )
            }
            
            let turnOnWiFiAction = UIAction(
                title: NSLocalizedString("TurnOnWi-Fi", comment: ""),
                image: UIImage(systemName: "wifi"),
                state: currentAction == .TurnOnWiFi ? .on : .off
            ) { _ in
                SettingsUtils.instance.setSwitchSlotExtraActions(
                    iccid: iccid,
                    actions: [.TurnOnWiFi]
                )
            }
            
            let disableWiFiConnectAction = UIAction(
                title: NSLocalizedString("DisableWi-FiAuto-Join", comment: ""),
                image: UIImage(systemName: "wifi.slash"),
                state: currentAction == .DisableWiFiConnect ? .on : .off
            ) { _ in
                SettingsUtils.instance.setSwitchSlotExtraActions(
                    iccid: iccid,
                    actions: [.DisableWiFiConnect]
                )
            }
            
            let enableWiFiConnectAction = UIAction(
                title: NSLocalizedString("EnableWi-FiAuto-Join", comment: ""),
                image: UIImage(systemName: "wifi"),
                state: currentAction == .EnableWiFiConnect ? .on : .off
            ) { _ in
                SettingsUtils.instance.setSwitchSlotExtraActions(
                    iccid: iccid,
                    actions: [.EnableWiFiConnect]
                )
            }
            
            let menu = UIMenu(
                title: NSLocalizedString("AfterSwitching", comment: ""),
                children: [
                    UIMenu(
                        options: .displayInline,
                        children: [
                            noneAction
                        ]
                    ),
                    UIMenu(
                        options: .displayInline,
                        children: [
                            turnOffWiFiAction,
                            turnOnWiFiAction
                        ]
                    ),
                    UIMenu(
                        options: .displayInline,
                        children: [
                            disableWiFiConnectAction,
                            enableWiFiConnectAction
                        ]
                    )
                ]
            )
            
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                return menu
            }
        }
        
        return nil
    }
    
    // MARK: - 展开菜单前
    func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        isContextMenuVisible = true
    }

    // MARK: - 菜单关闭后
    func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        animator?.addCompletion { [weak self] in
            self?.isContextMenuVisible = false
            // 顺手刷新下
            tableView.reloadData()
        }
    }
    
    private func onSwitchChanged(_ sender: UISwitch) {
        switch sender.tag {
        case SettingsSwitchViewTag.EnableCompatibilitySwitchMode:
            SettingsUtils.instance.setEnableCompatibilitySwitchMode(enable: sender.isOn)
        case SettingsSwitchViewTag.ShowSlotLabel:
            SettingsUtils.instance.setShowSlotLabel(enable: sender.isOn)
            // 设置快捷方式
            SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
            // 补发普通通知
            NotificationController.instance.sendNotifications(silentNotifications: true)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
            tableView.reloadSections(IndexSet(integer: 2), with: .none)
        case SettingsSwitchViewTag.ShowOperatorName:
            SettingsUtils.instance.setShowOperatorName(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .none)
        case SettingsSwitchViewTag.ShowPhoneNumber:
            SettingsUtils.instance.setShowPhoneNumber(enable: sender.isOn)
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        case SettingsSwitchViewTag.ShowAlertWhenTurningOffCellularPlan:
            SettingsUtils.instance.setShowAlertWhenTurningOffCellularPlan(enable: sender.isOn)
        case SettingsSwitchViewTag.EnableHomeScreenQuickActions:
            SettingsUtils.instance.setEnableHomeScreenQuickActions(enable: sender.isOn)
            // 设置快捷方式
            SettingsUtils.instance.setHomeScreenQuickActions(application: UIApplication.shared)
        case SettingsSwitchViewTag.ExitAfterQuickSwitching:
            SettingsUtils.instance.setExitAfterQuickSwitching(enable: sender.isOn)
        case SettingsSwitchViewTag.EnableNotifications:
            if sender.isOn {
                // 判断通知权限
                NotificationController.instance.ensureAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .notDetermined:
                            sender.setOn(false, animated: true)
                            NotificationController.instance.requestAuthorization { granted in
                                DispatchQueue.main.async {
                                    if !granted {
                                        sender.setOn(false, animated: true)
                                        SettingsUtils.instance.setEnableNotifications(enable: false)
                                        UIUtils.showAlert(message: NSLocalizedString("NotificationsPermissionDenied", comment: "通知权限已拒绝"), in: self)
                                    } else {
                                        sender.setOn(true, animated: true)
                                        SettingsUtils.instance.setEnableNotifications(enable: true)
                                        // 发送通知
                                        NotificationController.instance.sendNotifications(silentNotifications: true)
                                    }
                                    self.updateNotificationsCell()
                                }
                            }
                            return

                        case .authorized, .provisional, .ephemeral:
                            SettingsUtils.instance.setEnableNotifications(enable: true)
                            sender.setOn(true, animated: true)
                            // 发送通知
                            NotificationController.instance.sendNotifications(silentNotifications: true)

                        case .denied:
                            UIUtils.showAlert(message: NSLocalizedString("NotificationsPermissionGoToSettings", comment: "通知权限已拒绝"), in: self)
                            sender.setOn(false, animated: true)

                        @unknown default:
                            sender.setOn(false, animated: true)
                        }

                        self.updateNotificationsCell()
                    }
                }
            } else {
                SettingsUtils.instance.setEnableNotifications(enable: false)
                NotificationController.instance.clearAllNotifications()
                updateNotificationsCell()
            }
        case SettingsSwitchViewTag.EnableToggleCellularDataSlotNotifications:
            SettingsUtils.instance.setEnableToggleCellularDataSlotNotifications(enable: sender.isOn)
            NotificationController.instance.sendNotifications(silentNotifications: true)
        case SettingsSwitchViewTag.EnableToggleNetworkTypeNotifications:
            SettingsUtils.instance.setEnableToggleNetworkTypeNotifications(enable: sender.isOn)
            NotificationController.instance.sendNotifications(silentNotifications: true)
        case SettingsSwitchViewTag.EnableToggleCellularPlanNotifications:
            SettingsUtils.instance.setEnableToggleCellularPlanNotifications(enable: sender.isOn)
            NotificationController.instance.sendNotifications(silentNotifications: true)
        case SettingsSwitchViewTag.UseCriticalNotifications:
            if sender.isOn {
                NotificationController.instance.requestAuthorization { _ in
                    NotificationController.instance.isCriticalNotificationEnabled { enabled in
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else {
                                return
                            }

                            if enabled {
                                SettingsUtils.instance.setUseCriticalNotifications(enable: true)
                                NotificationController.instance.sendNotifications(silentNotifications: true)
                            } else {
                                sender.setOn(false, animated: true)
                                SettingsUtils.instance.setUseCriticalNotifications(enable: false)
                                UIUtils.showAlert(message: NSLocalizedString("CriticalAlertMessage", comment: ""), in: self)
                            }
                        }
                    }
                }
            } else {
                SettingsUtils.instance.setUseCriticalNotifications(enable: false)
                NotificationController.instance.sendNotifications(silentNotifications: true)
            }
        default:
            return
        }
    }
    
    // 更新通知的cell
    private func updateNotificationsCell() {

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

                // 获取当前通知开关状态
                var enableNotifications = SettingsUtils.instance.getEnableNotifications()

                switch status {
                case .authorized, .provisional, .ephemeral:
                    break

                case .denied, .notDetermined:
                    if enableNotifications {
                        SettingsUtils.instance.setEnableNotifications(enable: false)
                        enableNotifications = false
                    }

                @unknown default:
                    break
                }

                // 从列表中找到通知设置分组
                let notificationsInfoGroup = self.tableCellList[MainViewController.notificationsAtSection]

                // 清空通知设置
                notificationsInfoGroup.clearItems()

                // 添加总开关
                notificationsInfoGroup.addItem(InfoItem(id: SettingsSwitchViewTag.EnableNotifications, text: NSLocalizedString("Enable", comment: "")))

                switch status {
                case .authorized, .provisional, .ephemeral:
                    if enableNotifications {
                        notificationsInfoGroup.addItems(self.getNotificationItems())
                    }

                case .denied:
                    notificationsInfoGroup.addItem(InfoItem(id: HomeItemID.goToNotificationSettings, text: NSLocalizedString("GoToNotificationSettings", comment: "")))

                case .notDetermined:
                    break

                @unknown default:
                    break
                }

                // 刷新通知设置分组
                self.tableView.reloadSections([MainViewController.notificationsAtSection], with: .none)
            }
        }
    }
    
    private func getNotificationItems() -> [InfoItem] {
        return [
            // 切换流量卡的通知
            InfoItem(id: SettingsSwitchViewTag.EnableToggleCellularDataSlotNotifications, text: NSLocalizedString("ToggleCellularDataSlotNotifications", comment: "")),
            // 切换网络类型的通知
            InfoItem(id: SettingsSwitchViewTag.EnableToggleNetworkTypeNotifications, text: NSLocalizedString("ToggleNetworkTypeNotifications", comment: "")),
            // 切换蜂窝数据卡的通知
            InfoItem(id: SettingsSwitchViewTag.EnableToggleCellularPlanNotifications, text: NSLocalizedString("ToggleCellularPlanNotifications", comment: "")),
            InfoItem(id: SettingsSwitchViewTag.UseCriticalNotifications, text: NSLocalizedString("UseCriticalNotifications", comment: "")),
            InfoItem(id: HomeItemID.sendNotification, text: NSLocalizedString("SendNotifications", comment: "")),
            InfoItem(id: HomeItemID.goToNotificationSettings, text: NSLocalizedString("GoToNotificationSettings", comment: ""))
        ]
    }

    /// 发送通知
    private func onClickSendNotification() {

        if !SettingsUtils.instance.getEnableToggleCellularDataSlotNotifications() && !SettingsUtils.instance.getEnableToggleNetworkTypeNotifications() && !SettingsUtils.instance.getEnableToggleCellularPlanNotifications() {
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
    
    /// 刷新蜂窝网络信号
    private func refreshCellularConnection() {
        // 设置一个弹窗
        let alert = UIAlertController(
            title: NSLocalizedString("Alert", comment: ""),
            message: NSLocalizedString("RefreshCellularConnectionMessage", comment: ""),
            preferredStyle: .alert
        )
        
        // "确定" 按钮
        let confirmAction = UIAlertAction(title: NSLocalizedString("Confirm", comment: ""), style: .default) { _ in
            if CellularController.instance.refreshCellularConnection() {
                UIUtils.showAlert(message: NSLocalizedString("WaitingForRefresh", comment: ""), in: self)
            } else { // 无权限
                UIUtils.showAlert(message: NSLocalizedString("NoPermission", comment: ""), in: self)
            }
        }

        // "取消" 按钮
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)

        // 添加按钮，iOS 会自动按照规范排列
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)

        // 显示弹窗
        present(alert, animated: true, completion: nil)
        
    }

}
