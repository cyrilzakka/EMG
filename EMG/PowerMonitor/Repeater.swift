//
//  Repeater.swift
//  EMG
//
//  Created by Cyril Zakka on 11/20/24.
//

public enum PMState {
    case paused
    case running
}

public class Repeater {
    private var callback: (() -> Void)
    private var state: PMState = .paused
    
    private var timer: DispatchSourceTimer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "com.cyrilzakka.EMG"))
    
    public init(seconds: Int, callback: @escaping (() -> Void)) {
        self.callback = callback
        self.setupTimer(seconds)
    }
    
    deinit {
        self.timer.cancel()
        self.start()
    }
    
    private func setupTimer(_ interval: Int) {
        timer.schedule(
            deadline: DispatchTime.now() + Double(interval),
            repeating: .seconds(interval),
            leeway: .seconds(0)
        )
        timer.setEventHandler { [weak self] in
            self?.callback()
        }
    }
    
    public func start() {
        guard self.state == .paused else { return }
        
        self.timer.resume()
        self.state = .running
    }
    
    public func pause() {
        guard self.state == .running else { return }
        
        self.timer.suspend()
        self.state = .paused
    }
    
    public func reset(seconds: Int, restart: Bool = false) {
        if self.state == .running {
            self.pause()
        }
        
        self.setupTimer(seconds)
        
        if restart {
            self.callback()
            self.start()
        }
    }
}