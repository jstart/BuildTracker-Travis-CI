//
//  UIView+Constraints.swift
//  BuildTracker
//
//  Created by Christopher Truman on 4/1/20.
//  Copyright © 2020 truman. All rights reserved.
//

import UIKit

public extension UIView {
    /// Creates constraints pinning the edges of the receiver to the given view or layout guide.
    ///
    /// - parameter anchorContainer: The `LayoutAnchorsContainer` to pin the edges to.
    /// - parameter edges: The edges to pin. Defaults to `.all`.
    /// - parameter relation: The `NSLayoutRelation` to use. Defaults to `.equal`.
    /// - parameter inset: The amount to inset the receiver by. Defaults to `0`.
    /// - parameter priority: The priority to use for the new constraints. Defaults to `1000`.
    /// - parameter active: Whether the new constraints should be activated automatically.
    /// - returns: The new constraints.
    @discardableResult
    func pinEdges<T: LayoutAnchorsContainer>(to anchorContainer: T, edges: UIRectEdge = .all, relation: NSLayoutConstraint.Relation = .equal, inset: CGFloat = 0, priority: UILayoutPriority = .required, active: Bool) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        constraints.reserveCapacity(4)
        if edges.contains(.top) {
            constraints.append(constraint(topAnchor, is: relation, to: anchorContainer.topAnchor, constant: inset))
        }
        if edges.contains(.left) {
            constraints.append(constraint(leftAnchor, is: relation, to: anchorContainer.leftAnchor, constant: inset))
        }
        if edges.contains(.right) {
            constraints.append(constraint(anchorContainer.rightAnchor, is: relation, to: rightAnchor, constant: inset))
        }
        if edges.contains(.bottom) {
            constraints.append(constraint(anchorContainer.bottomAnchor, is: relation, to: bottomAnchor, constant: inset))
        }
        if priority != .required {
            for constraint in constraints {
                constraint.priority = priority
            }
        }
        if active {
            NSLayoutConstraint.activate(constraints)
        }
        return constraints
    }
}

public protocol LayoutAnchorsContainer {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }
    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: LayoutAnchorsContainer {}
extension UILayoutGuide: LayoutAnchorsContainer {}

private func constraint<AnchorType>(_ this: NSLayoutAnchor<AnchorType>, is relation: NSLayoutConstraint.Relation, to anchor: NSLayoutAnchor<AnchorType>, constant: CGFloat = 0) -> NSLayoutConstraint {
    switch relation {
    case .equal:
        return this.constraint(equalTo: anchor, constant: constant)
    case .greaterThanOrEqual:
        return this.constraint(greaterThanOrEqualTo: anchor, constant: constant)
    case .lessThanOrEqual:
        return this.constraint(lessThanOrEqualTo: anchor, constant: constant)
    @unknown default:
        fatalError()
    }
}
