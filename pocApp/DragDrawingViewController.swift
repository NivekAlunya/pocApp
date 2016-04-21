//
//  ViewController.swift
//  pocApp
//
//  Created by Kevin Launay on 4/20/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class DragDrawingViewController: UIViewController {
    
    @IBOutlet var iv: UIImageView!
    
    @IBOutlet var topPositionImage: NSLayoutConstraint!
    @IBOutlet var leftPositionImage: NSLayoutConstraint!
    
    @IBOutlet var heightImage: NSLayoutConstraint!
    @IBOutlet var widthImage: NSLayoutConstraint!
    
    @IBAction func animate(sender: UIButton) {
        moveImage()
    }
    
    @IBAction func rotate(sender: UIButton) {
        rotateImage()
    }
    
    @IBAction func zoom(sender: UIButton) {
        zoomImage()
    }
    
    @IBAction func dragImage(pan: UIPanGestureRecognizer) {
        guard let view = pan.view else {
            return
        }
        translate(pan.translationInView(self.view), view: view, inView: self.view)
        pan.setTranslation(CGPointZero, inView: self.view)
        if (pan.state == .Ended) {
            brake(pan.velocityInView(self.view), view: view, inView: self.view)
        }
    }
    
    var scale = CGFloat(1.0)
    @IBAction func pinchImage(pinch: UIPinchGestureRecognizer) {
        print("scale: \(pinch.scale)")
        print("velocity :\(pinch.velocity)")
        print("bounds: \(pinch.view!.bounds)")
        print("frame: \(pinch.view!.frame)")
        iv.transform = CGAffineTransformScale(self.iv.transform, pinch.scale, pinch.scale)
        
        let scaleH = sqrt(pow(iv.transform.a, 2.0) + pow(iv.transform.c, 2.0))
        let scaleV = sqrt(pow(iv.transform.b, 2.0) + pow(iv.transform.d, 2.0))
        pinch.scale = 1.0
        if pinch.state == .Ended {
            let area = CGRect(origin: iv.bounds.origin, size: CGSizeMake(iv.bounds.width * scaleH , iv.bounds.height * scaleV))
            iv.image = putImageInRect(image: image, inRect: area)
            restoreConstraintsForImage()
        }
    }
    
    var rotation = CGFloat(0.0)
    @IBAction func rotationImage(rotation: UIRotationGestureRecognizer) {
        print("rotation: \(rotation.rotation)")
        print("velocity :\(rotation.velocity)")
        print("bounds: \(rotation.view!.bounds)")
        print("frame: \(rotation.view!.frame)")
        self.rotation += rotation.rotation
        let angle = atan2(iv.transform.b, iv.transform.a)
        print("angle: \(angle)")
        rotate(rotation.view!, radians: rotation.rotation)
        rotation.rotation = 0
    }
    
    func rotate(view:UIView, radians: CGFloat) {
        view.transform = CGAffineTransformRotate(view.transform, radians)
    }
    
    func brake(velocity: CGPoint, view: UIView, inView: UIView) {
        print(velocity)
        let magnitude = sqrt(pow(velocity.x, 2.0) + pow(velocity.y, 2.0))
        let multiplier = magnitude / 200
        print(multiplier)
        
        let factor = multiplier / 100
        
        let finalPoint = dragInbounds(view, inView: self.view, toPoint: CGPoint(x: view.center.x + velocity.x * factor, y: view.center.y + velocity.y * factor))
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            view.center = finalPoint
            self.restoreConstraintsForImage()
        }) { (animationStopped) in
            
        }
    }
    
    func dragInbounds(drag: UIView, inView view:UIView, toPoint point: CGPoint) -> CGPoint {
        var endPoint = CGPoint()
        
        endPoint.x = min(max(point.x, drag.frame.width / 2), view.bounds.size.width - drag.frame.width / 2)
        endPoint.y = min(max(point.y, drag.frame.height / 2), view.bounds.size.height - drag.frame.height / 2)
        
        return endPoint
    }
    
    func translate(translation: CGPoint, view: UIView, inView: UIView) {
        view.center = dragInbounds(view, inView: inView, toPoint: CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y))
    }
    
    func restoreConstraintsForImage() {
        topPositionImage.constant = iv.center.y - heightImage.constant / 2
        leftPositionImage.constant = iv.center.x - widthImage.constant / 2
    }
    
    func zoomImage(delay:Double = 0.0) {
        UIView.animateWithDuration(1.0, delay: delay, options: [], animations: {
            self.iv.transform = CGAffineTransformScale(self.iv.transform, 0.5, 0.5)
        }) { animationStopped in
            print(animationStopped)
            print("\(self.iv.frame.width)x\(self.iv.frame.height)")
        }
    }
    
    func rotateImage(delay:Double = 0.0) {
        UIView.animateWithDuration(1.0, delay: delay, options: [], animations: {
            self.iv.transform = CGAffineTransformRotate(self.iv.transform, 180.degreesToRadians)
            }, completion: nil)
    }
    
    
    func moveImage(delay:Double = 0.0) {
        let originLeftPositionImage = leftPositionImage.constant
        let originTopPositionImage = topPositionImage.constant
        leftPositionImage.constant = iv.frame.width * -1
        topPositionImage.constant = iv.frame.height * -1
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(1.0, delay: delay, options: .CurveEaseInOut, animations: {
            
            self.topPositionImage.constant = originTopPositionImage
            self.leftPositionImage.constant = originLeftPositionImage
            
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        moveImage(1.0)
        
        //        let components = NSURLComponents(string: "http://192.168.0.15:8080/images/brittny-ward/brittny-ward-double-trouble-nude/Premium/308418_full.jpg")
        let components = NSURLComponents(string: "http://192.168.0.15:8080/images/brittny-ward/brittny-ward-double-trouble-nude/Premium/308417_full.jpg")
        //        let components = NSURLComponents(string: "http://192.168.0.15:8080/images/brittny-ward/brittny-ward-double-trouble-nude/Premium/308418_full_small.jpg")
        //        let components = NSURLComponents(string: "http://192.168.0.15:8080/images/brittny-ward/brittny-ward-double-trouble-nude/Premium/308417_full_small.jpg")
        
        guard let url = components?.URL
            , data = NSData(contentsOfURL: url) else {
                return
        }
        
        if let img = UIImage(data: data) {
            
            image = img
            
            iv.image = putImageInRect(image: image, inRect: iv.bounds)
            
            iv.backgroundColor = UIColor.blackColor()
            
        }
        
    }
    
    func putImageInRect(image img: UIImage, inRect area: CGRect) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(area.size, false, 0.0)
        
        //            let path = UIBezierPath(rect: CGRectMake(128, 128, 180.0, 120.0))
        //
        //            path.addClip()
        //
        
        var offset: CGFloat
        var rect = CGRectZero
        
        let ratioW = img.size.width / area.width
        
        let ratioH = img.size.height / area.height
        
        print("\(ratioW) : \(ratioH)")
        
        if ratioW > ratioH  {
            var height: CGFloat
            height = img.size.height / (ratioW)
            offset = (area.height - height) / 2
            rect = CGRectMake(0, offset, area.width , height)
            
        } else {
            var width: CGFloat
            width = img.size.width  / ratioH
            offset = (area.width - width) / 2
            rect = CGRectMake(offset, 0, width , area.height)
        }
        
        img.drawInRect(rect)
        
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return thumb
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension DragDrawingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

