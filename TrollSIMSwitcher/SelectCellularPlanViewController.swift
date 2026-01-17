import Foundation
import UIKit

class SelectCellularPlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView = UITableView()
    
    private var cellularPlanItems: [CTCellularPlanItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        navigationItem.title = NSLocalizedString("SelectCellularPlan", comment: "")
        
        // 获取设备的蜂窝数据套餐卡
        cellularPlanItems = CoreTelephonyController.instance.getCellularPlans()
        
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
        
    }
    
    // MARK: - 设置总分组数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - 设置每个分组的Cell数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellularPlanItems.count
    }
    
    // MARK: - 设置每个分组的顶部标题
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    // MARK: - 设置每个分组的底部标题 可以为分组设置尾部文本，如果没有尾部可以返回 nil
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return String.localizedStringWithFormat(NSLocalizedString("CellularPlanCount", comment: ""), cellularPlanItems.count)
    }
    
    // MARK: - 构造每个Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        let cellularPlan = cellularPlanItems[indexPath.row]
        
        cell.textLabel?.text = cellularPlan.label + " (" + cellularPlan.carrierName + ")"
        cell.textLabel?.numberOfLines = 0 // 允许换行
        
        cell.detailTextLabel?.text = cellularPlan.isSelected ? NSLocalizedString("TurnOn", comment: "") : NSLocalizedString("TurnOff", comment: "") // 显示当前的卡是否启动
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 15)
        
        if cellularPlan.identifier == SettingsUtils.instance.getSelectCellularPlan1() { // 设置是否选中当前的cell
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Cell的点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        // 点击cell后就设置数据卡
        SettingsUtils.instance.setSelectCellularPlan1(planID: cellularPlanItems[indexPath.row].identifier)
        tableView.reloadData()
        // 切换设置后告诉主界面刷新下整个数据集
        NotificationCenter.default.post(name: Notification.Name("CoreTelephonyUpdated"), object: nil)
    }
}
