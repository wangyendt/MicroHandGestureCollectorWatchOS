//
//  MotionManager.swift
//  MicroHandGestureCollectorWatchOS
//
//  Created by wayne on 2024/11/4.
//

import SwiftUI
import CoreMotion
import Combine

#if os(watchOS)  // 确保只在 watchOS 平台运行
public class MotionManager: ObservableObject {  // 改为 public
    @Published private(set) var accelerometerData: CMAccelerometerData?
    @Published private(set) var gyroData: CMGyroData?
    private let motionManager: CMMotionManager  // 改为 private
    private var accFileHandle: FileHandle?
    private var isCollecting = false
    
    public init() {  // 改为 public
        motionManager = CMMotionManager()
        print("MotionManager 初始化")
        print("加速度计状态: \(motionManager.isAccelerometerAvailable ? "可用" : "不可用")")
        print("陀螺仪状态: \(motionManager.isGyroAvailable ? "可用" : "不可用")")
        print("设备运动状态: \(motionManager.isDeviceMotionAvailable ? "可用" : "不可用")")
    }
    
    public func startUpdates() {  // 改为 public
        stopUpdates()
        
        if motionManager.isGyroAvailable {
            print("开始陀螺仪更新")
            motionManager.gyroUpdateInterval = 1.0 / 60.0
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let error = error {
                    print("陀螺仪错误: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { 
                    print("陀螺仪数据为空")
                    return 
                }
                
                DispatchQueue.main.async {
                    self?.gyroData = data
                    print("陀螺仪: x=\(data.rotationRate.x), y=\(data.rotationRate.y), z=\(data.rotationRate.z)")
                }
            }
        } else {
            print("陀螺仪不可用，尝试使用 deviceMotion")
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
                motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { [weak self] (motion, error) in
                    if let motion = motion {
                        print("设备运动: x=\(motion.rotationRate.x), y=\(motion.rotationRate.y), z=\(motion.rotationRate.z)")
                    }
                }
            }
        }
        
        if motionManager.isAccelerometerAvailable {
            print("开始加速度计更新")
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                if let error = error {
                    print("加速度计错误: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self?.accelerometerData = data
                }
            }
        }
    }
    
    public func stopUpdates() {  // 改为 public
        motionManager.stopGyroUpdates()
        motionManager.stopAccelerometerUpdates()
        motionManager.stopDeviceMotionUpdates()
        print("停止所有传感器更新")
    }
    
    public func startDataCollection(hand: String, gesture: String, force: String) {
        stopUpdates()
        isCollecting = true
        
        // 创建文件夹和文件
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        let timestamp = dateFormatter.string(from: Date())
        let folderName = "\(timestamp)_\(hand)_\(gesture)_\(force)"
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("无法访问文档目录")
            return
        }
        
        let folderURL = documentsPath.appendingPathComponent(folderName)
        let accFileURL = folderURL.appendingPathComponent("acc.txt")
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            FileManager.default.createFile(atPath: accFileURL.path, contents: nil)
            accFileHandle = try FileHandle(forWritingTo: accFileURL)
        } catch {
            print("创建文件失败: \(error)")
            return
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] (data, error) in
                guard let self = self, let data = data else { return }
                
                let timestamp = Date().timeIntervalSince1970
                let dataString = String(format: "%.6f,%.6f,%.6f,%.6f\n",
                                     timestamp,
                                     data.acceleration.x,
                                     data.acceleration.y,
                                     data.acceleration.z)
                
                if let data = dataString.data(using: .utf8) {
                    self.accFileHandle?.write(data)
                }
                
                DispatchQueue.main.async {
                    self.accelerometerData = data
                }
            }
        }
    }
    
    public func stopDataCollection() {
        stopUpdates()
        accFileHandle?.closeFile()
        accFileHandle = nil
        isCollecting = false
    }
    
    // 添加公共访问方法
    public var isGyroAvailable: Bool {
        return motionManager.isGyroAvailable
    }
    
    // 在 MotionManager 类中修改 exportData 方法
    public func exportData() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("❌ 无法访问文档目录")
            return
        }
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            
            // 创建日志文件
            let logFileURL = documentsPath.appendingPathComponent("export_log.txt")
            var logContent = "=== 数据采集文件列表 ===\n"
            logContent += "导出时间：\(Date())\n\n"
            
            files.forEach { file in
                logContent += "📁 \(file.lastPathComponent)\n"
            }
            
            try logContent.write(to: logFileURL, atomically: true, encoding: .utf8)
            print("✅ 日志已导出到：\(logFileURL.path)")
            
            // 打印所有数据文件的位置
            print("\n=== 数据文件位置 ===")
            files.forEach { file in
                print("📄 \(file.path)")
            }
        } catch {
            print("❌ 导出失败: \(error)")
        }
    }
}
#endif
