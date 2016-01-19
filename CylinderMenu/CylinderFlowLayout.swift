//
//  CylinderFlowLayout.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

class CylinderFlowLayout: UICollectionViewFlowLayout {
    
    var center: CGPoint = CGPointZero
    
    var radius: CGFloat = 0.0
    
    var numberOfCells: Int = 0
    
    var deleteIndexPaths: [NSIndexPath] = []
    var insertIndexPaths: [NSIndexPath] = []
    
    var initialAngle = CGFloat(0)
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        self.numberOfCells = self.collectionView!.numberOfItemsInSection(0)
    }
    
    override func prepareForCollectionViewUpdates(updateItems: [UICollectionViewUpdateItem]) {
        
        super.prepareForCollectionViewUpdates(updateItems)
        
        for updateItem: UICollectionViewUpdateItem in updateItems {
            
            if updateItem.updateAction == .Delete {
                
                self.deleteIndexPaths.append(updateItem.indexPathBeforeUpdate!)
                
            } else if updateItem.updateAction == .Insert {
                
                self.insertIndexPaths.append(updateItem.indexPathAfterUpdate!)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        
        super.finalizeCollectionViewUpdates()
        
        self.deleteIndexPaths = []
        self.insertIndexPaths = []
    }
    
    override func collectionViewContentSize() -> CGSize {
        
        return self.collectionView!.frame.size
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes {
        
        let attribute = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attribute.size = CGSizeMake(50, 50)
        
        let angle = self.initialAngle + CGFloat(2 * M_PI)*CGFloat(indexPath.item) / CGFloat(self.numberOfCells)

        attribute.center = CGPointMake(self.center.x + self.radius*cos(angle), self.center.y + self.radius*sin(angle))
        return attribute
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        for var i = 0; i < self.numberOfCells; i++ {
            
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            
            attributes.append(self.layoutAttributesForItemAtIndexPath(indexPath))
        }
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attribute = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        
        if self.insertIndexPaths.contains(itemIndexPath) {
            
            attribute.alpha = 0.0
            attribute.center = self.center
        }
        
        return attribute
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attribute = self.layoutAttributesForItemAtIndexPath(itemIndexPath)
        
        if self.deleteIndexPaths.contains(itemIndexPath) {
            
            attribute.alpha = 0.0
            attribute.center = self.center
            attribute.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }
        return attribute
    }
}
