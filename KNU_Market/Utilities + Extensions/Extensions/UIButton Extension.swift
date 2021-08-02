import UIKit

extension UIButton {
    
    func addBounceAnimation() {
        addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUpFailed(_:)), for: [.touchCancel, .touchUpOutside, .touchDragExit])
        addTarget(self, action: #selector(touchUpSucceeded(_:)), for: .touchUpInside)
    }
    
    func addBounceAnimationWithNoFeedback() {
        addTarget(self, action: #selector(touchDown(_:)), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(touchUpFailed(_:)), for: [.touchCancel, .touchUpOutside, .touchDragExit])
        addTarget(self, action: #selector(touchUpSucceededWithoutFeedback(_:)), for: .touchUpInside)
    }
    
    @objc func touchDown(_ sender: UIButton) {
        animate {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc func touchUpFailed(_ sender: UIButton) {
        animate {
            sender.transform = .identity
        }
    }
    
    @objc func touchUpSucceeded(_ sender: UIButton) {
        animate {
            sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } completion: { _ in
            self.animate {
                sender.transform = .identity
            }
        }
    }
    
    @objc func touchUpSucceededWithoutFeedback(_ sender: UIButton) {
        animate {
            sender.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        } completion: { _ in
            self.animate {
                sender.transform = .identity
            }
        }
    }
    
    func animate(reaction: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: reaction, completion: completion)
    }
}
