//
//  HungaFast.swift
//  Challenge
//
//  Created by Jonathan Solorzano on 6/6/22.
//

import Foundation


func OptimalAssignments(_ strArr: [String]) -> String {
    
    func combo(_ a:[Int]) -> [[Int]] {
        if a.count == 1  { return [a] }
        
        let otherItems = a.enumerated()
            .map{
                ($1, a[0..<$0] + a[$0+1..<a.count])
            }
        let subCombos  = otherItems.map{( $0,combo(Array($1)) )}
        
        return subCombos.flatMap{ i, r in r.map{ [i]+$0 } }
    }
    let nonDigits   = CharacterSet.decimalDigits.inverted
    let splits      = strArr.map{ $0.components(separatedBy:nonDigits) }
    let machines    = splits.map{ $0.flatMap{ Int($0) } }
    
    let combos      = combo(Array(machines.indices)).map{ $0.enumerated() }
    let values      = combos.map{ $0.map{ machines[$0][$1] }.reduce(0,+) }
    let optimal     = zip(combos,values).sorted{ $0.1 < $1.1 }.first!.0
    
    return optimal.map{"(\($0+1)-\($1+1))"}.joined()
}
