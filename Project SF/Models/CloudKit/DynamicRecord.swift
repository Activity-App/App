//
//  DynamicRecord.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

/// By conforming do DynamicRecord, you can define your Record using a Model struct. See [UserRecord](x-source-tag://UserRecord) for an example.
@dynamicMemberLookup
protocol DynamicRecord: Record, AnyObject {
    
    associatedtype Model
    
    static var model: Model { get }
    
    subscript<Type>(dynamicMember keyPath: KeyPath<Model, ModelItem<Type>>) -> Type? { get set }
    
}

extension DynamicRecord {
    
    // possibly abuse of this api
    subscript<Type>(dynamicMember keyPath: KeyPath<Model, ModelItem<Type>>) -> Type? {
        get {
            // TODO: investigate runtime cost of this
            let key = Self.model[keyPath: keyPath].key
            
            if let value = record[key] {
                guard let value = value as? Type else {
                    preconditionFailure("Type mismatch")
                }
                
                return value
            } else {
                return nil
            }
            
        }
        set {
            let key = Self.model[keyPath: keyPath].key
            
            record[key] = newValue as? __CKRecordObjCValue
        }
    }
    
}

struct ModelItem<Type> {
    
    fileprivate let key: String
    
    init(key: String) {
        self.key = key
    }
    
}
