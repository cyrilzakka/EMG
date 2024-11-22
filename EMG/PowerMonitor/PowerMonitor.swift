//
//  PowerMonitor.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

import Foundation

@Observable
class PowerMonitor {
    private var iorep = iorep_data()
    private var sd = static_data()
    private var cmd = cmd_data()
    private let sens = SensorsReader()
    
    let avg: Double = 30
    var isRunning = false
    private var monitorTask: Task<Void, Never>?
    
    var globalInfo: dispInfo?
    
    var samplingInterval: Double {
        get {
            access(keyPath: \.samplingInterval)
            return UserDefaults.standard.double(forKey: "samplingInterval")
        }
        set {
            withMutation(keyPath: \.samplingInterval) {
                UserDefaults.standard.setValue(newValue, forKey: "samplingInterval")
            }
        }
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true
        
        iorep = iorep_data()
        sd = static_data()
        cmd = cmd_data()
        
        monitorTask = Task { [weak self] in
            guard let self = self else { return }
            cmd.interval = 175
            cmd.samples = 1
            
            while cmd.interval/1000 >= samplingInterval {
                cmd.interval /= 2
            }
            
            sd.verbosed = false
            staticInit(sd: &sd)
            
            iorep.cpusubchn  = nil
            iorep.pwrsubchn  = nil
            iorep.clpcsubchn = nil
            iorep.bwsubchn   = nil
            iorep.cpuchn_cpu = IOReportCopyChannelsInGroup("CPU Stats", nil, 0, 0, 0)
            iorep.cpuchn_gpu = IOReportCopyChannelsInGroup("GPU Stats", nil, 0, 0, 0)
            iorep.pwrchn_eng = IOReportCopyChannelsInGroup("Energy Model", nil, 0, 0, 0)
            iorep.pwrchn_pmp = IOReportCopyChannelsInGroup("PMP", nil, 0, 0, 0)
            iorep.clpcchn = IOReportCopyChannelsInGroup("CLPC Stats", nil, 0, 0, 0)
            iorep.bwchn = IOReportCopyChannelsInGroup("AMC Stats", nil, 0, 0, 0)
            
            IOReportMergeChannels(
                iorep.cpuchn_cpu?.takeUnretainedValue(),
                iorep.cpuchn_gpu?.takeRetainedValue(),
                nil
            )
            IOReportMergeChannels(
                iorep.pwrchn_eng?.takeUnretainedValue(),
                iorep.pwrchn_pmp?.takeRetainedValue(),
                nil
            )
            
            iorep.cpusub = IOReportCreateSubscription(
                nil, iorep.cpuchn_cpu?.takeRetainedValue(),
                &iorep.cpusubchn, 0, nil
            )
            iorep.pwrsub = IOReportCreateSubscription(
                nil, iorep.pwrchn_eng?.takeRetainedValue(),
                &iorep.pwrsubchn, 0, nil
            )
            iorep.clpcsub = IOReportCreateSubscription(
                nil, iorep.clpcchn?.takeRetainedValue(),
                &iorep.clpcsubchn, 0, nil
            )
            iorep.bwsub = IOReportCreateSubscription(
                nil, iorep.bwchn?.takeRetainedValue(),
                &iorep.bwsubchn, 0, nil
            )
            
            iorep.cpuchn_cpu = nil
            iorep.cpuchn_gpu = nil
            iorep.pwrchn_eng = nil
            iorep.pwrchn_pmp = nil
            iorep.clpcchn    = nil
            iorep.bwchn      = nil
            
            var monInfo = dispInfo(sd: sd)
            var cpu_pwr = monInfo.cpu_pwr.val
            var gpu_pwr = monInfo.gpu_pwr.val
            
            var pwr_max: peak_pwr = peak_pwr()
            var pwr_avg: avg_pwr = avg_pwr()
            
            let fan_set = sd.fan_exist
            sens.read()
            if fan_set {
                generateFanLimit(sd: &sd, sense: sens.value!.sensors)
            }
            
            while !Task.isCancelled && isRunning {
                autoreleasepool {
                    var rd: render_data? = render_data()
                    var vd: variating_data? = vd_init(sd: self.sd)
                    self.sens.read()
                    getSensorVal(vd: &vd!, sd: &self.sd, sense: self.sens.value!.sensors) // sensor value
                    getMemUsage(vd: &vd!)
                    self.sd.ram_capacity = "\(Int(vd!.mem_stat.total[0]))\(ByteUnit(vd!.mem_stat.total[1]))"
                    monInfo = dispInfo(sd: self.sd)
                    monInfo.cpu_pwr.val = cpu_pwr
                    monInfo.gpu_pwr.val = gpu_pwr
                    
                    monInfo.sys_pwr_max = pwr_max.sys
                    monInfo.cpu_pwr_max = pwr_max.cpu
                    monInfo.gpu_pwr_max = pwr_max.gpu
                    monInfo.ram_pwr_max = pwr_max.ram
                    
                    monInfo.sys_pwr_avg = pwr_avg.sys
                    monInfo.cpu_pwr_avg = pwr_avg.cpu
                    monInfo.gpu_pwr_avg = pwr_avg.gpu
                    monInfo.ram_pwr_avg = pwr_avg.ram
                    
                    let repData = report_data(iorep: self.iorep)
                    
                    sample(iorep: repData.iorep!, sd: self.sd, vd: &vd!, cmd: self.cmd)
                    // print("sampling finish")
                    format(sd: &self.sd, vd: &vd!) // 포매팅
                    // print("formatting finish")
                    summary(sd: self.sd, vd: vd!, rd: &rd!, rvd: &monInfo, opt: self.avg)
                    
                    pwr_max.sys = monInfo.sys_pwr_max
                    pwr_max.cpu = monInfo.cpu_pwr_max
                    pwr_max.gpu = monInfo.gpu_pwr_max
                    pwr_max.ram = monInfo.ram_pwr_max
                    
                    pwr_avg.sys = monInfo.sys_pwr_avg
                    pwr_avg.cpu = monInfo.cpu_pwr_avg
                    pwr_avg.gpu = monInfo.gpu_pwr_avg
                    pwr_avg.ram = monInfo.ram_pwr_avg
                    
                    rd = nil
                    vd = nil
                }
                
                cpu_pwr = monInfo.cpu_pwr.val
                gpu_pwr = monInfo.gpu_pwr.val
                globalInfo = monInfo
                
                try? await Task.sleep(for: .milliseconds(Int64((samplingInterval-(cmd.interval*1e-3)) * 1000)))
            }
            cleanupSubscriptions()
        }
    }
    
    func stop() {
        isRunning = false
        monitorTask?.cancel()
        monitorTask = nil
        globalInfo = nil
    }
    
    private func cleanupSubscriptions() {
        // Release subscriptions
        iorep.cpusub = nil
        iorep.pwrsub = nil
        iorep.clpcsub = nil
        iorep.bwsub = nil

        iorep.cpusubchn = nil
        iorep.pwrsubchn = nil
        iorep.clpcsubchn = nil
        iorep.bwsubchn = nil

        iorep.cpuchn_cpu = nil
        iorep.cpuchn_gpu = nil
        iorep.pwrchn_eng = nil
        iorep.pwrchn_pmp = nil
        iorep.clpcchn    = nil
        iorep.bwchn      = nil
    }
    
}
