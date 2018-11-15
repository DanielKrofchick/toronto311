//
//  BottomSheet.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-15.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import UIKit

class BottomSheet: UIViewController {
    @IBOutlet weak var dragStrip: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var minVelocity: CGFloat = 0.05
    fileprivate var defaultTranslationDuration: TimeInterval = 0.25
    fileprivate var maxTranslationDuration: TimeInterval = 0.4
    
    private var minHeight: CGFloat {
        return 0.15 * (view.superview?.frame.height ?? 0)
    }
    
    private var maxHeight: CGFloat {
        return 0.85 * (view.superview?.frame.height ?? 0)
    }
    
    lazy var heightConstraint: NSLayoutConstraint = {
        let r = view.heightAnchor.constraint(equalToConstant: 100)
        r.isActive = true
        return r
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        targetContentOffset.pointee = .zero
        animateTranslationOne(velocity: velocity)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if shouldTranslate(scrollView) {
            translate(scrollView)
            print("translate")
        } else {
            print("not")
        }
    }
    
    private func shouldTranslate(_ scrollView: UIScrollView) -> Bool {
        let c = heightConstraint.constant
        let t = scrollView.panGestureRecognizer.translation(in: view).y
        
        return
            scrollView.isTracking &&
            ((c > minHeight && c < maxHeight) || (c == minHeight && t < 0) || (c == maxHeight && t > 0))
    }
    
    private func translate(_ scrollView: UIScrollView) {
        scrollView.contentOffset = .zero
        heightConstraint.constant -= scrollView.panGestureRecognizer.translation(in: view).y
        heightConstraint.constant = min(maxHeight, max(minHeight, heightConstraint.constant))
        scrollView.panGestureRecognizer.setTranslation(.zero, in: scrollView)
    }
    
    private func progress() -> CGFloat {
        let distance = maxHeight - minHeight
        let progressDistance = heightConstraint.constant - minHeight
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
    
    private func duration(velocity: CGPoint) -> TimeInterval {
        if abs(velocity.y) > minVelocity {
            let rest = abs((maxHeight - minHeight) * (1 - progress()))
            return TimeInterval(rest / abs(velocity.y))
        } else {
            return defaultTranslationDuration
        }
    }
    
    private func animateTranslation(velocity: CGPoint) {
        let v = abs(velocity.y) > minVelocity ? velocity : .zero
        translate(toHeight: height(velocity: velocity), duration: duration(velocity: velocity), velocity: v)
    }
    
    private func animateTranslationOne(velocity: CGPoint) {
        let p = progress()

        var h: CGFloat
        var d: TimeInterval
        var v: CGPoint
        
        if abs(velocity.y) > minVelocity {
            let rest = abs((maxHeight - minHeight) * (1 - p))
            
            h = velocity.y > 0 ? maxHeight: minHeight
            d = TimeInterval(rest / abs(velocity.y))
            v = velocity
        } else if p < 0.5 {
            h = minHeight
            d = defaultTranslationDuration
            v = .zero
        } else {
            h = maxHeight
            d = defaultTranslationDuration
            v = .zero
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
