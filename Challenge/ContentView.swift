//
//  ContentView.swift
//  Challenge
//
//  Created by Jonathan Solorzano on 5/6/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text(OptimalAssignments(example))
            .padding()
    }
    
//    let example = ["(13,4,7,6)","(1,11,5,4)","(6,7,2,8)","(1,3,5,9)"]
    let example = ["(1,2,1)","(4,1,5)","(5,2,1)"]

    func OptimalAssignments(_ strArr: [String]) -> String {
        
        print(strArr)
        
        let nonDigits = CharacterSet.decimalDigits.inverted
        let character = ","
        let matrix = strArr.map {
            $0.trimmingCharacters(in: nonDigits)
            .components(separatedBy: character)
            .map { Int($0)! }
        }
        
        let optimalAssigments = HungarianAlgoCS(matrix: matrix)
            .findOptimalAssignments()
            .enumerated()
            .compactMap { "(\($0+1)-\($1+1))" }
            .joined()
        
        print(optimalAssigments)
        
        return optimalAssigments
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
