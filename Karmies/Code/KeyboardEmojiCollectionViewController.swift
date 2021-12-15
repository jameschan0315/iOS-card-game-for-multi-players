//
//  KeyboardEmojiCollectionViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class KeyboardEmojiCollectionViewController: UICollectionViewController {

    typealias EmojiWasTappedHandler = (String, Int) -> Void
    
    static let cellReuseId = "Cell"
    
    private weak var emojiCategory: EmojiCategory?
    let index: Int
    
    var emojiWasTappedHandler: EmojiWasTappedHandler?
    
    init(emojiCategory: EmojiCategory, index: Int) {
        self.index = index
        
        let layout: UICollectionViewFlowLayout = {
            $0.scrollDirection = .Vertical
            $0.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            return $0
        }(UICollectionViewFlowLayout())
        
        super.init(collectionViewLayout: layout)
        
        self.emojiCategory = emojiCategory
        
        collectionView?.backgroundColor = KeyboardView.Settings.backgroundColor
        collectionView?.registerClass(KeyboardCollectionViewCell.self, forCellWithReuseIdentifier: KeyboardEmojiCollectionViewController.cellReuseId)
        
        print("alloc \(unsafeAddressOf(self))")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("free \(unsafeAddressOf(self))")
    }
    
    // MARK: Collection View Data Source
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiCategory?.emojiNames.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(KeyboardEmojiCollectionViewController.cellReuseId, forIndexPath: indexPath) as! KeyboardCollectionViewCell
        if cell.imageView == nil {
            cell.imageView = {
                $0.contentMode = UIViewContentMode.ScaleAspectFit
                cell.contentView.addSubview($0)
                return $0
            }(UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height)))
        }
        
        cell.imageView.image = nil
        cell.tag = indexPath.item
        
        if let emojiCategory = emojiCategory {
            let name = emojiCategory.emojiNames[indexPath.item]
            emojiCategory.storage.emojiWithName(name).asyncImageWithCompletionHandler { image in
                if cell.tag == indexPath.item {
                    cell.imageView.image = image
                }
            }
        }
        
        return cell
    }
    
    // MARK: Collection View Delegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let emojiCategory = emojiCategory {
            emojiWasTappedHandler?(emojiCategory.emojiNames[indexPath.item], indexPath.item)
        }
    }
    
    // MARK: Collection View Delegate (Flow Layout)
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 32, height: 32)
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
