//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    
    var toJSONString: String? {
        
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }
        
        return prettyPrintedString
    }

    var mutableToJSON: AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: .mutableContainers) as AnyObject
        } catch {
            print(error)
        }
        return nil
    }
}


extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}
