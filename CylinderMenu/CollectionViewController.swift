//
//  CollectionViewController.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

extension CGVector {
    
    func angle(v: CGVector) -> CGFloat {
        
        let dot = self.dx*v.dx + self.dy*self.dy
        let det = self.dx*v.dy - self.dy*v.dx
        
        let result = atan2(det, dot)
        
        if result.isNaN {
            
            return 0
        }
        return result
    }
}


let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    var numberOfCells = 6
    
    var radius: CGFloat = 0
    
    var initialPoint = CGPointZero
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let itemSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let sizeOfCell = min(itemSize.width, itemSize.height)
        
        let button = UIButton(frame: CGRectMake(0, 0, sizeOfCell, sizeOfCell))
        button.center = self.collectionView!.center
        button.backgroundColor = UIColor.lightGrayColor()
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeOfCell / 2.0
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.layer.borderWidth = 1.0
        button.addTarget(self, action: Selector("hideOrShowCells:"), forControlEvents: .TouchUpInside)
        
        self.collectionView!.addSubview(button)
        
        let size = self.collectionView!.frame.size
        
        self.radius = min(size.width, size.height) / 2.5
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            collectionViewLayout.center = self.collectionView!.center
            collectionViewLayout.radius = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTapGesture(sender: UITapGestureRecognizer) {
        
        if let indexPath = self.collectionView?.indexPathForItemAtPoint(sender.locationInView(self.collectionView)) {
            
            self.collectionView!.performBatchUpdates({ () -> Void in
                
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                self.numberOfCells--
                }, completion: nil)
        } else {
            
            self.collectionView!.performBatchUpdates({ () -> Void in
                
                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
                self.numberOfCells++
                }, completion: nil)
        }
        
    }
    
    @IBAction func handlePanGesture(sender: UIPanGestureRecognizer) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            if sender.state == .Began {
                
                self.initialPoint = sender.locationInView(sender.view)
                
            } else if sender.state == .Changed {
                
                let center = sender.view?.center
                
                let initialVector = CGVector(dx: self.initialPoint.x - center!.x, dy: self.initialPoint.y - center!.y)
                
                let currentPoint = sender.locationInView(sender.view)
                
                let currentVector = CGVector(dx: currentPoint.x - center!.x, dy: currentPoint.y - center!.y)
                
                let angle = initialVector.angle(currentVector)
                
                self.initialPoint = currentPoint
                    
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    collectionViewLayout.initialAngle += angle
                    
                    }, completion: nil)
                
            } else if sender.state == .Ended {
                
                let count = Int(collectionViewLayout.initialAngle/CGFloat(2*M_PI))
                
                collectionViewLayout.initialAngle -= CGFloat(count)*CGFloat(2*M_PI)
            }
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.numberOfCells
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) 
    
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.clipsToBounds = true
        cell.layer.cornerRadius = min(cell.bounds.width, cell.bounds.height) / 2.0
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1.0
        
        if let label = cell.viewWithTag(101) as? UILabel {
            
            label.text = String(indexPath.row + 1)
        }
        return cell
    }
    
    func hideOrShowCells(sender: UIButton) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                
                if sender.tag == 0 {
                    
                    collectionViewLayout.radius = self.radius
                    sender.tag = 1
                } else {
                    
                    collectionViewLayout.radius = 0
                    sender.tag = 0
                }
                }, completion: nil)
        }
    }
}
