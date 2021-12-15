//
//  KeyboardView.swift
//  Karmies
//
//  Created by Robert Nelson on 14/06/16.
//  Copyright © 2016 GB Soft. All rights reserved.
//

class KeyboardView: UIView {

    struct Settings {

        static let backgroundColor = UIColor(red:0.961, green:0.965, blue:0.969, alpha:1.0)
        static let separatorColor = UIColor(red:0.886, green:0.898, blue:0.906, alpha:1.0)
        static let backspaceButtonTintColor = UIColor(red:0.659, green:0.659, blue:0.659, alpha:1)
        
        static let selectedCategoryTintColor = UIColor(red: 0.176, green: 0.600, blue: 0.878, alpha: 1.0)
        static let selectedCategoryIndicatorHeight: CGFloat = 2
        
    }

    typealias EmojiWasTappedHandler = (String) -> Void
    typealias CategoryWasChangedHandler = (Int) -> Void
    
    private let size: CGSize
    private weak var context: KarmiesContext?

    private let categoryCollectionViewController = KeyboardCategoryCollectionViewController()
    private let categoryContainerPageViewController = KeyboardCategoryContainerPageViewController()
    let backspaceButton: UIButton
    private let reachabilityView: UIView
    
    var ReachabilityViewIsHidden: Bool {
        get { return reachabilityView.hidden }
        set { reachabilityView.hidden = newValue }
    }

    var emojiWasTappedHandler: EmojiWasTappedHandler?

    init(height: CGFloat, context: KarmiesContext) {
        size = CGSize(width: 0, height: height)
        self.context = context

        backspaceButton = KeyboardView.createBackspaceButton()
        reachabilityView = KeyboardView.createReachabilityView()

        super.init(frame: CGRectZero)

        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEmojiStorage(emojiStorage: EmojiStorage) {
        categoryCollectionViewController.categoryWasChangedHandler = { [unowned self] index in
            let selectedEmojiCategory = self.context!.emojiStorage.categories[index]
            self.context?.analytics.sendEvent(KeyboardEmojiCategoryAnalyticsEvent(action: .open, emojiCategoryName: selectedEmojiCategory.name, emojiCategoryIndex: index))

            self.categoryContainerPageViewController.setCategoryWithIndex(index)
        }
        categoryCollectionViewController.emojiStorage = emojiStorage
        
        categoryContainerPageViewController.categoryWasChangedHandler = { [unowned self] index in
            let selectedEmojiCategory = self.context!.emojiStorage.categories[index]
            self.context?.analytics.sendEvent(KeyboardEmojiCategoryAnalyticsEvent(action: .open, emojiCategoryName: selectedEmojiCategory.name, emojiCategoryIndex: index))

            self.categoryCollectionViewController.selectedCategoryIndex = index
        }
        categoryContainerPageViewController.emojiWasTappedHandler = { [unowned self] name, index in
            let selectedEmojiCategoryIndex = self.categoryCollectionViewController.selectedCategoryIndex
            let selectedEmojiCategory = self.context!.emojiStorage.categories[selectedEmojiCategoryIndex]
            self.context?.analytics.sendEvent(KeyboardEmojiAnalyticsEvent(action: .click, emojiName: name, emojiIndex: index, emojiCategoryName: selectedEmojiCategory.name, emojiCategoryIndex: selectedEmojiCategoryIndex))

            self.emojiWasTappedHandler?(name)
        }
        categoryContainerPageViewController.emojiStorage = emojiStorage
    }

    // MARK: Views

    private func setupSubviews() {
        categoryCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
        categoryContainerPageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let separatorView = KeyboardView.createSeparatorView()

        addSubview(categoryCollectionViewController.view)
        addSubview(backspaceButton)
        addSubview(separatorView)
        addSubview(categoryContainerPageViewController.view)
        addSubview(reachabilityView)

        let views = [
            "categoryCollectionView": categoryCollectionViewController.view,
            "backspaceButton": backspaceButton,
            "separatorView": separatorView,
            "categoryContainerView": categoryContainerPageViewController.view,
            "reachabilityView": reachabilityView,
        ]

        backgroundColor = Settings.backgroundColor

        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[categoryCollectionView]-8-[backspaceButton(30)]-8-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-11-[backspaceButton(28)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[separatorView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[categoryContainerView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[categoryCollectionView(48)]-0-[separatorView(1)]-0-[categoryContainerView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[reachabilityView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[reachabilityView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

        bounds = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        setNeedsLayout()
    }

    private static func createBackspaceButton() -> UIButton {
        let button = UIButton(type: .Custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Settings.backspaceButtonTintColor

        let image = UIImage.krm_imageNamed("EmojiKeyboard_BackspaceIcon")!
        button.setImage(image.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)

        return button
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Settings.separatorColor

        return view
    }
    
    private static func createReachabilityView() -> UIView {
        let view: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Settings.backgroundColor
            return $0
        }(UIView())
        
        let imageView: UIImageView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            return $0
        }(UIImageView(image: UIImage.krm_imageNamed("NotReachableIcon")))
        view.addSubview(imageView)
        
        view.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0),
        ])
    
        return view
    }

}