//
//  BottomSheet.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-15.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

class BottomSheet: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    // We aren't able to reset the scrollview pan gesture translation,
    // as that appears to interfere with it's internal implementation.
    // Tracking old gesture translation to calculate delta.
    fileprivate var oldTranslation: CGFloat = 0
    fileprivate var minVelocity: CGFloat = 0.5
    fileprivate var defaultTranslationDuration: TimeInterval = 0.25
    fileprivate var maxTranslationDuration: TimeInterval = 0.4
    
    private var minHeight: CGFloat {
        return 0.15 * (view.superview?.frame.height ?? 0)
    }
    
    private var maxHeight: CGFloat {
        return 0.85 * (view.superview?.frame.height ?? 0)
    }
    
    lazy var heightConstraint: NSLayoutConstraint = {
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

extension BottomSheet: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animateTranslation(velocity: CGPoint(x: minVelocity, y: minVelocity))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        animateTranslation(velocity: CGPoint(x: minVelocity, y: minVelocity))
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let h = height(velocity: velocity)
        
        // Stop flick from max to min when scrollview content is not at top
        if h != heightConstraint.constant && h == minHeight && scrollView.contentOffset.y > 0 {
            return
        }
        
        // Ensure content at top with flick from min to max
        if h != heightConstraint.constant {
            targetContentOffset.pointee = .zero
        }
        
        animateTranslation(velocity: velocity)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let newT = scrollView.panGestureRecognizer.translation(in: view).y
        let t = newT - oldTranslation
        oldTranslation = newT

        // Filter large jumps.
        // Difficulty finding suitable point to recalibrate pan translation and oldTranslation
        if abs(t) > 20 {
            return
        }
        
        if shouldTranslate(translation: t, scrollView: scrollView) {
            translate(t)
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollView.contentOffset.y + t)
        }
    }
    
    private func shouldTranslate(translation: CGFloat, scrollView: UIScrollView) -> Bool {
        let c = heightConstraint.constant

        return
            scrollView.isTracking &&
            ((c > minHeight && c < maxHeight) || (c == minHeight && translation < 0) || (c == maxHeight && translation > 0 && scrollView.contentOffset.y <= 0))
    }
    
    private func translate(_ translation: CGFloat) {
        heightConstraint.constant -= translation
        heightConstraint.constant = min(maxHeight, max(minHeight, heightConstraint.constant))
    }
    
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
    
    private func animateTranslation(velocity: CGPoint) {
        let h = height(velocity: velocity)
        var d = defaultTranslationDuration
        var v = CGPoint.zero
        
        if abs(velocity.y) >= minVelocity {
            let position = (maxHeight - minHeight) * progress()
            let rest = abs(h - position)
            
            d = TimeInterval(rest / abs(velocity.y))
            v = velocity
        }
        
        translate(toHeight: h, duration: d, velocity: v)
    }
    
    private func translate(toHeight height: CGFloat, duration: TimeInterval, velocity: CGPoint) {
        heightConstraint.constant = height
        UIView.animate(
            withDuration: min(duration, maxTranslationDuration),
            delay: 0,
            usingSpringWithDamping: velocity.y == 0 ? 1 : 0.6,
            initialSpringVelocity: abs(velocity.y),
            options: [.allowUserInteraction],
            animations: {
                self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
