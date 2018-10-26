import Cocoa
import CoreImage

enum RotateAnchor: Int {
    case imageTopLeft = 0
    case imageTop
    case imageTopRight
    case imageLeft
    case center
    case imageRight
    case imageBottomLeft
    case imageBottom
    case imageBottomRight
//    case left
//    case right
//    case top
//    case bottom
}

class DrawingView: NSView {
    
    var imageSize = NSSize(width: 100, height: 100) {
        didSet { needsDisplay = true }
    }
    
    var degree: CGFloat = 0 {
        didSet { needsDisplay = true }
    }
    
    var drawGuide: Bool = true {
        didSet { needsDisplay = true }
    }
    
    var anchor: RotateAnchor = .center {
        didSet { needsDisplay = true }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        drawBackground(in: dirtyRect)
        
        let image = generateImage(of: imageSize)
        
        let drawRect = image.draw(at: dirtyRect.center, anchor: anchor, rotateDegree: degree)
        
        if drawGuide {
            drawGuide(in: dirtyRect, guideRects: [
                (drawRect, .systemGreen)
            ])
        }
    }
    
    func drawBackground(in rect: NSRect) {
        let path = NSBezierPath(rect: rect)
        NSColor.quaternaryLabelColor.setFill()
        path.fill()
        NSColor.tertiaryLabelColor.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
    
    func generateImage(of size: NSSize) -> NSImage {
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        let rect = NSRect(origin: .zero, size: size)
        
        let path = NSBezierPath(rect: rect)
        NSColor.systemRed.withAlphaComponent(0.5).setFill()
        path.fill()
        
        path.move(to: rect.topLeft)
        path.line(to: rect.bottomRight)
        path.move(to: rect.topRight)
        path.line(to: rect.bottomLeft)
        path.move(to: rect.top)
        path.line(to: rect.bottom)
        path.move(to: rect.left)
        path.line(to: rect.right)
        NSColor.systemRed.withAlphaComponent(0.5).setStroke()
        path.stroke()
        
        image.unlockFocus()
        
        return image
    }
    
    func drawGuide(in rect: NSRect, guideRects: [(NSRect, NSColor)]) {
        
        let path = NSBezierPath()
        path.lineWidth = 1
        
        path.move(to: NSPoint(x: rect.minX, y: rect.midY))
        path.line(to: NSPoint(x: rect.maxX, y: rect.midY))
        path.move(to: NSPoint(x: rect.midX, y: rect.minY))
        path.line(to: NSPoint(x: rect.midX, y: rect.maxY))
        NSColor.cyan.withAlphaComponent(0.5).setStroke()
        path.stroke()
        
        guideRects.forEach { rect, color in
            let path = NSBezierPath()
            path.lineWidth = 1
            path.move(to: rect.topLeft)
            path.line(to: rect.topRight)
            path.line(to: rect.bottomRight)
            path.line(to: rect.bottomLeft)
            path.line(to: rect.topLeft)
            color.withAlphaComponent(0.5).setStroke()
            path.stroke()
        }
    }
}

extension NSImage {
    @discardableResult
    func draw(at point: NSPoint, anchor: RotateAnchor = .center, rotateDegree degree: CGFloat = 0) -> NSRect {
        
        let angle = degree * CGFloat.pi / 180
        let newSize = NSRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: angle)).size
        
        let x: CGFloat
        let y: CGFloat
        switch anchor {
        case .center:
            x = point.x - newSize.width / 2
            y = point.y - newSize.height / 2
//        case .left:
//            x = point.x
//            y = point.y - newSize.height / 2
//        case .right:
//            x = point.x - newSize.width
//            y = point.y - newSize.height / 2
//        case .top:
//            x = point.x - newSize.width / 2
//            y = point.y - newSize.height
//        case .bottom:
//            x = point.x - newSize.width / 2
//            y = point.y
        case .imageTop:
            x = point.x - newSize.width / 2 + size.height / 2 * sin(angle)
            y = point.y - newSize.height / 2 - size.height / 2 * cos(angle)
        case .imageLeft:
            x = point.x - newSize.width / 2 + size.width / 2 * cos(angle)
            y = point.y - newSize.height / 2 + size.width / 2 * sin(angle)
        case .imageRight:
            x = point.x - newSize.width / 2 - size.width / 2 * cos(angle)
            y = point.y - newSize.height / 2 - size.width / 2 * sin(angle)
        case .imageBottom:
            x = point.x - newSize.width / 2 - size.height / 2 * sin(angle)
            y = point.y - newSize.height / 2 + size.height / 2 * cos(angle)
        case .imageTopLeft:
            x = point.x - newSize.width / 2
            y = point.y - newSize.height / 2
        case .imageTopRight:
            x = point.x - newSize.width / 2
            y = point.y - newSize.height / 2
        case .imageBottomLeft:
            x = point.x - newSize.width / 2
            y = point.y - newSize.height / 2
        case .imageBottomRight:
            x = point.x - newSize.width / 2
            y = point.y - newSize.height / 2
        }
        
        let drawRect = NSRect(x: x, y: y, width: newSize.width, height: newSize.height)
        
        guard let data = tiffRepresentation else { return drawRect }
        
        var ciImage = CIImage(data: data)!
        ciImage = ciImage.transformed(by: CGAffineTransform(rotationAngle: angle))
        let newImage = NSImage(size: newSize)
        newImage.addRepresentation(NSCIImageRep(ciImage: ciImage))
        
        newImage.draw(in: drawRect)
        
        return drawRect
    }
}

extension NSRect {
    var topLeft: NSPoint {
        return NSPoint(x: minX, y: maxY)
    }
    
    var topRight: NSPoint {
        return NSPoint(x: maxX, y: maxY)
    }
    
    var bottomLeft: NSPoint {
        return NSPoint(x: minX, y: minY)
    }
    
    var bottomRight: NSPoint {
        return NSPoint(x: maxX, y: minY)
    }
    
    var top: NSPoint {
        return NSPoint(x: midX, y: maxY)
    }
    
    var bottom: NSPoint {
        return NSPoint(x: midX, y: minY)
    }
    
    var left: NSPoint {
        return NSPoint(x: minX, y: midY)
    }
    
    var right: NSPoint {
        return NSPoint(x: maxX, y: midY)
    }
    
    var center: NSPoint {
        return NSPoint(x: midX, y: midY)
    }
}
