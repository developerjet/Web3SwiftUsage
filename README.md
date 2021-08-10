# Web3EtherKit
web3 contract call

、、、

import UIKit
import web3swift
import BigInt

enum CSContractCallType {
    case write
    case read
}

enum InfuraType {
    
    static let rinkeby = "https://rinkeby.infura.io/v3/4a95f60324fa444d9f3eb79040ee8285"
    
    static let kovan = "https://kovan.infura.io/v3/2fd1b260e62e4f6fab379ceecf722fc4"
    
    static let product = "https://kovan.infura.io/v3/2fd1b260e62e4f6fab379ceecf722fc4"
}

private typealias Contract = CSContractInfo

struct CSContractInfo {
    
    /// trader
    static let traderAddress = "0xDE0B9c6beF2c1C1238E346F032bfC8662D01FbE5"
    
    /// approve amount
    static let approveAmount = "1000000000000000000000"
    
    /// web3 default password
    static let password = "web3swift"
}

@objcMembers public class CSContractManager: NSObject {
    
    /// manager
    static let shared = CSContractManager()
    
    /// web3
    private var web3Manager: web3?
    
    /// networks
    private var infuraNetworks: [String] {
        return [InfuraType.rinkeby, InfuraType.kovan]
    }

    /// network  selected index
    private var networkIndex: Int {
        guard let index = UserDefaults.standard.value(forKey: "kWeb3NetworkTypeKey") as? Int else {
            return 0
        }
        return index
    }
    
    /// contractURL
    private var contractURL: String {
        return infuraNetworks[networkIndex]
    }
    
    override init() { }
    
    // MARK: - Public
    
    /// callContract
    public func callContract(method: String, params: [AnyObject], config: CSContractConfig, callback: @escaping (CSContractTransResult)->Void) {
        
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
        params.append(Contract.traderAddress as AnyObject)
        // amount
        params.append(Contract.approveAmount as AnyObject)
        
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
        guard let spenderAddress = EthereumAddress(Contract.traderAddress)  else {
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
        params.append(token as AnyObject)
        
        // 注意：需要设置ABI类型
        callContractService(.factory, methodName: "isAllowedToken", callType: .read, params: params, config: config) { transResult in
            
            callback(transResult)
        }
    }
    
    /// 发送ETH
    public func sendEth(config: CSContractConfig, amount: String, toAdds: String, callback: @escaping (CSContractTransResult)->Void) {
        
        let transResult = CSContractTransResult()
                
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: Contract.password)
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
        
        txSendCallResult(tx) { result in
            transResult.transHash = result?.hash ?? ""
            transResult.transDesc = result?.transaction.description ?? ""
        }
        
        callback(transResult)
    }
    
    /// 发送代币
    public func sendToken(config: CSContractConfig, amount: String, toAdds: String, callback: @escaping (CSContractTransResult)->Void) {
        
        let transResult = CSContractTransResult()
        
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: Contract.password)
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
        
        txSendCallResult(tx) { result in
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
        
        if let object = config.modelToJSONObject() {
            print("Call configs：\(object)")
        }
        
        let transResult = CSContractTransResult()
        
        // key
        guard let privateKey = config.privateKey else { return }
        
        let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: Contract.password)
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
                closure(transResult)
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
            if let wei = Web3.Utils.parseToBigUInt(gasPrice, units: .Gwei) {
                options.gasPrice = .manual(wei)
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
            
            txSendCallResult(tx) { result in
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
                }
                else if let status = result["0"] as? Bool {
                    transResult.callStatus = status
                }
                
                print("Transaction callData：\(result)")
            }
        }
        
        // callback
        closure(transResult)
    }
    
    
    /// 获取tx交易结果
    private func txSendCallResult(_ tx: WriteTransaction, options: TransactionOptions? = nil, completion: @escaping (TransactionSendingResult?)->Void) {
        
        // Get transaction result
        do {
            let result = try tx.send(password: Contract.password, transactionOptions: options)
            completion(result)
            
            print("Transaction hash：\(result.hash)\n")
            print("Transaction desc：\(result.transaction.description)\n")
            
        } catch {
            completion(nil)
            
            print("Transaction error：\(error)")
            showMessag(message: error.localizedDescription.description)
        }
    }
    
    /// 获取链上交易日志
    /// - Parameter hash: 交易哈希
    /// - Returns: 交易结果
    public func getTransactionReceipt(hash: String) -> TransactionReceipt? {
        let response = try? self.web3Manager?.eth.getTransactionReceipt(hash)
        return response
    }
    
    /// 获取ETH余额
    /// - Parameter address: 账户地址
    /// - Returns: 当前账户余额
    public func getEthBalance(address: String, decimals: Int = 8) -> String {
        
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
        let priceString = Web3.Utils.formatToEthereumUnits(gasPrice ?? "0", toUnits: toUnit, decimals: 8)
        return priceString ?? "0"
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
    
    func showMessag(message: String, toView: UIView? = nil, delay: TimeInterval = 1.0) {
        DispatchQueue.main.async {
            MBProgressHUD.showMessag(message, to: toView, afterDelay: delay)
        }
    }
    
}


// MARK: - Ether scan

extension CSContractManager {
    
    public func etherScan(txHash: String) {
        guard let networkType = CSContractInfuraType(rawValue: networkIndex) else {
            return
        }
        
        var baseUrl = "https://rinkeby.etherscan.io/tx/"
        switch networkType {
        case .rinkeby:
            baseUrl = "https://rinkeby.etherscan.io/tx/"
            
        case .kovan:
            baseUrl = "https://kovan.etherscan.io/tx/"
            
        default:
            break
        }
        
        if let scanURL = URL(string: baseUrl + txHash) {
            if (UIApplication.shared.canOpenURL(scanURL)) {
                UIApplication.shared.open(scanURL, options: [:], completionHandler: nil)
            }
        }
    }
    
}


、、、
