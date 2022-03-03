## Web3Swift工具类封装
### Web3SwiftUtils

* 主要实现Ether、Binance、Polygon链等智能合约常用业务调用

### Usage

```swift
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
```
