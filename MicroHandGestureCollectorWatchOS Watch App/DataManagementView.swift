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
    @State private var isAllSelected = false
    @State private var showingDeleteAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var selectedFiles: [DataFile] {
        dataFiles.filter { $0.isSelected }
    }
    
    var body: some View {
        List {
            if isEditing && !dataFiles.isEmpty {
                Button(action: {
                    isAllSelected.toggle()
                    dataFiles = dataFiles.map { file in
                        var newFile = file
                        newFile.isSelected = isAllSelected
                        return newFile
                    }
                }) {
                    HStack {
                        Image(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isAllSelected ? .blue : .gray)
                        Image(systemName: "checklist")
                            .foregroundColor(.blue)
                        Text(isAllSelected ? "取消全选" : "全选")
                    }
                }
            }
            
            ForEach($dataFiles) { $file in
                HStack {
                    if isEditing {
                        Image(systemName: file.isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(file.isSelected ? .blue : .gray)
                            .onTapGesture {
                                file.isSelected.toggle()
                                updateAllSelectedState()
                            }
                    }
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    Text(file.name)
                }
            }
        }
        .navigationTitle("数据管理")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    isEditing.toggle()
                    if !isEditing {
                        isAllSelected = false
                        dataFiles = dataFiles.map { file in
                            var newFile = file
                            newFile.isSelected = false
                            return newFile
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                        Text(isEditing ? "完成" : "编辑")
                    }
                }
            }
            
            if isEditing {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if !selectedFiles.isEmpty {
                            showingDeleteAlert = true
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .alert("确认删除", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                deleteSelectedFiles()
            }
        } message: {
            Text("确定要删除选中的\(selectedFiles.count)个文件吗？")
        }
        .onAppear {
            loadDataFiles()
        }
    }
    
    private func updateAllSelectedState() {
        isAllSelected = !dataFiles.contains { !$0.isSelected }
    }
    
    private func loadDataFiles() {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            dataFiles = fileURLs
                .filter { url in
                    let filename = url.lastPathComponent
                    return filename.contains("_右手_") || filename.contains("_左手_")
                }
                .map { DataFile(name: $0.lastPathComponent, url: $0) }
                .sorted { $0.name > $1.name }
        } catch {
            print("Error loading files: \(error)")
        }
    }
    
    private func deleteSelectedFiles() {
        for file in selectedFiles {
            do {
                try FileManager.default.removeItem(at: file.url)
            } catch {
                print("Error deleting file: \(error)")
            }
        }
        loadDataFiles()
        isEditing = false
        isAllSelected = false
    }
} 