//
//  MagneticView.swift
//  Magnetic
//
//  Created by Lasha Efremidze on 3/28/17.
//  Copyright © 2017 efremidze. All rights reserved.
//

import SpriteKit

public class MagneticView: SKView {
    
    @objc
    public lazy var magnetic: Magnetic = { [unowned self] in
        let scene = Magnetic(size: self.bounds.size)
        self.presentScene(scene)
        return scene
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    func commonInit() {
        _ = magnetic
        createSelectionRotor(withName: "Selected",
                             usingScene: magnetic)
    }
  
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        magnetic.size = bounds.size
    }
    
    private func createSelectionRotor(withName name: String,
                                      usingScene magnet: Magnetic) {
        // iOS 10+ allows a VoiceOver user to skip to selected elements
        if #available(iOS 10.0, *) {
            let selectedRotor = UIAccessibilityCustomRotor(name: name) { predicate in
                // Ensure there is at least 1 selected Node]
                let selected = magnet.selectedChildren
                let all = magnet.children.compactMap { $0 as? Node }
                guard selected.count > 0 else { return nil }
                
                // See which direction the user is scrolling
                let isDirectionForward = predicate.searchDirection == .next
                
                // Get the index of current focused Node
                var currentNodeIndex = isDirectionForward ? all.count : -1
                if let current = predicate.currentItem.targetElement {
                    if let currentNode = current as? Node {
                        currentNodeIndex = all.index(of: currentNode) ?? currentNodeIndex
                    }
                }
                
                // A closure used to update the while loop
                let nextSearchNode = { (nodeIndex) in isDirectionForward ? nodeIndex - 1 : nodeIndex + 1 }
                
                // Search elements in selected direction for selected nodes
                var searchNode = nextSearchNode(currentNodeIndex)
                while searchNode >= 0 && searchNode < all.count {
                    defer { searchNode = nextSearchNode(searchNode) }
                    if all[searchNode].isSelected {
                        return UIAccessibilityCustomRotorItemResult(targetElement: all[searchNode],
                                                                    targetRange: nil)
                    }
                }
                return nil
            }
            accessibilityCustomRotors = [selectedRotor]
        }
    }

}
