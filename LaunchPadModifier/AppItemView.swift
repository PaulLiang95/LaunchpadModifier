//
//  AppItemView.swift
//  TestSqlite
//
//  Created by 梁湘辉 on 2023/12/19.
//

import SwiftUI

struct AppItemView: View {
    
    let app: AppData
    
    var body: some View {
        VStack {
            HStack {
                if let image = app.imageData {
                    Image(nsImage: NSImage(data: image)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 99)
                } else if !app.groupedApps.isEmpty {
                    VStack {
                        HStack {
                            if 0 < app.groupedApps.count && app.groupedApps[0].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[0].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 1 < app.groupedApps.count && app.groupedApps[1].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[1].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 2 < app.groupedApps.count && app.groupedApps[2].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[2].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                        }
                        
                        HStack {
                            if 3 < app.groupedApps.count && app.groupedApps[3].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[3].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 4 < app.groupedApps.count && app.groupedApps[4].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[4].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 5 < app.groupedApps.count && app.groupedApps[5].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[5].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                        }
                        
                        HStack {
                            if 6 < app.groupedApps.count && app.groupedApps[6].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[6].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 7 < app.groupedApps.count && app.groupedApps[7].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[7].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                            
                            if 8 < app.groupedApps.count && app.groupedApps[8].imageData != nil {
                                Image(nsImage: NSImage(data: app.groupedApps[8].imageData!)!)
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                Spacer()
                            }
                        }
                    }
                    .frame(width: 99, height: 99)
                } else {
                    Image(systemName: "wrongwaysign")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 99)
                }
                
                
                VStack(alignment: .leading) {
                    if !app.groupedApps.isEmpty {
                        Text("分组名称：" + (app.title ?? "未命名"))
                        Text("Row ID： " + (app.itemId?.description ?? "NULL"))
                        Text("分组内APP数量：" + (app.groupedApps.count.description))
                    } else {
                        Text("应用名称：" + (app.title ?? "未命名"))
                        Text("Row ID： " + (app.itemId?.description ?? "NULL"))
                        Text("应用ID：" + (app.bundleId ?? "无ID"))
                    }
                }
                Spacer()
            }
            .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            Rectangle()
                .background(Color.gray)
                .frame(height: 1)
        }
    }
}

#Preview {
    ContentView()
}
