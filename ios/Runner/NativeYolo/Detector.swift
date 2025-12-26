import Foundation
import TensorFlowLite
import CoreImage
import UIKit

class Detector {
    private var interpreter: Interpreter?
    private var labels: [String] = []
    
    // --- THREAD SAFETY LOCK ---
    private let lock = NSLock()
    
    private let confidenceThreshold: Float = 0.5
    private let iouThreshold: Float = 0.5
    private let inputMean: Float = 0.0
    private let inputStd: Float = 255.0
    
    private var inputWidth = 640
    private var inputHeight = 640
    private var outputChannels = 0
    private var outputElements = 0
    
    // Reuse context for performance
    private let ciContext = CIContext()
    
    init(modelPath: String, labelPath: String) {
        loadModel(modelPath: modelPath)
        loadLabels(labelPath: labelPath)
    }

    private func loadModel(modelPath: String) {
        do {
            var options = Interpreter.Options()
            options.threadCount = 4
            interpreter = try Interpreter(modelPath: modelPath, options: options)
            try interpreter?.allocateTensors()
            
            if let inputTensor = try interpreter?.input(at: 0) {
                let shape = inputTensor.shape.dimensions
                if shape.count == 4 {
                    inputWidth = shape[1]
                    inputHeight = shape[2]
                }
            }
            
            if let outputTensor = try interpreter?.output(at: 0) {
                let shape = outputTensor.shape.dimensions
                if shape.count == 3 {
                    outputChannels = shape[1]
                    outputElements = shape[2]
                }
            }
        } catch {
            print("Error loading model: \(error)")
        }
    }
    
    private func loadLabels(labelPath: String) {
        do {
            let content = try String(contentsOfFile: labelPath)
            labels = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        } catch {
            print("Error loading labels: \(error)")
        }
    }

    func detect(image: UIImage) -> (boxes: [BoundingBox], time: Double) {
        // Resize image to model dimensions
        guard let pixelBuffer = image.pixelBuffer(width: inputWidth, height: inputHeight) else {
            return ([], 0)
        }
        return runInference(pixelBuffer: pixelBuffer)
    }
    
    func detect(pixelBuffer: CVPixelBuffer) -> (boxes: [BoundingBox], time: Double) {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // If buffer matches model size, run directly
        if width == inputWidth && height == inputHeight {
            return runInference(pixelBuffer: pixelBuffer)
        }
        
        // Otherwise resize via CoreImage/UIImage flow
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return ([], 0)
        }
        let image = UIImage(cgImage: cgImage)
        
        return detect(image: image)
    }
    
    private func runInference(pixelBuffer: CVPixelBuffer) -> (boxes: [BoundingBox], time: Double) {
        // --- CRITICAL FIX: PREVENT CONCURRENT ACCESS ---
        lock.lock()
        defer { lock.unlock() }
        // -----------------------------------------------
        
        guard let interpreter = interpreter else { return ([], 0) }
        
        let startTime = Date()
        
        do {
            let inputData = preprocess(pixelBuffer)
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            
            let outputTensor = try interpreter.output(at: 0)
            let outputData = outputTensor.data
            let floats = outputData.toArray(type: Float.self)
            
            let boxes = bestBox(floats: floats)
            let timeElapsed = Date().timeIntervalSince(startTime) * 1000
            
            return (boxes, timeElapsed)
        } catch {
            print("Inference error: \(error)")
            return ([], 0)
        }
    }
    
    private func preprocess(_ buffer: CVPixelBuffer) -> Data {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else { return Data() }
        let width = CVPixelBufferGetWidth(buffer)
        let height = CVPixelBufferGetHeight(buffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        var data = Data(capacity: width * height * 3 * 4)
        
        for y in 0..<height {
            let rowStart = baseAddress + y * bytesPerRow
            for x in 0..<width {
                let offset = x * 4
                
                if offset + 2 < bytesPerRow {
                     // BGRA Input from Camera/UIImage
                     let b = Float(rowStart.load(fromByteOffset: offset, as: UInt8.self))
                     let g = Float(rowStart.load(fromByteOffset: offset + 1, as: UInt8.self))
                     let r = Float(rowStart.load(fromByteOffset: offset + 2, as: UInt8.self))
                     
                     // Normalize to 0..1 (RGB Model Input)
                     var rf = (r - inputMean) / inputStd
                     var gf = (g - inputMean) / inputStd
                     var bf = (b - inputMean) / inputStd
                     
                     withUnsafeBytes(of: &rf) { data.append(contentsOf: $0) }
                     withUnsafeBytes(of: &gf) { data.append(contentsOf: $0) }
                     withUnsafeBytes(of: &bf) { data.append(contentsOf: $0) }
                }
            }
        }
        return data
    }
    
    private func bestBox(floats: [Float]) -> [BoundingBox] {
        var boundingBoxes: [BoundingBox] = []
        if floats.count < outputChannels * outputElements { return [] }
        
        for c in 0..<outputElements {
            var maxConf: Float = -1.0
            var maxIdx = -1
            var j = 4
            
            while j < outputChannels {
                let arrayIdx = j * outputElements + c
                if arrayIdx < floats.count {
                    let val = floats[arrayIdx]
                    if val > maxConf {
                        maxConf = val
                        maxIdx = j - 4
                    }
                }
                j += 1
            }
            
            if maxConf > confidenceThreshold {
                let clsName = (maxIdx >= 0 && maxIdx < labels.count) ? labels[maxIdx] : "unknown"
                
                let cx = floats[0 * outputElements + c]
                let cy = floats[1 * outputElements + c]
                let w = floats[2 * outputElements + c]
                let h = floats[3 * outputElements + c]
                
                let x1 = cx - (w / 2.0)
                let y1 = cy - (h / 2.0)
                let x2 = cx + (w / 2.0)
                let y2 = cy + (h / 2.0)
                
                if x1 >= 0 && x1 <= 1 && y1 >= 0 && y1 <= 1 {
                    boundingBoxes.append(BoundingBox(
                        x1: x1, y1: y1, x2: x2, y2: y2,
                        cx: cx, cy: cy, w: w, h: h,
                        cnf: maxConf, cls: maxIdx, clsName: clsName
                    ))
                }
            }
        }
        return applyNMS(boxes: boundingBoxes)
    }
    
    private func applyNMS(boxes: [BoundingBox]) -> [BoundingBox] {
        var sorted = boxes.sorted { $0.cnf > $1.cnf }
        var selected: [BoundingBox] = []
        while !sorted.isEmpty {
            let first = sorted.removeFirst()
            selected.append(first)
            sorted = sorted.filter { calculateIoU(box1: first, box2: $0) < iouThreshold }
        }
        return selected
    }
    
    private func calculateIoU(box1: BoundingBox, box2: BoundingBox) -> Float {
        let x1 = max(box1.x1, box2.x1); let y1 = max(box1.y1, box2.y1)
        let x2 = min(box1.x2, box2.x2); let y2 = min(box1.y2, box2.y2)
        let intersection = max(0, x2 - x1) * max(0, y2 - y1)
        let union = (box1.w * box1.h) + (box2.w * box2.h) - intersection
        return union > 0 ? intersection / union : 0
    }
}

extension Data {
    func toArray<T>(type: T.Type) -> [T] {
        return self.withUnsafeBytes {
            Array(UnsafeBufferPointer<T>(start: $0.bindMemory(to: type).baseAddress!, count: self.count / MemoryLayout<T>.stride))
        }
    }
}

extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let image = resizedImage, let cgImage = image.cgImage else { return nil }
        
        let options: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pxBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, options as CFDictionary, &pxBuffer)
        
        guard let buffer = pxBuffer else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
