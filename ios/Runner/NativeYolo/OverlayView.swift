//
//  OverlayView.swift
//  Runner
//
//  Created by Didi abel on 25/12/2025.
//


import UIKit

class OverlayView: UIView {
    var results: [BoundingBox] = [] {
        didSet {
            DispatchQueue.main.async {
                self.setNeedsDisplay()
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // 1. Calculate Average Eye Radius
        let eyes = results.filter {
            $0.clsName.lowercased().contains("eye") || $0.clsName.lowercased().contains("pupil")
        }

        var avgEyeRadius: CGFloat = 0
        if !eyes.isEmpty {
            let sumRadius = eyes.reduce(0.0) { result, box in
                let w = CGFloat(box.w) * rect.width
                let h = CGFloat(box.h) * rect.height
                return result + max(w / 2.0, h / 2.0)
            }
            avgEyeRadius = sumRadius / CGFloat(eyes.count)
        }

        for box in results {
            let cx = CGFloat(box.cx) * rect.width
            let cy = CGFloat(box.cy) * rect.height
            
            let isEye = box.clsName.lowercased().contains("eye") || box.clsName.lowercased().contains("pupil")
            
            // Radius logic mirroring Android
            let radius: CGFloat
            if isEye && avgEyeRadius > 0 {
                radius = avgEyeRadius
            } else {
                let w = CGFloat(box.w) * rect.width
                let h = CGFloat(box.h) * rect.height
                radius = max(w / 2.0, h / 2.0)
            }

            // Draw Circle
            context.setStrokeColor(UIColor.green.cgColor) // Adjust color to match your Android resource
            context.setLineWidth(2.0)
            context.addArc(center: CGPoint(x: cx, y: cy), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            context.strokePath()

            // Draw Center Dot
            context.setFillColor(UIColor.cyan.cgColor)
            context.addArc(center: CGPoint(x: cx, y: cy), radius: 2.0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            context.fillPath()
        }
    }
}