//
//  TSSettingsIndex.swift
//  TrollSpeed
//
//  Created by Lessica on 2024/1/25.
//

import Foundation

enum TSSettingsIndex: Int, CaseIterable {
  //  case passthroughMode = 0
  //  case keepInPlace
    case hideAtSnapshot
    /*case singleLineMode
    case usesInvertedColor
    case usesRotation
    case usesLargeFont
    case usesArrowPrefixes
    case usesBitrate*/
    
    //ESP
    case PlayerLine
    case PlayerBone
    case PlayerInfo
    case PlayerHP
    
    
    var key: String {
        switch self {
        case .hideAtSnapshot:
            return HUDUserDefaultsKeyHideAtSnapshot
            //ESP
        case .PlayerLine:
            return HUDUserDefaultsKeyPlayerLine
        case .PlayerBone:
            return HUDUserDefaultsKeyPlayerBone
        case .PlayerInfo:
            return HUDUserDefaultsKeyPlayerInfo
        case .PlayerHP:
            return HUDUserDefaultsKeyPlayerHP
        }
    }

    var title: String {
        switch self {
        case .hideAtSnapshot:
            return "过直播"
        
        case .PlayerLine:
            return "射线"
        case .PlayerBone:
            return "骨骼"
        case .PlayerInfo:
            return "信息"
        case .PlayerHP:
            return "血量"
            
            
        }
    }

    func subtitle(highlighted: Bool, restartRequired: Bool) -> String {
        switch self {
            //人物射线
        case .hideAtSnapshot: fallthrough
   
        case .PlayerLine:
            return highlighted ? "打开" : "关闭"
        case .PlayerBone:
            return highlighted ? "打开" : "关闭"
        case .PlayerInfo:
            return highlighted ? "打开" : "关闭"
        case .PlayerHP:
            return highlighted ? "打开" : "关闭"
        }
    }
}
