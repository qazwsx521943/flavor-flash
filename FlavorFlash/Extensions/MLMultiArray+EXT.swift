//
//  MLMultiArray+EXT.swift
//  FlavorFlash
//
//  Created by 鍾哲玄 on 2023/12/7.
//

import UIKit
import CoreML

extension MLMultiArray {
	private func _image<T: MultiArrayType>(min: T,
										   max: T,
										   channel: Int?,
										   axes: (Int, Int, Int)?) -> CGImage? {

		// swiftlint:disable identifier_name
		if let (b, w, h, c) = toRawBytes(min: min, max: max, channel: channel, axes: axes) {
			if c == 1 {
				return CGImage.fromByteArrayGray(b, width: w, height: h)
			} else {
				return CGImage.fromByteArrayRGBA(b, width: w, height: h)
			}
		}
		return nil
	}

	public func cgImage(min: Double = 0,
						max: Double = 255,
						channel: Int? = nil,
						axes: (Int, Int, Int)? = nil) -> CGImage? {
		switch self.dataType {
		case .double:
			return _image(min: min, max: max, channel: channel, axes: axes)
		case .float32:
			return _image(min: Float(min), max: Float(max), channel: channel, axes: axes)
		case .int32:
			return _image(min: Int32(min), max: Int32(max), channel: channel, axes: axes)
		@unknown default:
			fatalError("Unsupported data type \(dataType.rawValue)")
		}
	}

	public func image(min: Double = 0,
					  max: Double = 255,
					  channel: Int? = nil,
					  axes: (Int, Int, Int)? = nil) -> UIImage? {
		let cgImg = cgImage(min: min, max: max, channel: channel, axes: axes)
		return cgImg.map { UIImage(cgImage: $0) }
	}

	public func toRawBytes<T: MultiArrayType>(min: T,
											  max: T,
											  channel: Int? = nil,
											  axes: (Int, Int, Int)? = nil)
	// swiftlint:disable large_tuple
	-> (bytes: [UInt8], width: Int, height: Int, channels: Int)? {
		// MLMultiArray with unsupported shape?
		if shape.count < 2 {
			print("Cannot convert MLMultiArray of shape \(shape) to image")
			return nil
		}

		// Figure out which dimensions to use for the channels, height, and width.
		let channelAxis: Int
		let heightAxis: Int
		let widthAxis: Int
		if let axes = axes {
			channelAxis = axes.0
			heightAxis = axes.1
			widthAxis = axes.2
			guard channelAxis >= 0 && channelAxis < shape.count &&
					heightAxis >= 0 && heightAxis < shape.count &&
					widthAxis >= 0 && widthAxis < shape.count else {
				print("Invalid axes \(axes) for shape \(shape)")
				return nil
			}
		} else if shape.count == 2 {
			// Expected shape for grayscale is (height, width)
			heightAxis = 0
			widthAxis = 1
			channelAxis = -1 // Never be used
		} else {
			// Expected shape for color is (channels, height, width)
			channelAxis = 0
			heightAxis = 1
			widthAxis = 2
		}

		let height = self.shape[heightAxis].intValue
		let width = self.shape[widthAxis].intValue
		let yStride = self.strides[heightAxis].intValue
		let xStride = self.strides[widthAxis].intValue

		let channels: Int
		let cStride: Int
		let bytesPerPixel: Int
		let channelOffset: Int

		// MLMultiArray with just two dimensions is always grayscale. (We ignore
		// the value of channelAxis here.)
		if shape.count == 2 {
			channels = 1
			cStride = 0
			bytesPerPixel = 1
			channelOffset = 0

			// MLMultiArray with more than two dimensions can be color or grayscale.
		} else {
			let channelDim = self.shape[channelAxis].intValue
			if let channel = channel {
				if channel < 0 || channel >= channelDim {
					print("Channel must be -1, or between 0 and \(channelDim - 1)")
					return nil
				}
				channels = 1
				bytesPerPixel = 1
				channelOffset = channel
			} else if channelDim == 1 {
				channels = 1
				bytesPerPixel = 1
				channelOffset = 0
			} else {
				if channelDim != 3 && channelDim != 4 {
					print("Expected channel dimension to have 1, 3, or 4 channels, got \(channelDim)")
					return nil
				}
				channels = channelDim
				bytesPerPixel = 4
				channelOffset = 0
			}
			cStride = self.strides[channelAxis].intValue
		}

		// Allocate storage for the RGBA or grayscale pixels. Set everything to
		// 255 so that alpha channel is filled in if only 3 channels.
		let count = height * width * bytesPerPixel
		var pixels = [UInt8](repeating: 255, count: count)

		// Grab the pointer to MLMultiArray's memory.
		var ptr = UnsafeMutablePointer<T>(OpaquePointer(self.dataPointer))
		ptr = ptr.advanced(by: channelOffset * cStride)

		// Loop through all the pixels and all the channels and copy them over.
		for c in 0..<channels {
			for y in 0..<height {
				for x in 0..<width {
					let value = ptr[c*cStride + y*yStride + x*xStride]
					let scaled = (value - min) * T(255) / (max - min)
					let pixel = clamp(scaled, min: T(0), max: T(255)).toUInt8
					pixels[(y*width + x)*bytesPerPixel + c] = pixel
				}
			}
		}
		return (pixels, width, height, channels)
	}
}

public func clamp<T: Comparable>(_ x: T, min: T, max: T) -> T {
	if x < min { return min }
	if x > max { return max }
	return x
}
