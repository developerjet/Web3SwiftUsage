//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

//MARK:- 常用正则枚举
enum Validate {
    
    case isNum(_: String)
    case email(_: String)
    case phoneNum(_: String)
    case carNum(_: String)
    case username(_: String)
    case password(_: String)
    case nickname(_: String)
    case URL(_: String)
    case IP(_: String)
    case decimal(_: String, count: Int = 8)
    case googleCode(_: String)
    case bankCard(_: String)
    
    case EosAccountName(_: String)
    
    var isValid: Bool {
        
        var predicateStr: String!
        var currObject: String!
        
        switch self {
        case .isNum(let str):
            predicateStr = "[0-9]*"
            currObject = str
        case .email(let str):
            predicateStr = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
            currObject = str
        case .phoneNum(let str):
            predicateStr = "^((13[0-9])|(15[0,0-9])|(17[0,0-9])|(18[0,0-9]))\\d{8}$"
            currObject = str
        case .carNum(let str):
            predicateStr = "^[A-Za-z]{1}[A-Za-z_0-9]{5}$"
            currObject = str
        case .username(let str):
            predicateStr = "^[A-Za-z0-9]{6,20}+$"
            currObject = str
        case .password(let str):
            predicateStr = "^(?=.*[a-zA-Z])(?=.*\\d)[A-Za-z\\d_\\-.,~+=@$!#%*?&()]{8,20}$"
            currObject = str
        case .nickname(let str):
            predicateStr = "^[\\u4e00-\\u9fa5]{1,10}$"
            currObject = str
        case .URL(let str):
            predicateStr = "(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]"
            currObject = str
        case .IP(let str):
            predicateStr = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
            currObject = str
        case .decimal(let str, let count):
            predicateStr = String(format: "^[0-9]*((\\.|,)[0-9]{0,%d})?$", count)
            currObject = str
        case .EosAccountName(let str):
            predicateStr = "^[1-5a-z.]{1,12}$"
            currObject = str
        case .googleCode(let str):
            predicateStr = "^\\d{6}$"
            currObject = str
        case .bankCard(let str):
            predicateStr = "^([0-9]{16}|[0-9]{19}|[0-9]{17}|[0-9]{18}|[0-9]{20}|[0-9]{21})$"
            currObject = str
        }
        
        let predicate =  NSPredicate(format: "SELF MATCHES %@" ,predicateStr)
        return predicate.evaluate(with: currObject)
    }
}
