//
//  Hungarian.swift
//  Challenge
//
//  Created by Jonathan Solorzano on 5/6/22.
//

import Foundation

class HungarianAlgorithm {
    
    private var matrix: [[Int]]
    
    private var squareInRow: [Int] /// Indicate the position of the marked zeroes
    private var squareInCol: [Int] /// Indicate the position of the marked zeroes
    private var rowIsCovered: [Int] /// Indicates whether a row is covered
    private var colIsCovered: [Int] /// Indicates whether a column is covered
    private var staredZeroesInRow: [Int] /// storage for the 0*
    
    init(matrix: [[Int]]) {
        
        // Initializing the arrays to be used
        
        self.matrix = matrix
        
        // squareInRow & squareInCol indicate the position of the marked zeroes
        self.squareInRow = Array<Int>(repeating: -1, count: matrix.count)
        self.squareInCol = Array<Int>(repeating: -1, count: matrix[0].count)
        
        // indicates whether a row is covered
        self.rowIsCovered = Array<Int>(repeating: -1, count: matrix.count)
        self.colIsCovered = Array<Int>(repeating: -1, count: matrix[0].count)
        
        self.staredZeroesInRow = Array<Int>(repeating: -1, count: matrix.count)
    }
    
    public func findOptimalAssignment() -> [[Int]] {
        step1() // reduce matrix
        step2() // mark independent zeroes
        step3() // cover columns which contain a marked zero
        
        while !allColumnsAreCovered() {
            
            var mainZero = step4()
            
            // while no zero found in step4
            while mainZero == nil {
                step7()
                mainZero = step4()
            }
            
            if squareInRow[mainZero![0]] == -1 {
                // there is no square mark in the mainZero line
                step6(mainZero!)
                step3() // cover columns which contain a marked zero
            } else {
                // there is square mark in the mainZero line
                // step 5
                rowIsCovered[mainZero![0]] = 1 // cover row of mainZero
                colIsCovered[squareInRow[mainZero![0]]] = 0 // uncover column of mainZero
                step7()
            }
        }
        var optimalAssignment = Array<Array<Int>>(repeating: [0], count: matrix.count)
        
        for (rowIndex, value) in squareInCol.enumerated() {
            optimalAssignment[rowIndex] = [rowIndex + 1, value + 1]
        }
        
        return optimalAssignment
    }
    
    // MARK: - Private API
    
    private func allColumnsAreCovered() -> Bool {
        
        for value in colIsCovered {
            if value == 0 { return false }
        }
        
        return true
    }
    
    /// Step 1:
    /// Reduce the matrix so that in each row and column at least one zero exists:
    /// 1. subtract each row minima from each element of the row
    /// 2. subtract each column minima from each element of the column
    private func step1() {
        // rows
        for (rowIndex, _) in matrix.enumerated() {
            
            var currentRowMin = Int.max
            
            // find the min value of the current row
            for colIndex in 0..<matrix[rowIndex].count {
                if matrix[rowIndex][colIndex] < currentRowMin {
                    currentRowMin = matrix[rowIndex][colIndex]
                }
            }
            // subtract min value from each element of the current row
            for colIndex in 0..<matrix[rowIndex].count {
                matrix[rowIndex][colIndex] -= currentRowMin
            }
        }
        
        // cols
        for colIndex in 0..<matrix[0].count {
            
            var currentColMin = Int.max
            
            // find the min value of the current column
            for (rowIndex, _) in matrix.enumerated() {
                if (matrix[rowIndex][colIndex] < currentColMin ) {
                    currentColMin = matrix[rowIndex][colIndex]
                }
            }
            
            // subtract min value from each element of the current column
            for (rowIndex, _) in matrix.enumerated() {
                matrix[rowIndex][colIndex] -= currentColMin
            }
        }
    }
    
    /// Step 2:
    /// Mark each 0 with a "square", if there are no other marked zeroes in the same row or column
    private func step2() {
        var rowHasSquare = Array<Int>(repeating: 0, count: matrix.count)
        var colHasSquare = Array<Int>(repeating: 0, count: matrix[0].count)
        
        for (rowIndex, _) in matrix.enumerated() {
            for (colIndex, _) in matrix.enumerated() {
                // mark if current value == 0 & there are no other marked zeroes in the same row or column
                if matrix[rowIndex][colIndex] == 0,
                   rowHasSquare[rowIndex] == 0,
                   colHasSquare[colIndex] == 0 {
                    
                    rowHasSquare[rowIndex] = 1
                    colHasSquare[colIndex] = 1
                    
                    squareInRow[rowIndex] = colIndex // save the row-position of the zero
                    squareInCol[colIndex] = rowIndex // save the col-position of the zero
                    continue // jump to next row
                }
            }
        }
    }
    
    /// Step 3:
    /// Cover all columns which are marked with a "square"
    private func step3() {
        for (index, _) in squareInCol.enumerated() {
            let squareInColHasValue = squareInCol[index] != -1
            colIsCovered[index] = squareInColHasValue ? 1 : 0
        }
    }
    
    /// Step 4:
    /// Find zero value Z_0 and mark it as "0*".
    /// returns position of Z_0 in the matrix
    private func step4() -> [Int]? {
        
        var position: [Int]? = nil
        
        for (rowIndex, _) in matrix.enumerated() {
            if rowIsCovered[rowIndex] == 0 {
                for colIndex in 0..<matrix[rowIndex].count {
                    if matrix[rowIndex][colIndex] == 0,
                       colIsCovered[colIndex] == 0 {
                        
                        staredZeroesInRow[rowIndex] = colIndex // mark as 0*
                        position = [rowIndex, colIndex]
                        continue
                    }
                }
            }
        }
        
        return position
    }
    
    
    /// Step 6:
    /// Create a chain K of alternating "squares" and "0*"
    /// mainZero => Z_0 of Step 4
    private func step6(_ mainZero: [Int]) {
        
        var rowIndex = mainZero[0]
        var colIndex = mainZero[1]
        var K = Set<[Int]>()
        
        //(a)
        // add Z_0 to K
        K.insert(mainZero)
        var found = false
        
        repeat {
            // (b)
            // add Z_1 to K if
            // there is a zero Z_1 which is marked with a "square " in the column of Z_0
            if squareInCol[colIndex] != -1 {
                K.insert([squareInCol[colIndex], colIndex])
                found = true
            } else {
                found = false
            }
            
            // if no zero element Z_1 marked with "square" exists in the column of Z_0, then cancel the loop
            if (!found) {
                break
            }
            
            // (c)
            // replace Z_0 with the 0* in the row of Z_1
            rowIndex = squareInCol[colIndex]
            colIndex = staredZeroesInRow[rowIndex]
            // add the new Z_0 to K
            if colIndex != -1 {
                K.insert([rowIndex, colIndex])
                found = true
            } else {
                found = false
            }
            
        } while found // (d) as long as no new "square" marks are found
        
        // (e)
        K.forEach { zero in
            // remove all "square" marks in K
            if squareInCol[zero[1]] == zero[0] {
                
                squareInCol[zero[1]] = -1
                squareInRow[zero[0]] = -1
            }
            // replace the 0* marks in K with "square" marks
            if staredZeroesInRow[zero[0]] == zero[1] {
                
                squareInRow[zero[0]] = zero[1]
                squareInCol[zero[1]] = zero[0]
            }
        }
        
        // (f)
        // remove all marks
        staredZeroesInRow = Array<Int>(repeating: -1, count: staredZeroesInRow.count)
        rowIsCovered = Array<Int>(repeating: 0, count: squareInRow.count)
        colIsCovered = Array<Int>(repeating: 0, count: squareInCol.count)
    }
    
    /// Step 7:
    /// 1. Find the smallest uncovered value in the matrix.
    /// 2. Subtract it from all uncovered values
    /// 3. Add it to all twice-covered values
    private func step7() {
        // Find the smallest uncovered value in the matrix
        var minUncoveredValue = Int.max
        
        for (rowIndex, _) in matrix.enumerated() {
            if rowIsCovered[rowIndex] == 1 { continue }
            for colIndex in 0..<matrix[0].count {
                if colIsCovered[colIndex] == 0,
                   matrix[rowIndex][colIndex] < minUncoveredValue {
                    minUncoveredValue = matrix[rowIndex][colIndex]
                }
            }
        }
        
        if (minUncoveredValue > 0) {
            
            for (rowIndex, _) in matrix.enumerated() {
                for colIndex in 0..<matrix[0].count {
                    if rowIsCovered[rowIndex] == 1,
                       colIsCovered[colIndex] == 1 {
                        // Add min to all twice-covered values
                        matrix[rowIndex][colIndex] += minUncoveredValue
                    } else if rowIsCovered[rowIndex] == 0,
                              colIsCovered[colIndex] == 0 {
                        // Subtract min from all uncovered values
                        matrix[rowIndex][colIndex] -= minUncoveredValue
                    }
                }
            }
        }
    }
}

