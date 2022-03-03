//
//  CSContractConfig.swift
//  ConsensusStorage
//
//  Created by Apple on 2021/5/24.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import BigInt
import HandyJSON

@objcMembers public class CSContractConfig: HandyJSON {
    
    /// privateKey
    @objc dynamic var privateKey: String?
    
    /// 发送数量
    @objc dynamic var amount: String?
    
    /// 合约地址
    @objc dynamic var contractAddress: String?
    
    /// 发送地址
    @objc dynamic var from: String?
    
    /// 接收地址
    @objc dynamic var to: String?
    
    /// gas费用 / automatic
    @objc var gasPrice: String?
    
    /// gas单位 / automatic
    @objc var gasLimit: String?
    
    /// abi文件类型（调用合约方法前必需设置）
    var abiType: CSContractAbiType = .factory
    
    /// 代币符号
    @objc var symbol: String = ""
    
    /// 授权数量
    @objc var approveAmount: String?

    /// 是否显示合约调用Error Message
    @objc var isShowErrMsg: Bool = true
    
    
    public required init() { }
}


