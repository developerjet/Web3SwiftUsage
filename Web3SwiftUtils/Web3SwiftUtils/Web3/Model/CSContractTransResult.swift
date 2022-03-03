//
//  CSContractTransResult.swift
//  ConsensusStorage
//
//  Created by Apple on 2021/5/24.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

@objcMembers public class CSContractTransResult: NSObject {
    
    @objc dynamic var transHash: String = ""
    @objc dynamic var transDesc: String = ""
    @objc dynamic var callData: [String: Any] = [:]
    @objc dynamic var callStatus: Bool = false
    @objc dynamic var linkAddress: String = ""
    @objc dynamic var approvedAmount: String = "0"
    
    override init() { }
}
