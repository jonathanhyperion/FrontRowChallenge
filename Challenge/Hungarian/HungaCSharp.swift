//
//  File.swift
//  Challenge
//
//  Created by Jonathan Solorzano on 6/6/22.
//

import Foundation

struct Location {
    let row: Int
    let column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}

class HungarianAlgoCS {
    
    private var matrix: [[Int]]
    private let rowsCount: Int
    private let columnsCount: Int
    
    private var masks: [[UInt8]]
    private var rowsCovered: [Bool]
    private var colsCovered: [Bool]
    
    
    private var path: [Location]
    private var pathStart: Location
    private var step: Int
    
    
    init(matrix: [[Int]]) {
        self.matrix = matrix
        // TODO: Validate matrix is square, we don't have fixed matrixes in swift arrays
        self.rowsCount = matrix.count
        self.columnsCount = matrix[0].count
        
        self.masks = [[UInt8]](
            repeating: [UInt8](repeating: 0, count: rowsCount),
            count: rowsCount
        )
        self.rowsCovered = [Bool](repeating: false, count: rowsCount)
        self.colsCovered = [Bool](repeating: false, count: columnsCount)
        
        self.path = [Location](repeating: .init(row: -1, column: -1), count: rowsCount*columnsCount)
        self.pathStart = Location(row: 0, column: 0)
        self.step = 1
    }
    
    /// Finds the optimal assignments for a given matrix of agents and costed tasks such that the total cost is minimized.
    public func findOptimalAssignments() -> [Int] {
        
        // Step 0: For each row/column of the matrix, find the smallest element and subtract it from every element in its row/column
        for rowIndex in 0..<rowsCount {
            var minVal = Int.max
            for colIndex in 0..<columnsCount { minVal = min(minVal, matrix[rowIndex][colIndex]) }
            for colIndex in 0..<columnsCount { matrix[rowIndex][colIndex] -= minVal }
        }
        
        // Step 0.1: Cover all zeros in the matrix using minimum number of horizontal and vertical lines.
        for rowIndex in 0..<rowsCount {
            for colIndex in 0..<columnsCount {
                if matrix[rowIndex][colIndex] == 0,
                   !rowsCovered[rowIndex],
                   !colsCovered[colIndex] {
                    
                    // Store the "lines" in mask array
                    masks[rowIndex][colIndex] = 1
                    rowsCovered[rowIndex] = true
                    colsCovered[colIndex] = true
                }
            }
        }
        
        clearCovers()
        
        // We'll use a step variable to keep iterating while we try to find the optimal values
        while step != -1 {
            // Each function will return the next step to perform depending on the values
            switch step {
            case 1: step = step1()
            case 2: step = step2()
            case 3: step = step3()
            case 4: step = step4()
            default: step = -1
            }
        }
        
        var agentTasks = [Int](repeating: -1, count: columnsCount)
        
        for rowIndex in 0..<rowsCount {
            for colIndex in 0..<columnsCount {
                if masks[rowIndex][colIndex] == 1 {
                    agentTasks[rowIndex] = colIndex
                    break
                }
            }
        }
        
        return agentTasks
    }
    
    /// Test for Optimality: If the minimum number of covering lines is n, an optimal assignment is possible and we are finished. Else if lines are lesser than n, we haven’t found the optimal assignment, and must proceed to step 2.
    private func step1() -> Int {
        
        for rowIndex in 0..<rowsCount {
            for colIndex in 0..<columnsCount {
                if masks[rowIndex][colIndex] == 1 { colsCovered[colIndex] = true }
            }
        }
        
        var colsCoveredCount = 0
        
        for colIndex in 0..<columnsCount {
            if colsCovered[colIndex] { colsCoveredCount += 1 }
        }
        
        if colsCoveredCount == columnsCount { return -1 }
        
        return 2
    }
    
    /// Determine the smallest entry not covered by any line.
    /// Subtract this entry from each uncovered row, and then add it to each covered column. Return to step 3.
    private func step2() -> Int {
        
        func findZero() -> Location {
            
            for rowIndex in 0..<rowsCount {
                for colIndex in 0..<columnsCount {
                    if matrix[rowIndex][colIndex] == 0,
                       !rowsCovered[rowIndex],
                       !colsCovered[colIndex] {
                        return Location(row: rowIndex, column: colIndex)
                    }
                }
            }
            
            return Location(row: -1, column: -1)
        }
        
        func findStarInRow(row: Int) -> Int {
            for colIndex in 0..<columnsCount {
                if masks[row][colIndex] == 1 { return colIndex }
            }
            return -1
        }
        
        while true {
            
            let loc = findZero()
            if loc.row == -1 { return 4 }
            
            masks[loc.row][loc.column] = 2
            
            let starCol = findStarInRow(row: loc.row)
            
            if starCol != -1 {
                rowsCovered[loc.row] = true
                colsCovered[starCol] = false
            }
            else {
                pathStart = loc
                return 3
            }
        }
    }
    
    private func step3() -> Int {
        
        func finsStarInColumn(column: Int) -> Int {
            for rowIndex in 0..<rowsCount {
                if masks[rowIndex][column] == 1 { return rowIndex }
            }
            return -1
        }
        
        func findPrimeInRow(row: Int) -> Int {
            for colIndex in 0..<columnsCount {
                if masks[row][colIndex] == 2 { return colIndex}
            }
            return -1
        }
        
        var pathIndex = 0
        path[0] = pathStart
        
        while true {
            let row = finsStarInColumn(column: path[pathIndex].column)
            if row == -1 { break }
            
            pathIndex += 1
            path[pathIndex] = Location(row: row, column: path[pathIndex - 1].column)
            
            let col = findPrimeInRow(row: path[pathIndex].row)
            
            pathIndex += 1
            path[pathIndex] = Location(row: path[pathIndex - 1].row, column: col)
        }
        
        convertPath(pathLength: pathIndex + 1)
        clearCovers()
        clearPrimes()
        
        return 1
    }
    
    private func step4() -> Int {
        
        func findMinValue() -> Int {
            var minValue = Int.max
            for rowIndex in 0..<rowsCount {
                for colIndex in 0..<columnsCount {
                    if !rowsCovered[rowIndex],
                       !colsCovered[colIndex] {
                        minValue = min(minValue, matrix[rowIndex][colIndex])
                    }
                }
            }
            return minValue
        }
        
        let minValue = findMinValue()
        
        for rowIndex in 0..<rowsCount {
            for colIndex in 0..<columnsCount {
                if rowsCovered[rowIndex] { matrix[rowIndex][colIndex] += minValue }
                if !colsCovered[colIndex] { matrix[rowIndex][colIndex] -= minValue}
            }
        }
        
        return 2
        
    }
    
    // MARK: - Helpers
    
    // TODO: This should be just one for loop
    private func clearCovers() {
        for rowIndex in 0..<rowsCount { rowsCovered[rowIndex] = false }
        for colIndex in 0..<columnsCount { colsCovered[colIndex] = false }
    }
    
    private func convertPath(pathLength: Int) {
        for index in 0..<pathLength {
            switch masks[path[index].row][path[index].column] {
            case 1: masks[path[index].row][path[index].column] = 0
            case 2: masks[path[index].row][path[index].column] = 1
            default: continue
            }
        }
    }
    
    private func clearPrimes() {
        for rowIndex in 0..<rowsCount {
            for colIndex in 0..<columnsCount {
                if masks[rowIndex][colIndex] == 2 { masks[rowIndex][colIndex] = 0 }
            }
        }
    }
}
