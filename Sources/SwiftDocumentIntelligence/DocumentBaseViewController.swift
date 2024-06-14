//
//  File.swift
//  
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

public class DocumentBaseViewController: UIViewController {
    
    private var style: UIStatusBarStyle = .default
    private var initialStyle: UIStatusBarStyle = .default
    private var traitCollectionChaged = false
    private var statusBarHidden = false
    
    var constraints: [NSLayoutConstraint] = []
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.tag = 1
        changeStatusBarStyle(.lightContent)
        
//        UITextField.appearance().tintColor = .primaryColor
        
        changeNavBarAppearance(isLightContent: true)
        
        setupViews()
        setupContraints()
        setupSharedContraints()
        setupTableView()
        setupCollectionView()
        setupRadioButtons()
        setupPickers()
        setupLabels()
        setupGestures()
        setupBorders()
        setupObservers()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    
    public override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setupBorders()
        setupContraints()
        
        if !traitCollectionChaged {
            initialStyle = style
        }
        
        if self.traitCollection.userInterfaceStyle == .dark {
            if #available(iOS 13.0, *) {
                changeStatusBarStyle(.lightContent)
            } else {
                changeStatusBarStyle(.default)
            }
        } else {
            changeStatusBarStyle(initialStyle)
        }
        
        traitCollectionChaged = true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }
    
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        }
    }
    
    public func changeStatusBarStyle(_ style: UIStatusBarStyle) {
        self.style = style
        self.setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.setNeedsStatusBarAppearanceUpdate()
    }
    
    public func changeNavBarAppearance(isLightContent: Bool, isTranslucent: Bool = false) {
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            
            if isTranslucent {
                navBarAppearance.configureWithTransparentBackground()
                navBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            } else {
                navBarAppearance.configureWithOpaqueBackground()
            }
            
            if isLightContent {
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.backgroundColor = .primaryColor
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.whiteColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.whiteColor]
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            } else {
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.backgroundColor = .backgroundColor
                navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.labelColor]
                navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.labelColor]
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
            }
        } else {
            if isTranslucent {
                navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController?.navigationBar.shadowImage = UIImage()
            }
        }
        
        if isLightContent {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = .whiteColor
            navigationController?.navigationBar.barTintColor = .primaryColor
            navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                                                       .foregroundColor: UIColor.whiteColor]
        } else {
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.tintColor = .labelColor
            navigationController?.navigationBar.barTintColor = .backgroundColor
            navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 20.0),
                                                                       .foregroundColor: UIColor.primaryColor]
        }
    }
    
    func showNavBar(animated: Bool = false) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func hideNavBar(animated: Bool = false) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func hideNavBarShadow() {
        if #available(iOS 13.0, *) {
            guard let navBarAppearance = self.navigationController?.navigationBar.standardAppearance else { return }
            navBarAppearance.shadowColor = .clear
            navBarAppearance.shadowImage = UIImage()
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        }
        
    }
    
    @objc
    public func navigateBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    public func navigateToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    public func dismissViewController() {
        self.dismiss(animated: true)
    }
    
    public func replaceBackButtonWithCancel() {
        let cancelButton = UIBarButtonItem(image: UIImage(named: "close")?.renderResizedImage(20)?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.setLeftBarButtonItems([cancelButton], animated: false)
    }
    
    @objc public func handleCancel() {
        
    }
    
    public func setupViews() {}
    
    public func setupGestures() {}
    
    public func setupLabels() {}
    
    public func setupTableView() {}
    
    public func setupCollectionView() {}
    
    public func setupRadioButtons() {}
    
    public func setupPickers() {}
    
    public func setupSharedContraints() {}
    
    public func setupContraints() {}
    
    public func setupObservers() {}
    
    public func setupBorders() {}
    
    @objc public func validateFields() {}
    
    @objc public func validateFieldsWithSender(_ sender: UIButton) {}
    
    
    @objc public func dummyClick() {}
    
    public func showStatusBar() {
        self.statusBarHidden = false
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
            self.tabBarController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public func hideStatusBar() {
        self.statusBarHidden = true
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.setNeedsStatusBarAppearanceUpdate()
            self.tabBarController?.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
