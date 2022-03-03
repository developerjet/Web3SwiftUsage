//
//  ViewController.swift
//  Web3SwiftUtils
//
//  Created by codertj on 2022/3/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func callContract(_ sender: UIButton) {
        
        let config = CSContractConfig()
        config.abiType = .erc20;
        config.privateKey = "your privateKey"
        config.from = "your walletAddress";
        config.approveAmount = "1000000000000";
        config.contractAddress = "contract address"
        config.symbol = "token symbol"
        
        // 代币授权
        CSContractManager.shared.callContract(method: "approve", params: [], config: config) { result in
            if (result.transHash.length > 0 && result.callData.count > 0) {
                print("Token approve success")
            }else {
                print("Token approve fail")
            }
        }
    }
}

