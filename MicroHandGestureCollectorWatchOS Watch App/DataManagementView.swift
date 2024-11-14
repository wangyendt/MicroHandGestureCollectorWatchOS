import SwiftUI

struct DataFile: Identifiable {
    let id = UUID()
    let name: String
    let url: URL
    var isSelected: Bool = false
}

struct DataManagementView: View {
    @State private var dataFiles: [DataFile] = []
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach($dataFiles) { $file in
                HStack {
                    if isEditing {
                        Image(systemName: file.isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(file.isSelected ? .blue : .gray)
                            .onTapGesture {
                                file.isSelected.toggle()
                            }
                    }
                    Text(file.name)
                }
            }
        }
        .navigationTitle("数据管理")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(isEditing ? "完成" : "编辑") {
                    isEditing.toggle()
                }
            }
            
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        let selectedFiles = dataFiles.filter { $0.isSelected }
                        if !selectedFiles.isEmpty {
                            deleteSelectedFiles()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .onAppear {
            loadDataFiles()
        }
    }
    
    private func loadDataFiles() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            dataFiles = fileURLs
                .filter { url in
                    // 过滤出采集的数据文件（格式：yyyy_MM_dd_HH_mm_ss_手势_力度）
                    let filename = url.lastPathComponent
                    return filename.contains("_右手_") || filename.contains("_左手_")
                }
                .map { DataFile(name: $0.lastPathComponent, url: $0) }
                .sorted { $0.name > $1.name } // 按文件名降序排序，最新的在最上面
        } catch {
            print("Error loading files: \(error)")
        }
    }
    
    private func deleteSelectedFiles() {
        let selectedFiles = dataFiles.filter { $0.isSelected }
        for file in selectedFiles {
            do {
                try FileManager.default.removeItem(at: file.url)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        loadDataFiles()
        isEditing = false
    }
} 