//
//  KeyboardCategoryContainerPageViewController.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class KeyboardCategoryContainerPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var emojiStorage: EmojiStorage? {
        didSet {
            setCategoryWithIndex(currentIndex ?? 0, reload: true)
        }
    }
    
    var categoryWasChangedHandler: KeyboardView.CategoryWasChangedHandler?
    var emojiWasTappedHandler: KeyboardEmojiCollectionViewController.EmojiWasTappedHandler?
    
    init() {
        super.init(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        dataSource = self
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setCategoryWithIndex(index: Int, reload: Bool = false) {
        if let currentIndex = currentIndex {
            if currentIndex != index || reload {
                let direction: UIPageViewControllerNavigationDirection = (currentIndex < index) ? .Forward : .Reverse
                setViewControllers([viewControllerForIndex(index)!], direction: direction, animated: !reload, completion: nil)
            }
        }
        else {
            setViewControllers([viewControllerForIndex(index)!], direction: .Forward, animated: false, completion: nil)
        }
    }
    
    func viewControllerForIndex(index: Int) -> UIViewController? {
        if let emojiStorage = emojiStorage where index >= 0 && index < emojiStorage.categories.count {
            let vc = KeyboardEmojiCollectionViewController(emojiCategory: emojiStorage.categories[index], index: index)
            vc.emojiWasTappedHandler = emojiWasTappedHandler
            return vc
        }
        else {
            return nil
        }
    }
    
    private var currentIndex: Int? {
        return (viewControllers?.first as? KeyboardEmojiCollectionViewController)?.index
    }
    
    // MARK: Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! KeyboardEmojiCollectionViewController
        return viewControllerForIndex(vc.index - 1)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! KeyboardEmojiCollectionViewController
        return viewControllerForIndex(vc.index + 1)
    }
    
    // MARK: Page View Controller Delegate
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let vc = viewControllers?.first as! KeyboardEmojiCollectionViewController
        categoryWasChangedHandler?(vc.index)
    }
    
}