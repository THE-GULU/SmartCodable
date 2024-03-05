//
//  SmartEncodable.swift
//  SmartCodable
//
//  Created by qixin on 2023/9/4.
//

import Foundation


/// Smart的编码协议
public protocol SmartEncodable: Encodable { }


extension SmartEncodable {
    
    /// 序列化为字典
    /// - Returns: 字典
    public func toDictionary() -> [String: Any]? {
        return _transformToJson(self, type: Self.self)
    }
    
    
    /// 序列化为Json字符串
    /// - Parameter prettyPrint: 是否格式化打印（json中会添加换行符号）
    /// - Returns: Json字符串
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        
        // 首先尝试将 self 直接转换为 [String: Any] 类型的字典
        if let jsonObject = self as? [String: Any] {
            return _transformToJsonString(object: jsonObject, prettyPrint: prettyPrint, type: Self.self)
        }
        
        if let anyObject = toDictionary() {
            return _transformToJsonString(object: anyObject, prettyPrint: prettyPrint, type: Self.self)
        }
        return nil
    }
    
}



extension Array where Element: SmartEncodable {
    /// 序列化为数组
    /// - Returns: 数组数据
    public func toArray() -> [Any]? {
        return _transformToJson(self,type: Element.self)
    }
    
    
    /// 转成Json字符串
    /// - Parameter prettyPrint: 是否格式化打印（json中会添加换行符号）
    /// - Returns: json字符串
    public func toJSONString(prettyPrint: Bool = false) -> String? {
        if let anyObject = toArray() {
            return _transformToJsonString(object: anyObject, prettyPrint: prettyPrint, type: Element.self)
        }
        return nil
    }
}


fileprivate func _transformToJsonString(object: Any, prettyPrint: Bool = false, type: Any.Type) -> String? {
    if JSONSerialization.isValidJSONObject(object) {
        do {
            let options: JSONSerialization.WritingOptions = prettyPrint ? [.prettyPrinted] : []
            let jsonData = try JSONSerialization.data(withJSONObject: object, options: options)
            return String(data: jsonData, encoding: .utf8)
            
        } catch {
            SmartLog.logError(error, className: "\(type)")
        }
    } else {
        SmartLog.logDebug("\(object)) is not a valid JSON Object", className: "\(type)")
    }
    return nil
}


fileprivate func _transformToJson<T>(_ some: Encodable, type: Any.Type) -> T? {
    let jsonEncoder = JSONEncoder()
    if let jsonData = try? jsonEncoder.encode(some) {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            
            if let temp = json as? T {
                return temp
            } else {
                SmartLog.logDebug("\(json)) is not a valid Type", className: "\(type)")
            }
        } catch {
            SmartLog.logError(error, className: "\(type)")
        }
    }
    return nil
}
