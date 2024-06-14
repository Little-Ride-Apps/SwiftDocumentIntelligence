//
//  Button.swift
//
//
//  Created by Boaz James on 14/06/2024.
//

import UIKit

class IconButton: UIButton {
    private var imgSize: CGFloat = 20
    private var size = CGSize(width: 44, height: 44)
    
    var customBackgroundColor: UIColor = .clear {
        didSet {
            if #available(iOS 15.0, *) {
                var config = self.configuration
                var backgroundConfig = UIBackgroundConfiguration.clear()
                backgroundConfig.backgroundColor = customBackgroundColor
                config?.background = backgroundConfig
                
                self.configuration = config
            }
            
            backgroundColor = customBackgroundColor
        }
    }
    
    var renderingMode: UIImage.RenderingMode = .alwaysTemplate {
        didSet {
            if !imgName.isEmpty {
               setupImage()
            }
        }
    }
    
    var imgName = "" {
        didSet {
            setupImage()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    init(imgSize: CGFloat, size: CGSize) {
        super.init(frame: .zero)
        self.imgSize = imgSize
        self.size = size
        setupViews()
    }
    
    private func setupImage() {
        if #available(iOS 15, *) {
            var configuration = self.configuration
            configuration?.image = UIImage(named: imgName, in: .module, with: nil)?.renderResizedImage(imgSize)?.withRenderingMode(renderingMode)
            configuration?.imagePlacement = .trailing
            configuration?.imagePadding = 10
            self.configuration = configuration
        } else {
            self.setImage(UIImage(named: imgName, in: .module, compatibleWith: nil)?.renderResizedImage(imgSize)?.withRenderingMode(renderingMode), for: .normal)
            switch UIApplication.shared.userInterfaceLayoutDirection {
            case .leftToRight:
                self.semanticContentAttribute = .forceRightToLeft
            case .rightToLeft:
                self.semanticContentAttribute = .forceLeftToRight
            @unknown default:
                self.semanticContentAttribute = .forceRightToLeft
            }
        }
    }
    
    func setupViews() {
        if #available(iOS 15, *) {
            var backgroundConfig = UIBackgroundConfiguration.clear()
            backgroundConfig.backgroundColor = customBackgroundColor

            var configuration = UIButton.Configuration.plain()
            configuration.imagePlacement = .trailing
            configuration.imagePadding = 0
            configuration.background = backgroundConfig
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            self.configuration = configuration
        } else {
            switch UIApplication.shared.userInterfaceLayoutDirection {
            case .leftToRight:
                self.semanticContentAttribute = .forceRightToLeft
            case .rightToLeft:
                self.semanticContentAttribute = .forceLeftToRight
            @unknown default:
                self.semanticContentAttribute = .forceRightToLeft
            }
            self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        self.backgroundColor = customBackgroundColor
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        self.setTitleColor(.darkGray, for: .highlighted)
        self.layer.masksToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: size.height).activate()
        self.widthAnchor.constraint(equalToConstant: size.width).activate()
//        self.contentHorizontalAlignment = .left
        self.tintColor = .whiteColor
        
    }
}
