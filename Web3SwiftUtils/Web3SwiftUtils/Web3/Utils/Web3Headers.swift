//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2022/3/3.
//

import Foundation

// MARK: - Type Service

public enum CSContractAbiType {
    case erc20
    case factory
    case link
    case luca
    case pledge
    case incentive
    case erc20Token
}

public enum CSEnvironmentType: Int {
    case dev = 0
    case pro = 1
}

public enum CSContractChainType: Int {
    case binance = 0
    case polygon = 1
}


// MARK: - Gas

let kBaseGasLimit = "800000"
let kBaseGasLimit21 = "21000"
let kBaseGasLimit10 = "100000"
let kBaseGasLimit80 = "800000"
let kBaseGasLimit43 = "4300000"

let kBaseGweiUnit = "1000000000"
let kCurrencyBigUInt = "1000000000000000000"


// MARK: - UserDefaults

let kWeb3NetworkTypeKey = "kWeb3NetworkTypeKey"
