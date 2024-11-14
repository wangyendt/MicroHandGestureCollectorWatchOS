//
//  ContentView.swift
//  MicroHandGestureCollectorWatchOS Watch App
//
//  Created by wayne on 2024/11/4.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var isCollecting = false
    @State private var selectedHand = "右手"
    @State private var selectedGesture = "单击[正]"
    @State private var selectedForce = "轻"
    
    @State private var showHandPicker = false
    @State private var showGesturePicker = false
    @State private var showForcePicker = false
    
    @State private var showingDataManagement = false
    
    let handOptions = ["左手", "右手"]
    let gestureOptions = ["单击[正]", "双击[正]", "握拳[正]", "鼓掌[负]", "抖腕[负]", "拍打[负]", "日常[负]"]
    let forceOptions = ["轻", "重"]
    let calculator = CalculatorBridge()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // 手性选择
                Button(action: { showHandPicker = true }) {
                    HStack {
                        Text("手性").font(.headline)
                        Spacer()
                        Text(selectedHand)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showHandPicker) {
                    List {
                        ForEach(handOptions, id: \.self) { option in
                            Button(action: {
                                selectedHand = option
                                showHandPicker = false
                            }) {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if selectedHand == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 手势选择
                Button(action: { showGesturePicker = true }) {
                    HStack {
                        Text("手势").font(.headline)
                        Spacer()
                        Text(selectedGesture)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showGesturePicker) {
                    List {
                        ForEach(gestureOptions, id: \.self) { option in
                            Button(action: {
                                selectedGesture = option
                                showGesturePicker = false
                            }) {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if selectedGesture == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 力度选择
                Button(action: { showForcePicker = true }) {
                    HStack {
                        Text("力度").font(.headline)
                        Spacer()
                        Text(selectedForce)
                            .foregroundColor(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                .sheet(isPresented: $showForcePicker) {
                    List {
                        ForEach(forceOptions, id: \.self) { option in
                            Button(action: {
                                selectedForce = option
                                showForcePicker = false
                            }) {
                                HStack {
                                    Text(option)
                                    Spacer()
                                    if selectedForce == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 开始/停止按钮
                Button(action: {
                    isCollecting.toggle()
                    if isCollecting {
                        motionManager.startDataCollection(
                            hand: selectedHand,
                            gesture: selectedGesture,
                            force: selectedForce
                        )
                    } else {
                        motionManager.stopDataCollection()
                    }
                }) {
                    Text(isCollecting ? "停止采集" : "开始采集")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .background(isCollecting ? Color.red : Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                
                // 导出按钮
                Button(action: {
                    motionManager.exportData()
                }) {
                    Text("导出数据")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                
            
                Button(action: {
                    showingDataManagement = true
                }) {
                    Image(systemName: "folder")
                    Text("数据管理")
                }
                .sheet(isPresented: $showingDataManagement) {
                    NavigationView {
                        DataManagementView()
                    }
                }
                
                // 实时数据显示
                if let accData = motionManager.accelerationData {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("加速度计").font(.headline)
                        Text(String(format: "X: %.2f\nY: %.2f\nZ: %.2f",
                                  accData.x,
                                  accData.y,
                                  accData.z))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if let rotationData = motionManager.rotationData {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("陀螺仪").font(.headline)
                        Text(String(format: "X: %.2f\nY: %.2f\nZ: %.2f",
                                  rotationData.x,
                                  rotationData.y,
                                  rotationData.z))
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("1024 + 1000 = \(calculator.sum(1000, with: 1024))")
                    .padding()
            }
            .padding(.horizontal, 10)
        }
    }
}

#Preview {
    ContentView()
}
