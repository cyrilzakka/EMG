//
//  extensions.swift
//  socpowerbuddy_swift
//
//  Created by Eom SeHwan on 2022/09/17.
//

// Custom error type for string operations
public struct StringError: LocalizedError {
    let message: String
    
    public var errorDescription: String? {
        return message
    }
}

// String extension with utility methods
public extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var trimmed: String {
        var buf = [UInt8]()
        var trimming = true
        for c in self.utf8 {
            if trimming && c < 33 { continue }
            trimming = false
            buf.append(c)
        }
        
        while let last = buf.last, last < 33 {
            buf.removeLast()
        }
        
        buf.append(0)
        return String(cString: buf)
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

// Double extension for rounding
public extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
