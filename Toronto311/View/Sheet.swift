//
//  Sheet.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-15.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

protocol SheetDelegate: class {
    func sheet(_ sheet: Sheet, didAnimateToHeight height: CGFloat)
}

class Sheet: UIViewController {
    lazy var pan: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
    }()
    var scrollView: UIScrollView?
    lazy var minHeight: CGFloat = { return 0.3 * (view?.superview?.frame.height ?? 0) }()
    lazy var maxHeight: CGFloat = { return 0.85 * (view?.superview?.frame.height ?? 0) }()
    var minFlickVelocity: CGFloat = 500
    
    private var defaultAnimationVelocity = CGPoint(x: 20, y: 20)
    private var defaultAnimationDuration: TimeInterval = 0.25
    private var maxAnimationDuration: TimeInterval = 0.4
    
    weak var sheetDelegate: SheetDelegate?
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let r = view.heightAnchor.constraint(equalToConstant: 0)
        r.isActive = true
        return r
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pan.delegate = self
        view.addGestureRecognizer(pan)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        initConstraints()
    }
    
    private func initConstraints() {
        view.pin(edges: [.left, .right, .bottom])
        heightConstraint.constant = maxHeight
    }
}

extension Sheet: UIScrollViewDelegate {
    @objc private func didPan(recognizer: UIPanGestureRecognizer) {
        let height = recognizer.translation(in: view).y
        let velocity = recognizer.velocity(in: view)
        recognizer.setTranslation(.zero, in: view)
        
        switch recognizer.state {
        case .began, .changed:
            if canResize(byHeight: height) {
                resize(byHeight: height)
            }
        case .ended, .cancelled, .failed:
            flick(velocity: velocity)
        case .possible:
            break
        }
    }
    
    private func flick(velocity: CGPoint) {
        let newHeight = height(velocity: velocity)
        
        if let scrollView = scrollView {
            // Prevent max -> min flick when scrollView content is below top
            if scrollView.contentOffset.y > 0 && heightConstraint.constant == maxHeight && newHeight == minHeight {
                return
            }
            
            // Pin scrollView content to top on cross-over flick
            if newHeight == minHeight && heightConstraint.constant != minHeight {
                scrollView.contentOffset = .zero
                scrollView.isScrollEnabled = false
            } else if newHeight == maxHeight && heightConstraint.constant != maxHeight {
                scrollView.isScrollEnabled = true
            }
        }
        
        animateResize(velocity: velocity)
    }

    private func progress() -> CGFloat {
        let progressDistance = heightConstraint.constant - minHeight
        let distance = maxHeight - minHeight
        
        return progressDistance / distance
    }
    
    private func height(velocity: CGPoint) -> CGFloat {
        if abs(velocity.y) > minFlickVelocity {
            return velocity.y > 0 ? minHeight: maxHeight
        } else if progress() < 0.5 {
            return minHeight
        } else {
            return maxHeight
        }
    }
    
    private func canResize(byHeight height: CGFloat) -> Bool {
        let c = heightConstraint.constant
        let inRange = c > minHeight && c < maxHeight
        let upFromBottom = c == minHeight && height < 0
        let downFromTop = c == maxHeight && height > 0 && (scrollView?.contentOffset.y ?? 0 <= 0)
        
        return inRange || upFromBottom || downFromTop
    }
    
    private func resize(byHeight height: CGFloat) {
        heightConstraint.constant = min(maxHeight, max(minHeight, heightConstraint.constant - height))
        
        if let scrollView = scrollView {
            let h = height * (height > 0 ? -1 : 1)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + h)
        }
    }
    
    private func animateResize(velocity: CGPoint) {
        let height = self.height(velocity: velocity)
        let distance = abs(heightConstraint.constant - height)
        let duration = TimeInterval(distance / abs(velocity.y))

        resize(toHeight: height, duration: duration, velocity: velocity)
    }
    
    func resize(toHeight height: CGFloat, duration: TimeInterval? = nil, velocity: CGPoint? = nil) {
        heightConstraint.constant = height
        
        // Magic number that works
        let springVelocityFactor: CGFloat = 100
        
        UIView.animate(
            withDuration: min(duration ?? defaultAnimationDuration, maxAnimationDuration),
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: abs((velocity ?? defaultAnimationVelocity).y) / springVelocityFactor,
            options: [.allowUserInteraction],
            animations: { [weak self] in
                guard let self = self else {return}
                self.view.layoutIfNeeded()
                self.sheetDelegate?.sheet(self, didAnimateToHeight: height)
        }, completion: nil)
    }
}

extension Sheet: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
