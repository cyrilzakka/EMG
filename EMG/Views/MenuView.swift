//
//  MenuView.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

import SwiftUI

struct MenuView: View {
    
    @Environment(PowerMonitor.self) private var powerMonitor
    
    var body: some View {
        // cpu_pwr: EMG.chartInfo(title: "CPU: 1.51W", val: [1.1142857, 1.8857144, 1.8000001, 7.5428567]),
//        gpu_pwr: EMG.chartInfo(title: "GPU: 0.17W", val: [0.0, 0.114285715, 0.25714287, 0.82857144]),
        ZStack {
            HStack(alignment: .center, spacing: 0) {
                // GPU
                HStack(alignment: .center, spacing: 5) {
                    VerticalGauge(value: Int(powerMonitor.globalInfo?.pcpu_usg.val ?? 0), minRange: 0, maxRange: 100).drawingGroup()
                    VStack(alignment: .leading) {
                        Text("GPU: \(Int(powerMonitor.globalInfo?.gpu_usg.val ?? 0), format: .number)%")
                        Text("\(Int(powerMonitor.globalInfo?.gpu_bw.val ?? 0), format: .number) GB/s")
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .scaleEffect(0.8)
                }
                .frame(width: 70)
                
                // CPU
                HStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 2) {
                        VerticalGauge(value: Int(powerMonitor.globalInfo?.ecpu_usg.val ?? 0), minRange: 0, maxRange: 100)
                        VerticalGauge(value: Int(powerMonitor.globalInfo?.pcpu_usg.val ?? 0), minRange: 0, maxRange: 100)
                    }
                    .drawingGroup()
                    
                    VStack(alignment: .leading) {
                        Text("E-CPU: \(Int(powerMonitor.globalInfo?.ecpu_usg.val ?? 0), format: .number)%")
                        Text("P-CPU: \(Int(powerMonitor.globalInfo?.pcpu_usg.val ?? 0), format: .number)%")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .scaleEffect(0.8)
                    
                }
                .frame(width: 80)
                
                // ANE
                VStack(alignment: .leading) {
                    Label {
                        Text("ANE")
                    } icon: {
                        Image(systemName: "cpu.fill")
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                    .labelStyle(NoSpacingLabel(spacing: 3))
                    
                    Text("\(Int(powerMonitor.globalInfo?.ane_usg.val ?? 0), format: .number)%")
                }
                .font(.footnote)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .scaleEffect(0.8)
//                .frame(width: 75)
                
                // Read/Write
                let (_, read, write) = parseMemoryBandwidth(powerMonitor.globalInfo?.bw_grp ?? "")
                VStack(alignment: .leading, spacing: 0) {
                    Label {
                        Text("R: \(Int(read), format: .number) GB/s")
                            .font(.footnote)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .fixedSize()
                    } icon: {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.primary.opacity(0.8))
                            .fontWeight(.bold)
                            .imageScale(.small)
                    }
                    .labelStyle(NoSpacingLabel(spacing: 3))
                    
                    Label {
                        Text("W: \(Int(write), format: .number) GB/s")
                            .font(.footnote)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .fixedSize()
                    } icon: {
                        Image(systemName: "arrow.down")
                            .foregroundStyle(.primary.opacity(0.8))
                            .fontWeight(.bold)
                            .imageScale(.small)
                    }
                    .labelStyle(NoSpacingLabel(spacing: 3))
                    
                }
                .scaleEffect(0.8)
                .frame(width: 70)
                
                
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
        
        .onAppear {
            powerMonitor.start()
        }
    }
    
    func parseMemoryBandwidth(_ text: String) -> (total: Double, read: Double, write: Double) {
        // First get the total bandwidth
        guard let totalStr = text.split(separator: ":")[safe: 1]?
            .split(separator: "(")[safe: 0]!
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " GB/s", with: ""),
            let total = Double(totalStr) else {
            return (0, 0, 0)
        }
        
        // Then get read and write values
        guard let componentsStr = text.split(separator: "(")[safe: 1]?
            .replacingOccurrences(of: ")", with: "") else {
            return (total, 0, 0)
        }
        
        let components = componentsStr.split(separator: " ")
        
        // Parse read value
        let readStr = components[safe: 0]?
            .replacingOccurrences(of: "R:", with: "")
            .replacingOccurrences(of: "GB/s", with: "") ?? ""
        let read = Double(readStr) ?? 0
        
        // Parse write value
        let writeStr = components[safe: 2]?
            .replacingOccurrences(of: "W:", with: "")
            .replacingOccurrences(of: "GB/s", with: "") ?? ""
        let write = Double(writeStr) ?? 0
        
        return (total, read, write)
    }
}

#Preview {
    MenuView()
        .frame(width: 300, height: 300)
        .environment(PowerMonitor())
}
