//
//  VerticalGauge.swift
//  EMG
//
//  Created by Cyril Zakka on 11/21/24.
//

import SwiftUI

struct VerticalGauge: View {
    var value: Int = -1
    @State private var frame: CGRect = .zero
    
    let minRange: Int
    let maxRange: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack {
                Capsule()
                    .fill(.tertiary)
                Capsule()
                    .fill(.primary)
                    .frame(height: frame.height * normalizedValue)
                    .frame(maxHeight: frame.height, alignment: .bottom)
            }
            .frame(width: 7)
            .scaleEffect(0.7)
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            frame = newValue
        }
    }
    
    private var normalizedValue: CGFloat {
        let clippedValue = min(max(value, minRange), maxRange)
        return CGFloat(clippedValue - minRange) / CGFloat(maxRange - minRange)
    }
}

struct HorizontalGauge: View {
    var value: Int = -1
    @State private var frame: CGRect = .zero
    
    let minRange: Int
    let maxRange: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Capsule()
                    .fill(.tertiary)
                Capsule()
                    .fill(.primary)
                    .frame(width: frame.width * normalizedValue)
                    .frame(maxWidth: frame.width, alignment: .leading)
            }
            .frame(height: 7)
            .scaleEffect(0.7)
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            frame = newValue
        }
    }
    
    private var normalizedValue: CGFloat {
        let clippedValue = min(max(value, minRange), maxRange)
        return CGFloat(clippedValue - minRange) / CGFloat(maxRange - minRange)
    }
}
