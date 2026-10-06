import Foundation

class InfoItemGroupList {
    
    private(set) var groups: [InfoItemGroup]
    
    init() {
        self.groups = []
    }
    
    init(_ groups: [InfoItemGroup] = []) {
        self.groups = groups
    }
    
    // 添加Group
    func append(_ group: InfoItemGroup) {
        groups.append(group)
    }
    
    // 添加Group
    func addGroup(_ group: InfoItemGroup) {
        self.append(group)
    }
    
    // 在指定section添加Group
    func addGroup(_ group: InfoItemGroup, at section: Int) {
        if section >= 0 && section <= groups.count {
            groups.insert(group, at: section)
        } else {
            groups.append(group)
        }
    }
    
    // 在指定Group后添加Group
    func addGroup(_ group: InfoItemGroup, afterID targetID: Int) {
        // 如果已存在相同ID则不添加
        if groups.contains(where: { $0.id == group.id }) {
            return
        }
        
        if let index = groups.firstIndex(where: { $0.id == targetID }) {
            groups.insert(group, at: index + 1)
        } else {
            groups.append(group)
        }
    }
    
    // 在指定Group前添加Group
    func addGroup(_ group: InfoItemGroup, beforeID targetID: Int) {
        // 如果已存在相同ID则不添加
        if groups.contains(where: { $0.id == group.id }) {
            return
        }
        
        if let index = groups.firstIndex(where: { $0.id == targetID }) {
            groups.insert(group, at: index)
        } else {
            groups.append(group)
        }
    }
    
    // 添加多个Group
    func addGroups(_ newGroups: [InfoItemGroup]) {
        groups.append(contentsOf: newGroups)
    }
    
    // 根据ID获取Group
    func getGroup(withID id: Int) -> InfoItemGroup? {
        return groups.first { $0.id == id }
    }
    
    // 根据ID获取Group所在的section
    func getSection(ofGroupID id: Int) -> Int? {
        return groups.firstIndex { $0.id == id }
    }
    
    // 根据section获取Group
    func getGroup(at section: Int) -> InfoItemGroup? {
        guard groups.indices.contains(section) else {
            return nil
        }
        
        return groups[section]
    }
    
    // 更新Group并返回当前section
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func updateGroup(_ newGroup: InfoItemGroup) -> Int? {
        guard let index = getSection(ofGroupID: newGroup.id) else {
            return nil
        }
        
        groups[index] = newGroup
        return index
    }
    
    // 根据ID更新Group
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func updateGroup(withID id: Int, _ updateGroup: InfoItemGroup) -> Int? {
        guard let index = getSection(ofGroupID: id) else {
            return nil
        }
        
        groups[index] = updateGroup
        return index
    }
    
    // 根据ID更新Group
    @discardableResult // 这个方法有返回值，但调用者可以选择不使用这个返回值，编译器不要警告
    func updateGroup(withID id: Int, _ update: (InfoItemGroup) -> Void) -> Int? {
        guard let index = getSection(ofGroupID: id) else {
            return nil
        }
        
        update(groups[index])
        return index
    }
    
    // 删除指定ID的Group并返回原section
    @discardableResult
    func removeGroup(withID id: Int) -> Int? {
        guard let index = getSection(ofGroupID: id) else {
            return nil
        }
        
        groups.remove(at: index)
        return index
    }
    
    // 清空所有Group
    func clearGroups() {
        groups.removeAll()
    }
}
