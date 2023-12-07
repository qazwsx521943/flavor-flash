//
//  MLMultiArray+Helpers.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/7.
//

import CoreML

public protocol MultiArrayType: Comparable {
	static var multiArrayDataType: MLMultiArrayDataType { get }
	static func +(lhs: Self, rhs: Self) -> Self
	static func -(lhs: Self, rhs: Self) -> Self
	static func *(lhs: Self, rhs: Self) -> Self
	static func /(lhs: Self, rhs: Self) -> Self
	init(_: Int)
	var toUInt8: UInt8 { get }
}

extension Double: MultiArrayType {
	public static var multiArrayDataType: MLMultiArrayDataType { return .double }
	public var toUInt8: UInt8 { return UInt8(self) }
}

extension Float: MultiArrayType {
	public static var multiArrayDataType: MLMultiArrayDataType { return .float32 }
	public var toUInt8: UInt8 { return UInt8(self) }
}

extension Int32: MultiArrayType {
	public static var multiArrayDataType: MLMultiArrayDataType { return .int32 }
	public var toUInt8: UInt8 { return UInt8(self) }
}
