//
//  CSSocialTokenModel.swift
//  ConsensusStorage
//
//  Created by Apple on 2021/6/1.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import web3swift

@objcMembers public class  CSSocialTokenModel: NSObject {
    
    /// 代币名称
    @objc dynamic var name: String = ""
    
    /// 代币符号
    @objc dynamic var symbol: String = ""
    
    /// 代币精度
    @objc dynamic var decimals: String = ""
    
    /// 代币精度
    @objc dynamic var balance: String = ""
    
    override init() { }
}
