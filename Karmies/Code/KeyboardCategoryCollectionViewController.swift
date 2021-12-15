//
//  KeyboardCategoryCollectionViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class KeyboardCategoryCollectionViewController: UICollectionViewController {
    
    static let cellReuseId = "Cell"
    
    var emojiStorage: EmojiStorage? {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    var selectedCategoryIndex = 0 {
        didSet {
            if selectedCategoryIndex != oldValue {
                let changedIndexPaths = [
                    NSIndexPath(forItem: selectedCategoryIndex, inSection: 0),
                    NSIndexPath(forItem: oldValue, inSection: 0),
                ]
                collectionView?.reloadItemsAtIndexPaths(changedIndexPaths)
                
                categoryWasChangedHandler?(selectedCategoryIndex)
            }
        }
    }
    
    var categoryWasChangedHandler: KeyboardView.CategoryWasChangedHandler?
    
    init() {
        let layout: UICollectionViewFlowLayout = {
            $0.scrollDirection = .Horizontal
            $0.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            return $0
        }(UICollectionViewFlowLayout())
        
        super.init(collectionViewLayout: layout)
        
        collectionView?.backgroundColor = KeyboardView.Settings.backgroundColor
        collectionView?.registerClass(KeyboardCollectionViewCell.self, forCellWithReuseIdentifier: KeyboardCategoryCollectionViewController.cellReuseId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let emojiStorage = emojiStorage {
            return emojiStorage.categories.count
        }
        else {
            return 0
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(KeyboardCategoryCollectionViewController.cellReuseId, forIndexPath: indexPath) as! KeyboardCollectionViewCell
        if cell.imageView == nil {
            let indicatorHeight = KeyboardView.Settings.selectedCategoryIndicatorHeight
            cell.imageView = {
                $0.contentMode = UIViewContentMode.ScaleAspectFit
                cell.contentView.addSubview($0)
                return $0
            }(UIImageView(frame: CGRect(x: 0, y: 10, width: cell.frame.size.width, height: cell.frame.size.height - 20)))
            cell.indicatorView = {
                $0.backgroundColor = KeyboardView.Settings.selectedCategoryTintColor
                cell.contentView.addSubview($0)
                return $0
            }(UIView(frame: CGRect(x: 0, y: cell.frame.size.height - indicatorHeight, width: cell.frame.size.width, height: indicatorHeight)))
        }
        
        cell.indicatorView.hidden = indexPath.item != selectedCategoryIndex
        
        cell.imageView.image = nil
        cell.tag = indexPath.item
        
        let emojiCategory = emojiStorage!.categories[indexPath.item]
        emojiCategory.asyncImageWithCompletionHandler { image in
            if cell.tag == indexPath.item {
                cell.imageView.image = image
            }
        }
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedCategoryIndex = indexPath.item
    }
    
    // MARK: Collection View Delegate (Flow Layout)
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 28, height: 48)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8.0
    }
    
}