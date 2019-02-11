/// Copyright (c) 2019年 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

@IBDesignable public class Knob: UIControl {
  
  public var minimumValue: Float = 0
  public var maximumValue: Float = 1
  
  public var value: Float = 0
  private let renderer = KnobRenderer()
  
  public var isContinuous = true
  
  @IBInspectable public var lineWidth: CGFloat{
    get { return renderer.lineWidth }
    set { renderer.lineWidth = newValue }
  }
  
  public var startAngle: CGFloat{
    get { return renderer.startAngle }
    set { renderer.startAngle = newValue }
  }
  
  public var endAngle: CGFloat{
    get { return renderer.endAngle }
    set { renderer.endAngle = newValue }
  }
    
   @IBInspectable public var color: UIColor{
        get { return renderer.color }
        set { renderer.color = newValue }
    }
    
  @IBInspectable public var pointerLength: CGFloat{
    get { return renderer.pointerLength }
    set { renderer.pointerLength = newValue }
  }
  
  public func setValue(_ newValue: Float, animated: Bool = false){
    value = min(maximumValue, max(minimumValue, newValue))
    
    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue
    let angleValue = CGFloat(value - minimumValue) / CGFloat(valueRange) * angleRange + startAngle
    renderer.setPointerAngle(angleValue, animated: animated)
  }
  
  
  override init(frame: CGRect){
    super.init(frame:frame)
    commonInit()
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
    
  }
  
  private func commonInit(){
    renderer.updateBounds(bounds)
    renderer.color = tintColor
    renderer.setPointerAngle(renderer.startAngle, animated: false)
    
    layer.addSublayer(renderer.trackLayer)
    layer.addSublayer(renderer.pointerLayer)
    
    let gestureRecognizer = RotationGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    addGestureRecognizer(gestureRecognizer)
    
  }
  
  
  @objc private func handleGesture(_ gesture: RotationGestureRecognizer){
    let midPointAngle = (2 * CGFloat(Double.pi) + startAngle - endAngle) / 2 + endAngle
    
    var boundedAngle = gesture.touchAngle
    if boundedAngle > midPointAngle{
      boundedAngle -= 2 * CGFloat(Double.pi)
    }else if boundedAngle < (midPointAngle - 2 * CGFloat(Double.pi)){
      boundedAngle -= 2 * CGFloat(Double.pi)
    }
    
    boundedAngle = min(endAngle, max(startAngle, boundedAngle))
    
    
    let angleRange = endAngle - startAngle
    let valueRange = maximumValue - minimumValue
    let angleValue = Float(boundedAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
    
    setValue(angleValue)
    
    if isContinuous{
      sendActions(for: .valueChanged)
    }else{
      if gesture.state == .ended || gesture.state == .cancelled{
        sendActions(for: .valueChanged)
      }
    }
  }

}

extension Knob{
    
    //is invoked only when rendering inside IB
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        renderer.updateBounds(bounds)
    }
}
