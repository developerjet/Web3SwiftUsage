//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import HandyJSON

enum CSContractCallType {
    case write
    case read
}

@objcMembers public class CSContractManager: NSObject {
    
    /// shared
    static let shared = CSContractManager()
    
    /// currentConfig
    var currentConfig: CSContractConfig?
    
    /// web3
    private var web3Manager: web3?

    /// default password
    private var password: String {
        return "web3swift"
    }
    
    /// default gweiUnit
    private var kBaseGweiUnit: String {
        return "1000000000"
    }
    
    /// environmentType
    private var environmentType: CSEnvironmentType {
        return .dev
    }
        
    /// network configs
    private var networkConfigs: [CSContractNetConfig] {
        
        if (self.environmentType == .pro) {
            return [
                // Binance Main Chain
                CSContractNetConfig(ipUrl: "https://bsc-dataseed.binance.org", netType: .binance, traderAddress: "", factoryAddress: "", lucaAddress: ""),
                // Polygon Main Chain
                CSContractNetConfig(ipUrl: "https://rpc.maticvigil.com", netType: .polygon, traderAddress: "", factoryAddress: "", lucaAddress: "")]
        }else {
            return [
                // Binance Test Chain
                CSContractNetConfig(ipUrl: "", netType: .binance, traderAddress: "", factoryAddress: "", lucaAddress: ""),
                // Polygon Test Chain
                CSContractNetConfig(ipUrl: "", netType: .polygon, traderAddress: "", factoryAddress: "", lucaAddress: "")]
        }
    }
    
    /// now contract network
    var network: CSContractNetConfig {
        return networkConfigs[self.networkIndex]
    }
    
    /// selected network  type
    var networkType: CSContractChainType {
        return network.netType
    }
    
    /// wallet Currency
    var walletCurrency: String {
        switch self.networkType {
        case .binance:
            return "BNB"
        default:
            return "Matic"
        }
    }
    
    /// network  selected index
    private var networkIndex: Int {
        guard let index = UserDefaults.standard.value(forKey: kWeb3NetworkTypeKey) as? Int else {
            return 0
        }
        return index
    }
    
    /// contractURL
    private var contractURL: String {
        return network.ipUrl
    }
    
    override init() { }
    
    // MARK: - Public
    
    /// callContract
    public func callContract(method: String, params: [AnyObject], config: CSContractConfig, callback: @escaping (CSContractTransResult)->Void) {
        currentConfig = config
        
        // 注意：需要设置ABI类型
        callContractService(config.abiType, methodName: method, callType: .write, params: params, config: config) { transResult in
            
            callback(transResult)
        }
    }
    
    
    /// 查询区块日志是否存在
    public func checkIsExistReceiptLogs(hash: String) -> Bool {
        
        if let response = self.getTransactionReceipt(hash: hash) {
            return response.logs.count > 0 ? true : false
        }else {
            print("First CheckReceiptAddress Failed")
            if let transResp = self.getTransactionReceipt(hash: hash) {
                return transResp.logs.count > 0 ? true : false
            }else {
                print("Again CheckReceiptAddress Failed")
                return false
            }
        }
    }
    
    public func checkReceiptAddress(hash: String) -> String? {
        
        if let response = self.getTransactionReceipt(hash: hash) {
            let address = String.reptLogHandlerAddress(logs: response.logs)
            return address
        }else {
            print("CheckReceiptAddress Failed")
            
            let response = self.getTransactionReceipt(hash: hash)
            let address = String.reptLogHandlerAddress(logs: response?.logs ?? [EventLog]())
            return address
        }
    }
    
    public func checkReceiptStatus(hash: String) -> Bool {
        
        if let response = self.getTransactionReceipt(hash: hash) {
            let status = String.reptLogHandlerStatus(logs: response.logs)
            return status
        }else {
            print("CheckReceiptStatus Failed")
            
            let response = self.getTransactionReceipt(hash: hash)
            let status = String.reptLogHandlerStatus(logs: response?.logs ?? [EventLog]())
            return status
        }
    }
    
    /// 进行ERC20代币授权
    /// - Parameters:
    ///   - config: 合约调用基础参数配置
    ///   - callback: 回调结果
    public func approve(config: CSContractConfig, callback: @escaping (CSContractTransResult)->Void) {
        
        var params: [AnyObject] = [AnyObject]()
        // spender
        params.append(network.traderAddress as AnyObject)
        /// approve amount
        params.append((config.approveAmount ?? "1000000000000000000000") as AnyObject)
        
        // 注意：需要设置ABI类型
        callContractService(.erc20, methodName: "approve", callType: .write, params: params, config: config) { transResult in
            
            callback(transResult)
        }
    }
    
    
    /// ERC20授权状态查询
    /// - Parameters:
    ///   - address: 当前用户的Eth钱包地址
    ///   - config: 合约调用基础参数配置
    ///   - callback: 回调结果
    public func allowance(config: CSContractConfig, callback: @escaping (CSContractTransResult)->Void) {
        
        guard let from = config.from, let ownerAddress = EthereumAddress(from) else {
            return
        }
        guard let spenderAddress = EthereumAddress(network.traderAddress)  else {
            return
        }
        
        var params: [AnyObject] = []
        // owner
        params.append(ownerAddress as AnyObject)
        // spender
        params.append(spenderAddress as AnyObject)
        
        // 注意：需要设置ABI类型
        callContractService(.erc20, methodName: "allowance", callType: .read, params: params, config: config) { transResult in
            
            callback(transResult)
        }
    }
    
    
    /// 验证代币是否支持
    public func isAllowedToken(config: CSContractConfig, symbol: String, token: String, callback: @escaping (CSContractTransResult)->Void) {
        
        var params: [AnyObject] = []
        // _symbol
        params.append(symbol as AnyObject)
        // _token
        params.append(token.lowercased() as AnyObject)
        
        // 注意：需要设置ABI类型
        callContractService(.factory, methodName: "isAllowedToken", callType: .read, params: params, config: config) { transResult in
            if (config.symbol == "BNB" || config.symbol == "ETH" || config.symbol == "MATIC") {
                transResult.callStatus = true
                callback(transResult)
                return
            }
            
            callback(transResult)
        }
    }
    
    /// 发送ETH
    public func sendEth(config: CSContractConfig, amount: String, toAdds: String, callback: @escaping (CSContractTransResult)->Void) {
        currentConfig = config
        
        let transResult = CSContractTransResult()
                
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)
        let keystoreManager = KeystoreManager([keystore! as EthereumKeystoreV3])
        
        /// web3
        let endpoint = URL(string: contractURL)!
        guard let web333 = try? Web3.new(endpoint) else {
            return
        }
        web333.addKeystoreManager(keystoreManager)
        web3Manager = web333
        
        // 钱包地址
        guard let from = config.from, let walletAddress = EthereumAddress(from) else {
            return
        }
        
        // 接收地址
        guard let toAddress = EthereumAddress(toAdds) else {
            return;
        }
        
        guard let tx = web333.eth.sendETH(from: walletAddress, to: toAddress, amount: amount) else {
            callback(transResult)
            return
        }
        
        txSendCallResult(tx, config: config) { result in
            transResult.transHash = result?.hash ?? ""
            transResult.transDesc = result?.transaction.description ?? ""
        }
        
        callback(transResult)
    }
    
    /// 发送代币
    public func sendToken(config: CSContractConfig, amount: String, toAdds: String, callback: @escaping (CSContractTransResult)->Void) {
        currentConfig = config
        
        let transResult = CSContractTransResult()
        
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)
        let keystoreManager = KeystoreManager([keystore! as EthereumKeystoreV3])
        
        /// web3
        let endpoint = URL(string: contractURL)!
        guard let web333 = try? Web3.new(endpoint) else {
            return
        }
        web333.addKeystoreManager(keystoreManager)
        web3Manager = web333
        
        // 方法名称
        let contractMethod = "transfer"
        // ABI资源
        let contractABI = Web3.Utils.erc20ABI

        // 合约地址
        let ethContractAddress = EthereumAddress(config.contractAddress!)
        
        let abiVersion = 2 // Contract ABI version
        guard let contract = web333.contract(contractABI, at: ethContractAddress, abiVersion: abiVersion) else {
            callback(transResult)
            return
        }
        
        // 我的地址
        guard let from = config.from, let walletAddress = EthereumAddress(from) else {
            return
        }
        
        // 目标地址
        guard let toAddress = EthereumAddress(toAdds) else {
            return
        }
                
        var options = TransactionOptions.defaultOptions
        options.from = walletAddress
        options.to = toAddress
        options.callOnBlock = .latest
        
        // get the decimals manually
        let callResult = try? contract.read("decimals", transactionOptions: options)!.call()
        var decimals = BigUInt(18)
        if let dec = callResult?["0"], let decTyped = dec as? BigUInt {
            decimals = decTyped
        }
        
        let intDecimals = Int(decimals)
        guard let value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals) else {
            callback(transResult)
            return
        }
        
        if let gasLimit = config.gasLimit {
            options.gasLimit = .manual(BigUInt("\(gasLimit)")!)
        }else {
            options.gasLimit = .automatic
        }
        
        if let gasPrice = config.gasPrice {
            if let wei = Web3.Utils.parseToBigUInt(gasPrice, units: .Gwei) {
                options.gasPrice = .manual(wei)
            }else {
                options.gasPrice = .automatic
            }
        }
        else {
            options.gasPrice = .automatic
        }
        
        guard let tx = contract.write(contractMethod, parameters: [toAddress, value] as [AnyObject], transactionOptions: options) else {
            callback(transResult)
            return
        }
        
        txSendCallResult(tx, config: config) { result in
            transResult.transHash = result?.hash ?? ""
            transResult.transDesc = result?.transaction.description ?? ""
        }
        
        callback(transResult)
    }
    
    // MARK: - Contract Call Handler
    
    /// 操作智能合约
    /// - Parameters:
    ///   - method: 方法名称
    ///   - params: 参数
    ///   - config: options配置
    ///   - closure: tx结果信息
    private func callContractService(_ abiType: CSContractAbiType = .erc20, methodName: String, callType: CSContractCallType, params: [AnyObject] = [AnyObject](), config: CSContractConfig, closure: @escaping (CSContractTransResult)->Void) {
        
        if let object = config.toJSON() {
            print("Contract call config：\(object)\n")
            print("Contract call params：\(params)\n")
            
            print("Contract call rpc：\(self.network.ipUrl)\n")
        }
        
        let transResult = CSContractTransResult()
        
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)
        let keystoreManager = KeystoreManager([keystore! as EthereumKeystoreV3])
        
        /// web3
        let endpoint = URL(string: contractURL)!
        guard let web333 = try? Web3.new(endpoint) else {
            return
        }
        web333.addKeystoreManager(keystoreManager)
        web3Manager = web333
        
        // 方法名称
        let contractMethod = methodName
        
        // ABI资源
        var contractABI = Web3.Utils.erc20ABI
        switch abiType {
        case .erc20:
            contractABI = Web3.Utils.erc20ABI
        default:
            let abiName = fetchAbiType(type: abiType)
            contractABI = String.fileContractABI(resName: abiName)
        }

        // 合约地址
        let ethContractAddress = EthereumAddress(config.contractAddress!)
        
        let abiVersion = 2 // Contract ABI version
        guard let contract = web333.contract(contractABI, at: ethContractAddress, abiVersion: abiVersion) else {
            return
        }
        
        var options = TransactionOptions.defaultOptions
        
        // 我的地址
        if let from = config.from, let walletAddress = EthereumAddress(from) {
            options.from = walletAddress
        }
        
        // 接收地址
        if let to = config.to, let toAddress = EthereumAddress(to) {
            options.to = toAddress
        }
        
        var decimals = BigUInt(18)
        // get the decimals manually
        if let callResult = try? contract.read("decimals", transactionOptions: options)?.call() {
            guard let dec = callResult["0"], let decTyped = dec as? BigUInt else {
                return
            }
            decimals = decTyped
        }
        
        let intDecimals = Int(decimals)
        if let amount = config.amount {
            options.value = Web3.Utils.parseToBigUInt(amount, decimals: intDecimals)
        }

        if let gasLimit = config.gasLimit {
            options.gasLimit = .manual(BigUInt("\(gasLimit)")!)
        }else {
            options.gasLimit = .automatic
        }
        
        
        if let gasPrice = config.gasPrice {
            if let gwei = Web3.Utils.parseToBigUInt(gasPrice, units: .Gwei) {
                options.gasPrice = .manual(gwei)
            }else {
                options.gasPrice = .automatic
            }
        }
        else {
            
            options.gasPrice = .automatic
        }
        
        let extraData: Data = Data() // Extra data for contract method
        
        if (callType == .write) {
            
            guard let tx = contract.write(contractMethod,
                                          parameters: params,
                                          extraData: extraData,
                                          transactionOptions: options) else {
                // callback
                closure(transResult)
                return
            }
            
            print("Transaction methodName：\(methodName)\n")
            print("Transaction description：\(tx.transaction.description)\n")
            
            if let result = try? tx.call() {
                transResult.callData = result
                print("Transaction callData：\(result)")
                
                if let etherAddress = result["0"] as? EthereumAddress {
                    print("Transaction _link：\(etherAddress.address)")
                    transResult.linkAddress = etherAddress.address
                }
            }
            
            txSendCallResult(tx, config: config) { result in
                transResult.transHash = result?.hash ?? ""
                transResult.transDesc = result?.transaction.description ?? ""
            }
            
        }else {
            
            guard let tx = contract.read(contractMethod,
                                         parameters: params,
                                         extraData: extraData,
                                         transactionOptions: options) else {
                // callback
                closure(transResult)
                return
            }
            
            print("Transaction methodName：\(methodName)\n")
            print("Transaction description：\(tx.transaction.description)\n")
            
            if let result = try? tx.call() {
                transResult.callData = result
                if let tokenWei = result["0"] as? BigUInt {
                    transResult.callStatus = tokenWei > 0
                    transResult.approvedAmount = "\(tokenWei)"
                }else if let status = result["0"] as? Bool {
                    if (config.symbol == "BNB" || config.symbol == "ETH" || config.symbol == "MATIC") {
                        transResult.callStatus = true
                    }else {
                        transResult.callStatus = status
                    }
                }
                
                print("Transaction callData：\(result)")
            }
        }
        
        // callback
        closure(transResult)
    }
    
    
    /// 获取tx交易结果
    private func txSendCallResult(_ tx: WriteTransaction, options: TransactionOptions? = nil, config: CSContractConfig, completion: @escaping (TransactionSendingResult?)->Void) {
        
        // Get transaction result
        do {
            let result = try tx.send(password: password, transactionOptions: options)
            completion(result)
            
            print("Transaction hash：\(result.hash)\n")
            print("Transaction desc：\(result.transaction.description)\n")
            
        } catch {
            completion(nil)
            
            print("transactionError:\(error)")
        }
    }
    
    /// 获取链上交易日志
    /// - Parameter hash: 交易哈希
    /// - Returns: 交易结果
    public func getTransactionReceipt(hash: String) -> TransactionReceipt? {
        let response = try? self.web3Manager?.eth.getTransactionReceipt(hash)
        return response
    }
    
    /// 获取当前账户余额
    /// - Parameter address: 账户地址
    /// - Returns: 当前账户余额
    public func getAccountBalance(address: String, decimals: Int = 8) -> String {
        
        guard let provider = Web3HttpProvider(NSURL(string: contractURL)! as URL) else {
            return "0.00000000"
        }
        guard let ethAddress = EthereumAddress(address) else {
            return "0.00000000"
        }
        
        let web3Instance = web3(provider:provider)
        let toUnit = Web3.Utils.Units.eth
        let balance = try? web3Instance.eth.getBalance(address: ethAddress)
        let balanceString = Web3.Utils.formatToEthereumUnits(balance ?? "0", toUnits: toUnit, decimals: decimals)
        return balanceString ?? "0.00000000"
    }
    
    /// 验证gas费用是否足够
    public func gasFeeIsEnough(_ walletAddress: String) -> Bool {
        guard walletAddress.length > 0 && walletAddress.hasPrefix("0x") else {
            return false
        }
        
        let gasPrice = self.getContractGasPrice()
        
        let currentBalance = self.getAccountBalance(address: walletAddress, decimals: 8)
        
        var gasLimit = "800000"
        if let config = self.currentConfig, let makeLimit = config.gasLimit {
            gasLimit = makeLimit
        }
        
        let v1 = gasPrice
        let v2 = gasLimit
        let base = self.kBaseGweiUnit
        let value = v1.multiply(base).multiply(v2)
        let currentFee = self.ethCalculation(value: value, isEth: true)
        
        return currentBalance.floatValue > currentFee.floatValue
    }
    
    /// 获取当前默认gasPrice
    /// - Returns: gasPrice
    public func getEthGasPrice(isGwei: Bool) -> String {
        /// web3
        guard let web3Instance = try? Web3.new(URL(string: contractURL)!) else {
            return "0"
        }
        
        var toUnit = Web3.Utils.Units.wei
        if isGwei {
            toUnit = Web3.Utils.Units.Gwei
        }
        let gasPrice = try? web3Instance.eth.getGasPrice()
        let priceString = Web3.Utils.formatToEthereumUnits(gasPrice ?? "10", toUnits: toUnit, decimals: 8)
        return priceString ?? "0"
    }
    
    /// 获取合约交易的gasPrice
    /// - Returns: gasPrice
    public func getContractGasPrice() -> String {
        /// web3
        getContractGasPriceWithRatio(ratio: "0.5")
    }
        
    /// 获取当前对应比例的gasPrice
    /// - Parameter ratio: 0.25 ~ 1
    /// - Returns: gasPrice
    public func getContractGasPriceWithRatio(ratio: String) -> String {
        /// web3
        guard let web3Instance = try? Web3.new(URL(string: contractURL)!) else {
            return "0"
        }
        
        let toUnit = Web3.Utils.Units.Gwei
        let gasPrice = try? web3Instance.eth.getGasPrice()
        let priceString = Web3.Utils.formatToEthereumUnits(gasPrice ?? "10", toUnits: toUnit, decimals: 8)
        // 相应幅度
        let baseRatio = 1 + ratio.doubleValue
        let priceResult = priceString?.multiply("\(baseRatio)")
        return priceResult ?? "0"
    }
    
    /// 计算当前对应比例 ETH gasFee值
    public func ethCalculationWithRatio(value: String, ratio: String) -> String {
        let resValue = BigUInt(value)
        let toUnit = Web3.Utils.Units.eth
        let valueString = Web3.Utils.formatToEthereumUnits(resValue ?? "0", toUnits: toUnit, decimals: 8)
        // 相应幅度
        let baseRatio = 1 + ratio.doubleValue
        let priceResult = valueString?.multiply("\(baseRatio)")
        return priceResult ?? "0.00000000"
    }
    
    /// 计算当前ETH值
    public func ethCalculation(value: String, isEth: Bool = true) -> String {
        let resValue = BigUInt(value)
        var toUnit = Web3.Utils.Units.Gwei
        if (isEth) {
            toUnit = Web3.Utils.Units.eth
        }
        let valueString = Web3.Utils.formatToEthereumUnits(resValue ?? "0", toUnits: toUnit, decimals: 8)
        return valueString ?? "0.00000000"
    }
    
    /// 计算当前ETH值
    /// - Parameters:
    ///   - value: eth值
    ///   - isEth: 是否是ETH
    ///   - decimals: 需要保留的精度
    /// - Returns: 计算结果值
    public func ethCalculation(value: String, isEth: Bool = true, decimals: Int) -> String {
        let resValue = BigUInt(value)
        var toUnit = Web3.Utils.Units.Gwei
        if (isEth) {
            toUnit = Web3.Utils.Units.eth
        }
        let valueString = Web3.Utils.formatToEthereumUnits(resValue ?? "0", toUnits: toUnit, decimals: decimals)
        return valueString ?? "0.00000000"
    }
    
    /// 计算当前ETH值
    public func ethGasPriceCalculation(value: String, decimals: Int = 8) -> String {
        let resValue = BigUInt(value)
        let toUnit = Web3.Utils.Units.eth
        let valueString = Web3.Utils.formatToEthereumUnits(resValue ?? "0", toUnits: toUnit, decimals: decimals)
        return valueString ?? "0.00000000"
    }
    
    /// 查询代币信息
    /// - Parameter address: 代币地址
    public func querySocialToken(address: String) -> CSSocialTokenModel? {
        guard let tokenAddress = EthereumAddress(address) else {
            return nil;
        }
        
        guard let provider = Web3HttpProvider(NSURL(string: contractURL)! as URL) else {
            return nil
        }
        
        let web3Instance = web3(provider:provider)
        let token = ERC20(web3: web3Instance, provider: provider, address: tokenAddress)
        token.readProperties()
        
        let result = CSSocialTokenModel()
        result.name = token.name
        result.symbol = token.symbol
        result.decimals = "\(token.decimals)"
        
        if let balance = try? token.getBalance(account: tokenAddress) {
            let toUnit = Web3.Utils.Units.eth
            let balanceString = Web3.Utils.formatToEthereumUnits(balance, toUnits: toUnit, decimals: 8)
            result.balance = balanceString ?? "0.00000000"
            
            print("decimals：\(token.decimals)\nsymbol：\(token.symbol)\nname：\(token.name)\nbalance：\(result.balance)")
        }
        
        return result
    }
    
    /// 获取Token代币余额
    public func queryTokenBalance(config: CSContractConfig, tokenAddr: String) -> String {
        
        var params: [AnyObject] = [AnyObject]()
        // _address
        let tokenAddress = EthereumAddress(tokenAddr)
        params.append(tokenAddress as AnyObject)
        
        var balanceValue = "0"
        callContractService(.erc20, methodName: "balanceOf", callType: .read, params: params, config: config) { txResult in
            
            if let balance = txResult.callData["0"] as? BigInt {
                balanceValue = Web3.Utils.formatToPrecision(balance, numberDecimals: 8, formattingDecimals: 8, decimalSeparator: ".", fallbackToScientific: false)!
            }
        }
        
        return balanceValue
    }
    
}


// MARK: - ABI

extension CSContractManager {
    
    func fetchAbiType(type: CSContractAbiType) -> String {
        
        switch type {
        case .erc20:
            return "erc20"
        case .factory:
            return "factory"
        case .link:
            return "link"
        case .luca:
            return "luca"
        case .pledge:
            return "pledge"
        case .incentive:
            return "incentive"
        default:
            return "erc20Token"
        }
    }
        
}


// MARK: - Block Explorer

extension CSContractManager {
    
    public func blockScan(txHash: String) {
        var baseUrl = ""
        
        switch networkType {
            // Binance
        case .binance:
            if (self.environmentType == .pro) {
                baseUrl = "https://bscscan.com/tx/"
            }else {
                baseUrl = "https://testnet.bscscan.com/tx/"
            }
            // Polygon
        default:
            if (self.environmentType == .pro) {
                baseUrl = "https://polygonscan.com/tx/"
            }else {
                baseUrl = "https://mumbai.polygonscan.com/tx/"
            }
            break
        }
        
        if let scanURL = URL(string: baseUrl + txHash) {
            if (UIApplication.shared.canOpenURL(scanURL)) {
                UIApplication.shared.open(scanURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    public func blockBrow(txHash: String, chainId: Int = 1) {
        var baseUrl = ""
        
        switch chainId {
            // Binance
        case 1:
            if (self.environmentType == .pro) {
                baseUrl = "https://bscscan.com/tx/"
            }else {
                baseUrl = "https://testnet.bscscan.com/tx/"
            }
            // Polygon
        default:
            if (self.environmentType == .pro) {
                baseUrl = "https://polygonscan.com/tx/"
            }else {
                baseUrl = "https://mumbai.polygonscan.com/tx/"
            }
            break
        }
        
        if let scanURL = URL(string: baseUrl + txHash) {
            if (UIApplication.shared.canOpenURL(scanURL)) {
                UIApplication.shared.open(scanURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    public func blockBrowWallet(address: String) {
        var baseUrl = ""
        
        switch self.networkType {
            // Binance
        case .binance:
            if (self.environmentType == .pro) {
                baseUrl = "https://bscscan.com/address/"
            }else {
                baseUrl = "https://testnet.bscscan.com/address/"
            }
            // Polygon
        default:
            if (self.environmentType == .pro) {
                baseUrl = "https://polygonscan.com/address/"
            }else {
                baseUrl = "https://mumbai.polygonscan.com/address/"
            }
            break
        }
        
        if let scanURL = URL(string: baseUrl + address) {
            if (UIApplication.shared.canOpenURL(scanURL)) {
                UIApplication.shared.open(scanURL, options: [:], completionHandler: nil)
            }
        }
    }
}


// MARK: - Tools

extension CSContractManager {
    
    func getGasLimit(linkCurrency: String) -> String {
        return "800000"
    }
    
    func numberWithHex(hexStr: String) -> String {
        if let hexValue = Web3Utils.hexToBigUInt(hexStr) {
            let toUnit = Web3.Utils.Units.eth
            let stringValue = Web3.Utils.formatToEthereumUnits(hexValue, toUnits: toUnit, decimals: 8)
            return stringValue ?? "0"
        }
        return "0";
    }
}
