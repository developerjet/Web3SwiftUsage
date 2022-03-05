## Web3Swift工具类封装
### Web3SwiftUtils

* 主要实现Etherum、Binance、Polygon链等智能合约常用业务调用

### Usage

```swift
    /// 代币授权
    func tokenApprove() {
        
        let config = CSContractConfig()
        config.abiType = .erc20;
        config.privateKey = "your privateKey"
        config.from = "your walletAddress";
        config.approveAmount = "1000000000000";
        config.contractAddress = "contract address"
        config.symbol = "token symbol"

        CSContractManager.shared.callContract(method: "approve", params: [], config: config) { result in
            if (result.transHash.length > 0 && result.callData.count > 0) {
                print("Token approve success")
            }else {
                print("Token approve fail")
            }
        }
    }
```

```swift
    /// 代币发送
    func sendToken() {
        
        let config = CSContractConfig()
        config.abiType = .erc20;
        config.privateKey = "your privateKey"
        config.from = "your walletAddress";
        config.approveAmount = "1000000000000";
        config.contractAddress = "contract address"
        config.symbol = "token symbol"
        config.gasLimit = kBaseGasLimit;
        
        let targetAddress = "target address"
        CSContractManager.shared.sendToken(config: config, amount: "10", toAdds: targetAddress) { result  in
            if (result.transHash.length > 0) {
                print("Token send success")
            }else {
                print("Token send fail")
            }
        }
    }
```

```swift
    /// 查询代币信息
    func queryToken() {
        
        let tokenAddress = ""
        guard let token = CSContractManager.shared.querySocialToken(address: tokenAddress) else {
            return
        }
        
        print("Token Name:\(token.name)\n")
        print("Token Symbol:\(token.symbol)\n")
        print("Token decimals:\(token.decimals)\n")
    }
```
