import Foundation

// 每一个item的具体数据模型
class InfoItem {
    
    let id: Int                // id
    var text: String           // 文本
    var detailText: String?    // 副文本
    var hintText: String?      // 说明文本
    var enabled: Bool          // 允许点击这个item
    var selected: Bool         // 已选择/已开启
    
    init(id: Int, text: String, detailText: String? = nil, hintText: String? = nil, enabled: Bool = false, selected: Bool = false) {
        self.id = id
        self.text = text
        self.detailText = detailText
        self.hintText = hintText
        self.enabled = enabled
        self.selected = selected
    }
}
