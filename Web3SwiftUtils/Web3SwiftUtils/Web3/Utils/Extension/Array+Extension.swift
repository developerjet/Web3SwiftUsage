//
//  Array+Extension.swift
//  ConsensusStorage
//
//  Created by Apple on 2021/8/3.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

extension Array {
    
    subscript (safe index:Int) -> Element? {
        return (0..<count).contains(index) ? self[index] : nil
    }
    
    func toJSONString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        let json = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return json! as String
    }
    
    func toData() -> Data {
        let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted)
        return data!
    }
    
}

extension Array where Element: Hashable {
    
    /// 保留顺序去重
    var unique:[Element] {
        var uniq = Set<Element>()
        uniq.reserveCapacity(self.count)
        return self.filter {
            return uniq.insert($0).inserted
        }
    }
}

extension Array {
    
    /// 检测数组中是否有指定的元素
    /// - Parameters:
    ///   - item: 需要检测的元素
    /// - Returns: 检测结果（true，false）
    func exists<T: Equatable>(item: T) -> Bool {
        var index: Int = 0
        var found = false
        
        while (index < self.count && found == false)
        {
            if item == self[index] as! T
            {
                found = true
            }
            else
            {
                index = index + 1
            }
        }
        
        if found {
            return true
        } else {
            return false
        }
    }
    
    
    /// 检测数组中指定元素所在的索引
    /// - Parameters:
    ///   - item: 需要检测的元素
    /// - Returns: 元素所在的索引
    func find<T: Equatable>(item: T) -> Int? {
        var index: Int = 0
        var found = false
        
        while (index < self.count && found == false)
        {
            if item == self[index] as! T
            {
                found = true
            }
            else
            {
                index = index + 1
            }
        }
        
        if found {
            return index
        }else {
            return nil
        }
    }
}
