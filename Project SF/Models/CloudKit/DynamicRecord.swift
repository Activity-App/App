//
//  DynamicRecord.swift
//  Project SF
//
//  Created by William Taylor on 12/7/20.
//

import Foundation
import CloudKit

@dynamicMemberLookup
protocol DynamicRecord: Record, AnyObject {
    
    associatedtype Model: ModelProtocol
    
    static var model: Model { get }
    
    subscript<Type>(dynamicMember keyPath: KeyPath<Model, ModelItem<Type>>) -> Type? { get set }
    
}

extension DynamicRecord {
    
    subscript<Type>(dynamicMember keyPath: KeyPath<Model, ModelItem<Type>>) -> Type? {
        get {
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

protocol ModelProtocol {
    
    init()
    
}

struct ModelItem<Type> {
    
    fileprivate let key: String
    
    init(key: String) {
        self.key = key
    }
    
}
