//
//  Collection+Extensions.swift
//  EMG
//
//  Created by Cyril Zakka on 11/21/24.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
