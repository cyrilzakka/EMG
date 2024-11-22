//
//  Models.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

struct tileInfo {
    var title: String
    var val: Float
    
    var watts: Double {
        Double(title.split(separator: "@")[safe: 1]?
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: " W", with: "") ?? "0.0") ?? 0.0
    }
}

struct chartInfo {
    var title: String
    var val: [Float]
}

struct dispInfo {
    var proc_grp = "Processor Utilization"
    var mem_grp = "Memory"
    var pwr_grp = "Power Chart"
    
    var ecpu_usg = tileInfo(
        title: "E-CPU Usage",
        val: 0
    )
    var pcpu_usg = tileInfo(
        title: "P-CPU Usage",
        val: 0
    )
    var gpu_usg = tileInfo(
        title: "GPU Usage",
        val: 0
    )
    var ane_usg = tileInfo(
        title: "ANE Usage",
        val: 0
    )
    var fan_usg = chartInfo(
        title: "FAN Usage",
        val: [0, 0]
    )
    var airflow_info = ["Left fan: "]
    
    var ram_usg = tileInfo(
        title: "RAM Usage",
        val: 0
    )
    var bw_grp = "Memory Bandwidth"
    var ecpu_bw = tileInfo(
        title: "E-CPU",
        val: 50
    )
    var pcpu_bw = tileInfo(
        title: "P-CPU",
        val: 50
    )
    var gpu_bw = tileInfo(
        title: "GPU",
        val: 50
    )
    var media_bw = tileInfo(
        title: "Media",
        val: 50
    )
    
    var cpu_pwr = chartInfo(
        title: "CPU",
        val: []
    )
    var gpu_pwr = chartInfo(
        title: "GPU",
        val: []
    )
    
    var sys_pwr_max: Double = 0
    var cpu_pwr_max: Float = 0
    var gpu_pwr_max: Float = 0
    var ram_pwr_max: Float = 0
    
    var sys_pwr_avg = Array<Double>()
    var cpu_pwr_avg = Array<Float>()
    var gpu_pwr_avg = Array<Float>()
    var ram_pwr_avg = Array<Float>()
    
    init(sd: static_data) {
        autoreleasepool {
            var cpu_title = sd.extra[0]
            if case let mode = sd.extra[sd.extra.count-1], ["Apple", "Rosetta 2"].contains(mode) {
                if mode == "Apple" {
                    cpu_title += " (cores: \(sd.core_ep_counts[0])E+\(sd.core_ep_counts[1])P+"
                } else if mode == "Rosetta 2" {
                    cpu_title += "[Rosetta 2] (cores: \(sd.core_ep_counts.reduce(0,+))C+"
                }
                cpu_title += "\(sd.gpu_core_count)GPU+\(sd.ram_capacity))"
                cpu_title = "\(sd.verbosed ? sd.marketing_name + " " : "")\(cpu_title)"
            }
            cpu_title += " \(sd.os_ver)\(sd.verbosed ? " " + sd.os_code_name : "")"
            
            proc_grp = cpu_title
        }
    }
}
