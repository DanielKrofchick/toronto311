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
    // We aren't able to reset the scrollview pan gesture translation,
    // as that appears to interfere with it's internal implementation.
    // Tracking old gesture translation to calculate delta.
    private var oldTranslation: CGFloat = 0
    
    // Minimum flick velocity to trigger resize
    private var minVelocity: CGFloat = 0.5
    
    // Filter large jumps.
    // Difficulty finding suitable point to recalibrate pan gesture translation and oldTranslation
    private var maxResize: CGFloat = 10
    
    private var defaultResizeAnimationDuration: TimeInterval = 0.25
    private var maxResizeAnimationDuration: TimeInterval = 0.4
    
    weak var sheetDelegate: SheetDelegate?
    
    var minHeight: CGFloat {
        return 0.15 * (view.superview?.frame.height ?? 0)
    }
    
    var maxHeight: CGFloat {
        return 0.85 * (view.superview?.frame.height ?? 0)
    }
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let r = view.heightAnchor.constraint(equalToConstant: 0)
        r.isActive = true
        return r
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateResize(velocity: CGPoint(x: minVelocity, y: minVelocity))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        animateResize(velocity: CGPoint(x: minVelocity, y: minVelocity))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let h = height(velocity: velocity)
        
        // Prevent max -> min flick when scrollview content is below top
        if heightConstraint.constant == maxHeight && h == minHeight && scrollView.contentOffset.y > 0 {
            return
        }

        // Prevent up content scroll on min -> max flick
        if heightConstraint.constant != h {
            targetContentOffset.pointee = .zero
        }
        
        animateResize(velocity: velocity)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newT = scrollView.panGestureRecognizer.translation(in: view).y
        
        var t = newT - oldTranslation
        t = min(abs(t), maxResize) * (t.sign == .minus ? -1 : 1)

        oldTranslation = newT

//        if t > maxResize {
//            return
//        }
        
        if shouldResize(byHeight: t, scrollView: scrollView) {
            resize(byHeight: t)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + t)
        }
    }
    
    // MARK: -
    
    private func progress() -> CGFloat {
        let progressDistance = heightConstraint.constant - minHeight
        let distance = maxHeight - minHeight
        return progressDistance / distance
    }
    
    private func height(velocity: CGPoint) -> CGFloat {
        if abs(velocity.y) > minVelocity {
            return velocity.y > 0 ? maxHeight: minHeight
        } else if progress() < 0.5 {
            return minHeight
        } else {
            return maxHeight
        }
    }
    
    private func animateResize(velocity: CGPoint) {
        let h = height(velocity: velocity)
        var d = defaultResizeAnimationDuration
        var v = CGPoint.zero

        let position = (maxHeight - minHeight) * progress()
        var rest = abs(position)

        if abs(velocity.y) >= minVelocity {
            rest = abs(h - position)
        }
        
        d = TimeInterval(rest / abs(velocity.y * 1000))
        v = velocity

        resize(toHeight: h, duration: d, velocity: v)
    }
    
    func resize(toHeight height: CGFloat, duration: TimeInterval? = nil, velocity: CGPoint = .zero) {
        heightConstraint.constant = height
        UIView.animate(
            withDuration: min(duration ?? defaultResizeAnimationDuration, maxResizeAnimationDuration),
            delay: 0,
            usingSpringWithDamping: velocity.y == 0 ? 0.6 : 0.6,
            initialSpringVelocity: abs(velocity.y),
            options: [.allowUserInteraction],
            animations: { [weak self] in
                guard let self = self else {return}
                self.view.layoutIfNeeded()
                self.sheetDelegate?.sheet(self, didAnimateToHeight: height)
        }, completion: nil)
    }
    
    private func shouldResize(byHeight height: CGFloat, scrollView: UIScrollView) -> Bool {
        let c = heightConstraint.constant
        let inRange = c > minHeight && c < maxHeight
        let upFromBottom = c == minHeight && height < 0
        let downFromTop = c == maxHeight && height > 0 && scrollView.contentOffset.y <= 0
        
        print(height)
        
        return scrollView.isTracking && (inRange || upFromBottom || downFromTop)
    }
    
    private func resize(byHeight height: CGFloat) {
        heightConstraint.constant = min(maxHeight, max(minHeight, heightConstraint.constant - height))
    }
}
