//
//  ContentView.swift
//  LaunchPadModifier
//
//  Created by 梁湘辉 on 2023/12/20.
//

import SwiftUI
import SwiftData
import GRDB

struct ContentView: View {
    
    @AppStorage("DBPath") var dbPath = ""
    
    @State private var isFileSelectorPresented = false
    
    @State var appDatas: [AppData] = []
    
    @State var errorMesage = "请选择 /private/var/folders/ 下的启动台配置数据库文件"
    
    @State var isWindowsPop = false
    
    @State var selectedAPP: AppData?
    
    @State var selectedGroupAPP: AppData?
    
    @State var isShowingAlert = false
    
    @State var alertMessage = ""
    
    
    var body: some View {
        ZStack {
            if appDatas.isEmpty {
                VStack {
                    
                    Text(errorMesage)
                    Button("选择数据库文件夹路径") {
                        loadLaunchPadData()
                    }
                }
            } else {
                
                List(selection: $selectedAPP) {
                    ForEach(appDatas, id: \.self) { data in
                        AppItemView(app: data)
                            .onTapGesture {
                                onItemTaped(app: data)
                            }
                            .contextMenu(ContextMenu(menuItems: {
                                if data.isGroup {
                                    Button {
                                        onItemTaped(app: data)
                                    } label: {
                                        Label("查看详情", systemImage: "magnifyingglass")
                                    }
                                }
                                
                                Button {
                                    renameAPP(app: data)
                                } label: {
                                    Label("重命名", systemImage: "pencil")
                                }
                                
                                Button {
                                    deleteAPP(app: data)
                                } label: {
                                    Label("删除图标", systemImage: "trash")
                                }
                            }))
                            .background(Color.white.opacity(0.01).onTapGesture {
                                onItemTaped(app: data)
                            })
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: backupDB) {
                    Label("备份数据库", systemImage: "square.and.arrow.up")
                }
            }
            
            ToolbarItem {
                Button(action: reloadDB) {
                    Label("还原数据库", systemImage: "square.and.arrow.down")
                }
            }
                            
            ToolbarItem {
                Button(action: refeshLaunchPadData) {
                    Label("刷新数据库", systemImage: "gobackward")
                }
            }
        }
        .fileImporter(isPresented: $isFileSelectorPresented, allowedContentTypes: [.folder]) { result in
            
            switch result {
            case .success(let file):
                print(file.absoluteString)
                checkDBFile(path: file.absoluteString)
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
        .onAppear {
            if dbPath == "" {
                errorMesage = "请选择 /private/var/folders/ 下的启动台配置数据库文件"
            } else {
                checkDBFile(path: dbPath)
            }
        }
        .sheet(isPresented: $isWindowsPop) {
            if let apps = selectedAPP?.groupedApps {
                VStack {
                    List(selection: $selectedGroupAPP) {
                        ForEach(apps, id: \.self) { data in
                            AppItemView(app: data)
                                .onTapGesture {
                                    onItemTaped(app: data)
                                }
                                .contextMenu(ContextMenu(menuItems: {                                    
                                    Button {
                                        renameAPP(app: data)
                                    } label: {
                                        Label("重命名", systemImage: "pencil")
                                    }
                                    
                                    Button {
                                        deleteAPP(app: data)
                                    } label: {
                                        Label("删除图标", systemImage: "trash")
                                    }
                                }))
                        }
                    }
                    .frame(height: 450, alignment: .top)
                }
            }
        }
        .alert(alertMessage, isPresented: $isShowingAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func deleteAPP(app: AppData) {
        deleteAPPFromDB(app: app)
    }
    
    private func renameAPP(app: AppData) {
        
    }
    
    private func deleteAPPFromDB(app: AppData) {
        do {
            let dbQueue = try DatabaseQueue(path: dbPath + "db")
            try dbQueue.write { db in
                if app.isGroup {
                    if app.groupedApps.isEmpty {
                        try db.execute(
                            sql: "DELETE FROM groups WHERE item_id = :id",
                            arguments: ["id": app.itemId])
                        
                        try db.execute(
                            sql: "DELETE FROM items WHERE rowid = :id",
                            arguments: ["id": app.itemId])
                    } else {
                        alertMessage = "暂不建议直接删除带有APP的分组"
                        isShowingAlert = true
                    }
                } else {
                    try db.execute(
                        sql: "DELETE FROM image_cache WHERE item_id = :id",
                        arguments: ["id": app.itemId])
                    
                    try db.execute(
                        sql: "DELETE FROM apps WHERE item_id = :id",
                        arguments: ["id": app.itemId])
                    
                    try db.execute(
                        sql: "DELETE FROM items WHERE rowid = :id",
                        arguments: ["id": app.itemId])
                }
            }
            refeshLaunchPadData()
            isWindowsPop = false
            _ = runShellWithArgs("killall", "Dock")
        } catch {
            alertMessage = error.localizedDescription
            isShowingAlert = true
        }
    }
    
    private func onItemTaped(app: AppData) {
        selectedAPP = app
        
        isWindowsPop = app.isGroup
        
        //        selectedAPP = app
        print(selectedAPP?.title ?? "NULL")
    }
    
    private func refeshLaunchPadData() {
//        isFileSelectorPresented = true
        appDatas.removeAll()
        checkDBFile(path: dbPath)
    }
    
    private func loadLaunchPadData() {
        isFileSelectorPresented = true
    }
    
    private func backupDB() {
        removeFile(sourceUrl: dbPath + "db.backup")
        removeFile(sourceUrl: dbPath + "db-shm.backup")
        removeFile(sourceUrl: dbPath + "db-wal.backup")
        copyFile(sourceUrl: dbPath + "db", targetUrl: dbPath + "db.backup")
        copyFile(sourceUrl: dbPath + "db-shm", targetUrl: dbPath + "db-shm.backup")
        copyFile(sourceUrl: dbPath + "db-wal", targetUrl: dbPath + "db-wal.backup")
        print("'database.backup'")
        _ = runShellWithArgs("sqlite3", dbPath + "db", ".backup '2132.bk'")
    }
    
    private func reloadDB() {
        print(dbPath)
        removeFile(sourceUrl: dbPath + "db")
        removeFile(sourceUrl: dbPath + "db-shm")
        removeFile(sourceUrl: dbPath + "db-wal")
        copyFile(sourceUrl: dbPath + "db.backup", targetUrl: dbPath + "db")
        copyFile(sourceUrl: dbPath + "db-shm.backup", targetUrl: dbPath + "db-shm")
        copyFile(sourceUrl: dbPath + "db-wal.backup", targetUrl: dbPath + "db-wal")
        refeshLaunchPadData()
        _ = runShellWithArgs("killall", "Dock")
    }
    
    private func deleteDBCache() {
        removeFile(sourceUrl: dbPath + "db-shm")
        removeFile(sourceUrl: dbPath + "db-wal")
    }
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(items[index])
            }
        }
    }
    
    private func checkDBFile(path: String) {
        let actualPath = path.replacingOccurrences(of: "file://", with: "")
        if FileManager.default.fileExists(atPath: actualPath + "db") {
            if FileManager.default.fileExists(atPath: actualPath + "db.backup") {
                readLaunchPadDB(path: actualPath + "db")
            } else {
                copyFile(sourceUrl: actualPath + "db", targetUrl: actualPath + "db.backup")
                readLaunchPadDB(path: actualPath + "db")
            }
            
            dbPath = actualPath
            
        } else {
            appDatas.removeAll()
            errorMesage = "请选择启动台数据库文件夹"
        }
    }
    
    
    private func copyFile(sourceUrl:String, targetUrl:String) {
        let fileManager = FileManager.default
        do{
            try fileManager.copyItem(atPath: sourceUrl, toPath: targetUrl)
        }catch{
            errorMesage = "无法生成数据库备份文件"
            print(error.localizedDescription)
        }
    }
    
    private func removeFile(sourceUrl:String){
        let fileManger = FileManager.default
        do{
            try fileManger.removeItem(atPath: sourceUrl)
            print("Success to remove file.")
        }catch{
            print("Failed to remove file.")
        }
    }
    
    private func readLaunchPadDB(path: String) {
        do {
            
            let dbQueue = try DatabaseQueue(path: path)
            
            _ = try dbQueue.read { db in
                
                let groupRows = try Row.fetchCursor(db, sql: "SELECT * FROM groups")
                while let group = try groupRows.next() {
                    let itemId: Int? = group["item_id"]
                    let title: String? = group["title"]
                    
                    if title != nil && title != "" {
                        appDatas.append(AppData(itemId: itemId, title: title, isGroup: true))
                    }
                }
                
                let itemRows = try Row.fetchCursor(db, sql: "SELECT * FROM items")
                while let item = try itemRows.next() {
                    
                    let itemId: Int? = item["rowid"]
                    let parentId: Int? = item["parent_id"]
                    let flags: Int? = item["flags"]
                    
                    if flags != nil {
                        
                        let app = try Row.fetchOne(db, sql: "SELECT * FROM apps WHERE item_id = ?", arguments: [itemId])
                        
                        let imageResult = try Row.fetchOne(db, sql: "SELECT * FROM image_cache WHERE item_id = ?", arguments: [itemId])
                        
                        
                        let title: String? = app?["title"]
                        let bundleId: String? = app?["bundleid"]
                        
                        let image: Data? = imageResult?["image_data"]
                        
                        if let parentId = parentId {
                            let index = appDatas.firstIndex(where: { $0.itemId == (parentId - 1) })
                            if index != nil {
                                print(index!)
                                appDatas[index!].groupedApps.append(AppData(itemId: itemId, title: title, bundleId: bundleId, imageData: image))
                            }else {
                                if title != nil {
                                    appDatas.append(AppData(itemId: itemId, title: title, bundleId: bundleId, imageData: image))
                                } else if let image = image {
                                    appDatas.append(AppData(itemId: itemId, title: title, bundleId: bundleId, imageData: image))
                                }
                            }
                        } else {
                            if title != nil {
                                appDatas.append(AppData(itemId: itemId, title: title, bundleId: bundleId, imageData: image))
                            }
                        }
                    }
                }
            }
            
            
        } catch {
            errorMesage = error.localizedDescription
            
            appDatas.removeAll()
        }
    }
    
    func runShellWithArgs(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
    
}

#Preview {
    ContentView()
}
