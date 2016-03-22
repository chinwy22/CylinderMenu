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

class CollectionViewController: UICollectionViewController {

    private var array = [1, 2, 3, 4, 5, 6]
    
    private var radius: CGFloat = 0
    
    private var initialPoint = CGPointZero
    
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
        button.addTarget(self,
            action: #selector(CollectionViewController.showCells(_:)),
            forControlEvents: .TouchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView!.addSubview(button)
        
        let horizontalConstraint = button.centerXAnchor.constraintEqualToAnchor(self.view.centerXAnchor)
        let vertivalConstraint = button.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor)
        
        NSLayoutConstraint.activateConstraints([horizontalConstraint, vertivalConstraint])
        
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
                
                self.array.removeAtIndex(indexPath.item)
                
                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                
                }, completion: nil)
        } else {
            
            self.collectionView!.performBatchUpdates({ () -> Void in
                
                self.array.append(self.array.last ?? 0)
                
                self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: self.array.count - 1, inSection: 0)])
                
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
        
        return self.array.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
    
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.clipsToBounds = true
        cell.layer.cornerRadius = min(cell.bounds.width, cell.bounds.height) / 2.0
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1.0
        
        if let label = cell.viewWithTag(101) as? UILabel {
            
            label.text = String(self.array[indexPath.item])
        }
        return cell
    }
    
    internal func showCells(sender: UIButton) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                    
                collectionViewLayout.radius = self.radius
                
                }, completion:  { (finished: Bool) -> Void in
                    
                    sender.removeTarget(self,
                        action: #function,
                        forControlEvents: .TouchUpInside)
                    sender.addTarget(self,
                        action: #selector(CollectionViewController.hideCells(_:)),
                        forControlEvents: .TouchUpInside)
            })
        }
    }
    
    internal func hideCells(sender: UIButton) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                
                collectionViewLayout.radius = 0
                
                }, completion:  { (finished: Bool) -> Void in
                    
                    sender.removeTarget(self,
                        action: #function,
                        forControlEvents: .TouchUpInside)
                    sender.addTarget(self,
                        action: #selector(CollectionViewController.showCells(_:)),
                        forControlEvents: .TouchUpInside)
            })
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        self.radius = min(size.width, size.height) / 2.5
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            collectionViewLayout.center = CGPoint(x: size.width/2, y: size.height/2)
            
            if collectionViewLayout.radius > 0 {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    collectionViewLayout.radius = self.radius
                    
                    }, completion: nil)
            }
        }
    }
}
