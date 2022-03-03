//
//  Web3Headers.swift
//  Web3SwiftUtils
//
//  Created by Apple on 2021/5/11.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation

extension String {
    
    private func isDecimal(_ num: String) -> Bool {
        guard Validate.decimal(self, count: 16).isValid,
              Validate.decimal(num, count: 16).isValid,
              self.doubleValue > 0,
              num.doubleValue > 0 else { return false }
        return !self.hasSuffix(".")
    }

    func add(_ num: String) -> String {
        guard isDecimal(num) else { return "0" }
        guard num.doubleValue != 0 else { return "0" }
        return NSDecimalNumber(string: self).adding(NSDecimalNumber(string: num)).stringValue
    }
    
    func subtract(_ num: String) -> String {
        guard isDecimal(num) else { return "0" }
        guard num.doubleValue != 0 else { return "0" }
        return NSDecimalNumber(string: self).subtracting(NSDecimalNumber(string: num)).stringValue
    }
    
    func multiply(_ num: String) -> String {
        guard isDecimal(num) else { return "0" }
        guard num.doubleValue != 0 else { return "0" }
        return NSDecimalNumber(string: self).multiplying(by: NSDecimalNumber(string: num)).stringValue.preciseDecimal(p: 8, isRoundingDown: true)
    }
    
    func divid(_ num: String) -> String {
        guard isDecimal(num) else { return "0" }
        guard num.doubleValue != 0 else { return "0" }
        return NSDecimalNumber(string: self).dividing(by: NSDecimalNumber(string: num)).stringValue.preciseDecimal(p: 8, isRoundingDown: true)
    }
    
    func pow(_ num: Int) -> String {
        guard num != 0 else { return "0" }
        return NSDecimalNumber(string: self).raising(toPower: num).stringValue.preciseDecimal(p: 8, isRoundingDown: true)
    }
    
    func preciseDecimal(p: Int, isRoundingDown: Bool, isPretty: Bool = false) -> String {
        
        var roundingModel = NSDecimalNumber.RoundingMode.plain
        if isRoundingDown { roundingModel = NSDecimalNumber.RoundingMode.down }
        
        let count: Int = (p < 0 ? 0 : p)
        let decimalNumberHandle: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: roundingModel,
                                                                                  scale: Int16(count),
                                                                                  raiseOnExactness: false,
                                                                                  raiseOnOverflow: false,
                                                                                  raiseOnUnderflow: false,
                                                                                  raiseOnDivideByZero: false)
        let decimaleNumber: NSDecimalNumber = NSDecimalNumber(string: self)
        let resultNumber: NSDecimalNumber = decimaleNumber.rounding(accordingToBehavior: decimalNumberHandle)
        
        guard isPretty else { return resultNumber.stringValue }
        
        let formatter: NumberFormatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = p

        return formatter.string(from: resultNumber) ?? resultNumber.stringValue
    }
}

