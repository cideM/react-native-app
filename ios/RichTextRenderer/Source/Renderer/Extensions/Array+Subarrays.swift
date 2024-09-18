//
//  Array+Subarrays.swift
//  RichTextRenderer
//
//  Created by Mohamed Abdul Hameed on 27.01.21.
//

extension Array {
    /// Creates an array of arrays from the array based on the intervals decided by the `indices` parameter.
    ///
    /// For example, for the following values:
    /// array = `["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]`
    /// indices = `[3, 6]`
    ///
    /// The result will be: `[["0", "1", "2"], ["3"], ["4", "5"], ["6"], ["7", "8", "9", "10"]]`
    ///
    /// - Parameter indices: The indices that will decide the bounds of the subarrays.
    /// - Returns: The subarrays
    func subarrays(indices: [Int]) -> [[Element]] {
        guard !self.isEmpty else { return [[]] }
        guard !indices.isEmpty else { return [self] }
        guard self.count > 1 else { return [[self[0]]] }
        guard self.count > 2 else { return [[self[0]], [self[1]]]}
        
        var result: [[Element]] = []
        var sortedIndices = indices.sorted()

        var resultArray = self
        while !resultArray.isEmpty {
            guard let lastIndex = sortedIndices.last else { result.append(resultArray.dropLast()); break }
            let range = (lastIndex + 1)...
            if result.isEmpty {
                result.append(Array(resultArray[range]))
            } else {
                result.append(Array(resultArray[range]).dropLast())
            }
            result.append([self[lastIndex]])
            resultArray.removeSubrange(range)
            sortedIndices.removeLast()
        }
        
        result = result.reversed()
        result = result.filter { !$0.isEmpty }
        
        return result
    }
}
