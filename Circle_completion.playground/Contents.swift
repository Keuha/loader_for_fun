import UIKit
import PlaygroundSupport

enum CircleProgressionViewAnimationState {
    case start, firstAnimation, secondAnimation, progress, stop
}

class CircleProgressionView : UIView {
    static let offset: CGFloat = 10.0
    private var path : UIBezierPath? {
        didSet {
            circleLayer.path = path?.cgPath
        }
    }
    
    private var state : CircleProgressionViewAnimationState {
        didSet {
            observe(change: state)
        }
    }
    private var progressionPath : UIBezierPath?
    var circleLayerContainer = CALayer()
    
    var circleLayer : CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        
        return shapeLayer
    }()
    
    var circleProgressLayer : CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 15
        shapeLayer.cornerRadius = 2
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        return shapeLayer
    }()
    
    override init(frame: CGRect) {
        state = .stop
        super.init(frame:frame)
        initLayerValues()
    }
    
    required init?(coder aDecoder: NSCoder) {
        state = .stop
        super.init(coder:aDecoder)
        initLayerValues()
    }
    
    
    
    private func initLayerValues() {
        let side = min(frame.width, frame.height)
        circleLayerContainer.frame = CGRect(x: 0, y: 0, width: side, height: side)
        let offset = CircleProgressionView.offset
        let bezierSide = side - (offset * 2)
        let bezierRect = CGRect(x:offset,
                                y:offset,
                                width: bezierSide,
                                height:bezierSide)
        path = UIBezierPath(roundedRect: bezierRect,
                            cornerRadius: CGFloat(bezierSide / 2))
        circleLayerContainer.addSublayer(circleLayer)
        layer.addSublayer(circleLayerContainer)
        layer.addSublayer(circleProgressLayer)
    }
    
    func setProgressionPath(_ progressionInPercent: CGFloat) {
        let progression = progressionInPercent / 100 * (360)
        let rad = (progression + 270) * CGFloat.pi / 180
        let start = 270 *  CGFloat.pi / 180
        let offset = CircleProgressionView.offset
        
        progressionPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2),
                radius: (self.frame.size.height - offset - circleProgressLayer.lineWidth / 2) / 2,
                startAngle: start,
                endAngle: rad,
                clockwise: true)

    }
    
    func observe(change: CircleProgressionViewAnimationState) {
        print(change)
        switch change {
        case .firstAnimation:
             fullAnimate { self.state = .secondAnimation }
            break
       case .secondAnimation:
             emptyAnimate { self.state = .firstAnimation }
            break
        case .start, .progress, .stop: break
        }
    }
    
    func animate(loop: Bool) {
        
        var completion : ()->Void = {}
        if loop {
            state = .start
            completion = { self.state = .secondAnimation }
        }
        fullAnimate(completion: completion)
    }
    
    

    func fullAnimate(completion: @escaping ()->Void) {
        self.state = .progress
        circleProgressLayer.removeAllAnimations()
        circleProgressLayer.path
        CATransaction.begin()
         circleProgressLayer.path = progressionPath?.cgPath
        CATransaction.setCompletionBlock{ completion() }
        let animation : CABasicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))

        animation.fromValue = 0.0
        animation.toValue = 1.0

        animation.duration = 2

       animation.timingFunction =  CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)

        circleProgressLayer.add(animation, forKey: #keyPath(CAShapeLayer.strokeEnd))
        CATransaction.commit()


    }

    func emptyAnimate(completion: @escaping ()->Void) {
        self.state = .progress
        circleProgressLayer.removeAllAnimations()
        CATransaction.begin()

        circleProgressLayer.path = progressionPath?.reversing().cgPath
        CATransaction.setCompletionBlock{ completion() }
        let animation : CABasicAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))

        animation.fromValue = 1.0
        animation.toValue = 0.0

        animation.duration = 2
        animation.timingFunction =  CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)

        circleProgressLayer.add(animation, forKey: #keyPath(CAShapeLayer.strokeEnd))
        CATransaction.commit()
    }
}

var container : UIView = {
    let frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    let view = UIView(frame: frame)
    view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    return view
}()

let circle = CircleProgressionView(frame: container.frame)
PlaygroundPage.current.liveView = container
circle.setProgressionPath(100)
container.addSubview(circle)
circle.animate(loop: true)



