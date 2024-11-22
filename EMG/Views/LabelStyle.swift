//
//  LabelStyle.swift
//  EMG
//
//  Created by Cyril Zakka on 11/21/24.
//

import SwiftUI

struct NoSpacingLabel: LabelStyle {
    var spacing: Double = 0.0
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}
