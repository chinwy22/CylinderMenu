//
//  CollectionViewController.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class CollectionViewController: UICollectionViewController {

    var numberOfCells = 6
    
    var radius: CGFloat = 0
    
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
        button.layer.borderWidth = 2.0
        button.addTarget(self, action: Selector("moveCells:"), forControlEvents: .TouchUpInside)
        
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
    
    @IBAction func handleRotationGesture(sender: UIRotationGestureRecognizer) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            if sender.state == .Began {
                
                sender.rotation = collectionViewLayout.initialAngle
                
            } else if sender.state == .Changed {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    collectionViewLayout.initialAngle = sender.rotation
                    }, completion: nil)
                
            } else if sender.state == .Ended {
                
                let count: Int = Int(sender.rotation/CGFloat(2*M_PI))
                collectionViewLayout.initialAngle = sender.rotation - CGFloat(count)*CGFloat(2*M_PI)
            }
        }
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
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.numberOfCells
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
    
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.clipsToBounds = true
        cell.layer.cornerRadius = min(cell.bounds.width, cell.bounds.height) / 2.0
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 2.0
        
        if let label = cell.viewWithTag(1001) as? UILabel {
            
            label.text = String(indexPath.row + 1)
        }
        return cell
    }
    
    func moveCells(sender: UIButton) {
        
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
