//
//  Hunga.swift
//  Challenge
//
//  Created by Jonathan Solorzano on 6/6/22.
//

import Foundation

final class HungaAlgorithm {

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

    func findOptimalAssignment() -> [[Int]] {
        
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
        squareInCol.enumerated().forEach { (i, value) in
            optimalAssignment[i] = [i + 1, value + 1]
        }
        return optimalAssignment
    }

    /**
     * Check if all columns are covered. If that's the case then the
     * optimal solution is found
     *
     * @return true or false
     */
    private func allColumnsAreCovered() -> Bool {
      var covered = true
        colIsCovered.forEach { i in
            if (i == 0) {
                covered = false
                return
            }
        }
        return covered
    }

    /**
     * Step 1:
     * Reduce the matrix so that in each row and column at least one zero exists:
     * 1. subtract each row minima from each element of the row
     * 2. subtract each column minima from each element of the column
     */
    private func step1() {
        // rows
        matrix.indices.forEach { i in
            // find the min value of the current row
            var currentRowMin = Int.max
            (0...matrix[i].count - 1).forEach { j in
                if (matrix[i][j] < currentRowMin) {
                    currentRowMin = matrix[i][j]
                }
            }
            // subtract min value from each element of the current row
            (0...matrix[i].count - 1).forEach { k in
                matrix[i][k] -= currentRowMin
            }
        }

        // cols
        (0...matrix[0].count - 1).forEach { i in
            // find the min value of the current column
            var currentColMin = Int.max
            matrix.enumerated().forEach { (j, value) in
                if (matrix[j][i] < currentColMin) {
                    currentColMin = matrix[j][i]
                }
            }
            // subtract min value from each element of the current column
            matrix.enumerated().forEach { (k, value) in
                matrix[k][i] -= currentColMin
            }
        }
    }

    /**
     * Step 2:
     * mark each 0 with a "square", if there are no other marked zeroes in the same row or column
     */
    private func step2() {
        var rowHasSquare = Array<Int>(repeating: 0, count: matrix.count)
        var colHasSquare = Array<Int>(repeating: 0, count: matrix[0].count)
        matrix.indices.forEach { i in
            matrix.indices.forEach { j in
                // mark if current value == 0 & there are no other marked zeroes in the same row or column
                if (matrix[i][j] == 0 && rowHasSquare[i] == 0 && colHasSquare[j] == 0) {
                    rowHasSquare[i] = 1
                    colHasSquare[j] = 1
                    squareInRow[i] = j // save the row-position of the zero
                    squareInCol[j] = i // save the column-position of the zero
                    return  // jump to next row
                }
            }
        }
    }

    /**
     * Step 3:
     * Cover all columns which are marked with a "square"
     */
    private func step3() {
        squareInCol.enumerated().forEach { (i, value) in
            if squareInCol[i] != -1 {
              colIsCovered[i] = 1
            } else {
              colIsCovered[i] = 0
            }
        }
    }

    /**
     * Step 7:
     * 1. Find the smallest uncovered value in the matrix.
     * 2. Subtract it from all uncovered values
     * 3. Add it to all twice-covered values
     */
    private func step7() {
        // Find the smallest uncovered value in the matrix
        var minUncoveredValue = Int.max
        matrix.enumerated().forEach { (i, value) in
            if (rowIsCovered[i] == 1) {
                return
            }
            (0...matrix[0].count - 1).forEach { j in
                if (colIsCovered[j] == 0 && matrix[i][j] < minUncoveredValue) {
                    minUncoveredValue = matrix[i][j]
                }
            }
        }
        if (minUncoveredValue > 0) {
            matrix.enumerated().forEach { (i, value) in
                (0...matrix[0].count - 1).forEach { j in
                    if (rowIsCovered[i] == 1 && colIsCovered[j] == 1) {
                        // Add min to all twice-covered values
                        matrix[i][j] += minUncoveredValue
                    } else if (rowIsCovered[i] == 0 && colIsCovered[j] == 0) {
                        // Subtract min from all uncovered values
                        matrix[i][j] -= minUncoveredValue
                    }
                }
            }
        }
    }

    /**
     * Step 4:
     * Find zero value Z_0 and mark it as "0*".
     *
     * @return position of Z_0 in the matrix
     */
    private func step4() -> [Int]? {
      var position: [Int]? = nil
        matrix.enumerated().forEach { (i, _) in
            if (rowIsCovered[i] == 0) {
                (0...matrix[i].count - 1).forEach { j in
                    if (matrix[i][j] == 0 && colIsCovered[j] == 0) {
                        staredZeroesInRow[i] = j // mark as 0*
                        position = [i, j]
                        return
                    }
                }
            }
        }
        return position
    }

    /**
     * Step 6:
     * Create a chain K of alternating "squares" and "0*"
     *
     * @param mainZero => Z_0 of Step 4
     */
    private func step6(_ mainZero: [Int]) {
        var i = mainZero[0]
        var j = mainZero[1]
        var K = Set<[Int]>()
        //(a)
        // add Z_0 to K
        K.insert(mainZero)
        var found = false
        repeat {
            // (b)
            // add Z_1 to K if
            // there is a zero Z_1 which is marked with a "square " in the column of Z_0
            if squareInCol[j] != -1 {
                K.insert([squareInCol[j], j])
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
            i = squareInCol[j]
            j = staredZeroesInRow[i]
            // add the new Z_0 to K
            if j != -1 {
                K.insert([i, j])
                found = true
            } else {
                found = false
            }
        } while found // (d) as long as no new "square" marks are found

        // (e)
        K.forEach { zero in
            // remove all "square" marks in K
            if (squareInCol[zero[1]] == zero[0]) {
                squareInCol[zero[1]] = -1
                squareInRow[zero[0]] = -1
            }
            // replace the 0* marks in K with "square" marks
            if (staredZeroesInRow[zero[0]] == zero[1]) {
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
}
