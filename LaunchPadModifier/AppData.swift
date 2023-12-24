//
//  AppData.swift
//  LaunchPadModifier
//
//  Created by 梁湘辉 on 2023/12/24.
//

import Foundation


struct AppData: Identifiable, Hashable, Codable {
    var id = UUID()
    
    var itemId: Int?
    
    var title: String?
    
    var bundleId: String?
    
    var imageData: Data?
    
    var groupedApps: [AppData] = []
    
    var isGroup = false
    
}
