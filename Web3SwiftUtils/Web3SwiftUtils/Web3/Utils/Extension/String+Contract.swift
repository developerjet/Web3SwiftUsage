//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import web3swift

extension String {
    
    /// 获取链上Tx日志地址
    static func reptLogHandlerAddress(logs: [EventLog], offsetBy: Int = 64) -> String {
        var hashAddress: String = ""
        guard let firstLog = logs.first else {
            return hashAddress
        }
        
        /// HexFilter
        let hexFilter = "000000000000000000000000"
        let dataHex = firstLog.data.toHexString()
        let prefixHex = String(dataHex.prefix(offsetBy))
        print("prefixHex：\(prefixHex)")
        
        if prefixHex.hasPrefix(hexFilter) {
            let hash = prefixHex.replacingOccurrences(of: hexFilter, with: "")
            if hash.count > 0 {
                hashAddress = "0x" + hash
            }
            print("CreateLink hexAddress：\(hashAddress)")
        }
        
        return hashAddress
    }
    
    /// 获取链上Tx处理状态
    static func reptLogHandlerStatus(logs: [EventLog], offsetBy: Int = 64) -> Bool {
        var status: Bool = false
        guard let lastLog = logs.last else {
            return status
        }
        
        let dataHex = lastLog.data.toHexString()
        let suffixHex = String(dataHex.suffix(offsetBy))
        print("suffixHex：\(suffixHex)")
        
        status = suffixHex.boolValue
        print("HandlerLink status：\(suffixHex.boolValue)")
        
        return status
    }
    
    /// 引入智能合约ABI
    static func fileContractABI(resName: String) -> String {
        let filePath = Bundle.main.path(forResource: resName, ofType: "json")
        
        guard let abiString = try? NSString(contentsOfFile: filePath!, encoding: String.Encoding.utf8.rawValue) as String else {
            return Web3.Utils.erc20ABI
        }
        
        return abiString
    }
    
}


// MARK: - URL
public protocol URLConvertibleProtocol {
    var URLValue: URL? { get }
    var URLStringValue: String { get }
}

extension String: URLConvertibleProtocol {
    ///String转换成URL
    public var URLValue: URL? {
        if let URL = URL(string: self) {
            return URL
        }
        let set = CharacterSet()
            .union(.urlHostAllowed)
            .union(.urlPathAllowed)
            .union(.urlQueryAllowed)
            .union(.urlFragmentAllowed)
        return self.addingPercentEncoding(withAllowedCharacters: set).flatMap { URL(string: $0) }
    }
    public var URLStringValue: String {
        return self
    }
    
    func paramInUrl(for key: String) -> String? {
        
        var urlStr = self
        if !self.hasPrefix("http") {
            urlStr = String(format: "https://%@", self)
        }
        guard let url = URLComponents(string: urlStr) else { return nil }
        return url.queryItems?.first(where: { $0.name == key })?.value
    }
}


extension String {
    public var length: Int {
        ///更改成其他的影响含有emoji协议的签名
        return self.utf16.count
    }
    public var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    public var intValue: Int32 {
        return (self as NSString).intValue
    }
    public var floatValue: Float {
        return (self as NSString).floatValue
    }
    public var integerValue: Int {
        return (self as NSString).integerValue
    }
    public var longLongValue: Int64 {
        return (self as NSString).longLongValue
    }
    public var boolValue: Bool {
        return (self as NSString).boolValue
    }
}

// MARK: - Tool
extension String {
    
    public var isNotEmpty: Bool {
        return !isEmpty
    }
    
    var trim: String {
        if self.isNotEmpty {
            return self.trimmingCharacters(in: CharacterSet.whitespaces)
        }else{
            return ""
        }
    }
}



