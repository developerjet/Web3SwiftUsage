//
//  CSContractNetworkConfig.swift
//  ConsensusStorage
//
//  Created by Apple on 2021/9/9.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import HandyJSON

public class CSContractNetConfig: HandyJSON {
    
    public required init() { }
    
    /// 智能合约网络ip
    var ipUrl: String = ""
    
    /// 智能合约网络类型
    var netType: CSContractChainType = .binance
    
    /// 交易员地址
    var traderAddress: String = ""
    
    /// 工厂合约地址
    var factoryAddress: String = ""
    
    // luca代币合约地址
    var lucaAddress: String = ""
    
    
    init(ipUrl: String, netType: CSContractChainType, traderAddress: String, factoryAddress: String, lucaAddress: String) {
        
        self.ipUrl = ipUrl
        self.netType = netType
        self.traderAddress = traderAddress
        self.factoryAddress = factoryAddress
        self.lucaAddress = lucaAddress
    }
}
