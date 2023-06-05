//
//  FanPowerView.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 1/29/23.
//

import UIKit
import RxSwift
import WebKit

protocol FanPowerViewDelegate {
    func ready()
}

public class FanPowerView: UIView {
    
    @IBOutlet public var contentView: UIView!
    
    @IBOutlet private weak var learnMoreLabel: UILabel!
    @IBOutlet private weak var termsAndConditionsLabel: UILabel!
    @IBOutlet private weak var closeWebviewButton: UIImageView!
    @IBOutlet private weak var shareSmsButton: UIView!
    @IBOutlet private weak var shareFacebookButton: UIView!
    @IBOutlet private weak var shareTwitterButton: UIView!
    @IBOutlet private weak var shareCloseButton: UIImageView!
    @IBOutlet private weak var shareHolder: UIView!
    @IBOutlet private weak var shareBackgroundHolder: UIView!
    @IBOutlet private weak var shareImage: UIImageView!
    @IBOutlet private weak var termsAndConditionsHolder: UIView!
    @IBOutlet private weak var pageControlHolderHeight: NSLayoutConstraint!//30
    @IBOutlet private weak var pageControlHolder: UIView!
    @IBOutlet private weak var splashMessage: UIView!
    @IBOutlet private weak var splashButton: UIView!
    @IBOutlet private weak var mainLogo: UIImageView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var introHolder: UIView!
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var webViewHolder: UIView!
    private var velocityX = CGFloat(0.0)
    private let viewModel = FanPowerViewModel()
    private let disposeBag = DisposeBag()
    private let carouselMarginX = 15.0
    private let carouselMarginY = 200.0
    private var completionHandler: () -> Void = {}
    private var termsContentReference: UILabel?
    private var termsContentWebviewHeight: NSLayoutConstraint?
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        initSubviews()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        initSubviews()
//    }
    
    public func setup(tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, completionHandler: @escaping () -> Void) {
        FanpowerApi.shared.tokenForJwtRequest = tokenForJwtRequest
        FanpowerApi.shared.publisherToken = publisherToken
        FanpowerApi.shared.publisherId = publisherId
        FanpowerApi.shared.publisherShareUrl = shareUrl
        self.completionHandler = completionHandler
        
        initSubviews()
    }
    
    public func setup(tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, propIds: [String], completionHandler: @escaping () -> Void) {
        FanpowerApi.shared.tokenForJwtRequest = tokenForJwtRequest
        FanpowerApi.shared.publisherToken = publisherToken
        FanpowerApi.shared.publisherId = publisherId
        FanpowerApi.shared.publisherShareUrl = shareUrl
        self.completionHandler = completionHandler
        self.viewModel.propIds = propIds
        
        initSubviews()
    }
    
    private func updateScrollMeta() {
        if viewModel.propIds.count < 2 {
            collectionView.isScrollEnabled = false
            pageControlHolderHeight.constant = 0
        } else {
            collectionView.isScrollEnabled = true
            pageControlHolderHeight.constant = 30
        }
    }
    
    public func setCollectionViewLayout() {
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
        print("Width: \(self.frame.width) Height: \(self.frame.height)")
//        print("Width: \(self.window?.frame.width) Height: \(self.window?.frame.height)")
        carouselLayout.itemSize = .init(
            width: self.frame.width,// - carouselMarginX,
            height: self.frame.height - carouselMarginY//100//collectionView.collectionViewLayout.collectionViewContentSize.height//400//
        )
        carouselLayout.sectionInset = .zero
        carouselLayout.minimumLineSpacing = 0
        carouselLayout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = carouselLayout
    }
    
    private func styleForNascar() {
        Constants.convertNascarLabel(label: termsAndConditionsLabel)
        Constants.convertNascarLabel(label: learnMoreLabel)
    }
    
    private func initSubviews() {
        
            let bundle = Bundle(for: FanPowerView.self).path(forResource: "FanpowerPackage", ofType: "bundle")
            if let bundle = bundle {
                let nib = UINib(nibName: "FanPowerView", bundle: Bundle(path: bundle))
                nib.instantiate(withOwner: self, options: nil)
            } else {
                let nib = UINib(nibName: "FanPowerView", bundle: Bundle.module)
                nib.instantiate(withOwner: self, options: nil)
            }
        
//        let nib = UINib(nibName: "FanPowerView", bundle: Bundle(path: Bundle(for: FanPowerView.self).path(forResource: "FanPower", ofType: "bundle")!))
        
//        let nib = UINib(nibName: "FanPowerView", bundle: Bundle(for: FanPowerView.classForCoder()))
        
//        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        if FanpowerApi.shared.publisherId == "367" {
            styleForNascar()
        }
        
        pageControl.numberOfPages = collectionView(collectionView, numberOfItemsInSection: 0)
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        pageControlHolder.layer.cornerRadius = pageControlHolder.frame.height / 2
        
                    
        let cBundle = Bundle(for: CarouselCell.self).path(forResource: "FanpowerPackage", ofType: "bundle")
        if let cBundle = cBundle {
            let nib = UINib(nibName: "CarouselCell", bundle: Bundle(path: cBundle))
            
            collectionView.register(
                nib,
                forCellWithReuseIdentifier: CarouselCell.cellId
            )
        } else {
            let nib = UINib(nibName: "CarouselCell", bundle: Bundle.module)
            
            collectionView.register(
                nib,
                forCellWithReuseIdentifier: CarouselCell.cellId
            )
        }
        
        /*collectionView.register(
            UINib(nibName: "CarouselCell", bundle: Bundle(path: Bundle(for: CarouselCell.self).path(forResource: "FanPower", ofType: "bundle")!)),
            forCellWithReuseIdentifier: CarouselCell.cellId
        )*/
        
        setCollectionViewLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
//        collectionView.layer.cornerRadius = 24
        //collectionView.roundCorners(topLeft: 24, topRight: 24, bottomLeft: 12, bottomRight: 12)
        updateScrollMeta()
        
        shareHolder.layer.cornerRadius = 12
        shareTwitterButton.layer.cornerRadius = 8
        shareSmsButton.layer.cornerRadius = 8
        shareFacebookButton.layer.cornerRadius = 8
        
        termsAndConditionsHolder.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapTerms (_:)))
        )
        
        learnMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapLearnMore (_:)))
        )
        
        shareImage.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareImage (_:)))
        )
        
        shareCloseButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareClose (_:)))
        )
        shareBackgroundHolder.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareClose (_:)))
        )
        closeWebviewButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapCloseWebview(_:)))
        )
        shareSmsButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareSms(_:)))
        )
        shareTwitterButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareTwitter(_:)))
        )
        shareFacebookButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapShareFacebook(_:)))
        )
        
        let introGradient = CAGradientLayer()
        introGradient.colors = [Constants.splashGradientClear.cgColor, Constants.splashGradientYellow.cgColor]
        introGradient.locations = [0.0, 1.0]
        introGradient.frame = introHolder.bounds
        introHolder.layer.insertSublayer(introGradient, at: 0)
        introHolder.isHidden = !viewModel.showIntroHolder()
        
        splashMessage.layer.cornerRadius = 24
        splashMessage.layer.shadowColor = UIColor.black.cgColor
        splashMessage.layer.shadowOpacity = 0.3
        splashMessage.layer.shadowOffset = .zero
        splashMessage.layer.shadowRadius = 20
        splashButton.layer.cornerRadius = 20
        
        splashButton.isUserInteractionEnabled = true
        splashButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.continueSplash (_:)))
        )
        
        viewModel.initialize()
        
        registerListeners()
    }
    
    private func getShareString() -> String? {
        return (collectionView.cellForItem(at: collectionView.indexPathsForVisibleItems[0]) as! CarouselCell).viewModel.getReferralString()
    }
    
    private func getReferralUrlString() -> String? {
        return (collectionView.cellForItem(at: collectionView.indexPathsForVisibleItems[0]) as! CarouselCell).viewModel.referralUrl
    }
    
    @objc private func tapShareSms(_ sender:UITapGestureRecognizer) {
        if let shareString = getShareString() {
            let sms = "sms:&body=\(shareString)"
            let url = sms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tapShareTwitter(_ sender:UITapGestureRecognizer) {
        if let shareString = getShareString() {
            let url = "https://twitter.com/intent/tweet?text=\(shareString)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func tapShareFacebook(_ sender:UITapGestureRecognizer) {
        if let shareString = getReferralUrlString() {
            let url = "https://www.facebook.com/sharer/sharer.php?u=\(shareString)"
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
    
    @objc private func continueSplash(_ sender:UITapGestureRecognizer) {
        introHolder.isHidden = true
    }
    
    private func animateWebView() {
        UIView.animate(withDuration: 0.5) {
            self.webViewHolder.alpha = 1
        }
    }
    
    @objc private func tapTerms(_ sender: UITapGestureRecognizer) {
        webViewHolder.alpha = 0
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://fanpower.io/terms/")!))
            self.animateWebView()
        }
        print("tapped terms")
        webViewHolder.isHidden = false
        closeWebviewButton.isHidden = false
    }
    
    @objc private func tapLearnMore(_ sender: UITapGestureRecognizer) {
        webViewHolder.alpha = 0
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://fanpower.io")!))
            self.animateWebView()
        }
        print("tapped learnmore")
        webViewHolder.isHidden = false
        closeWebviewButton.isHidden = false
    }
    
    @objc private func tapCloseWebview(_ sender: UITapGestureRecognizer) {
        closeWebviewButton.isHidden = true
        webViewHolder.isHidden = true
    }
    
    @objc private func tapShareImage(_ sender: UITapGestureRecognizer) {
        print("tapped shareimage")
        self.shareBackgroundHolder.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.shareBackgroundHolder.alpha = 1
        }
        self.shareBackgroundHolder.isHidden = false
    }
    
    @objc private func tapShareClose(_ sender: UITapGestureRecognizer) {
        self.shareBackgroundHolder.isHidden = true
    }
    
    private func registerListeners() {
        viewModel.logoUrl.subscribe(onNext: {
            if let url = URL(string: $0) {
                self.mainLogo.load(url: url)
            }
        }).disposed(by: disposeBag)
        
        viewModel.propUpdated.subscribe(onNext: {_ in
            self.collectionView.reloadData()
            self.completionHandler()
            let numberOfPages = self.collectionView(self.collectionView, numberOfItemsInSection: 0)
            self.pageControl.numberOfPages = numberOfPages
            self.pageControl.isHidden = numberOfPages <= 1
            self.updateScrollMeta()
        }).disposed(by: disposeBag)
        
        viewModel.adUrlUpdated.subscribe(onNext: {_ in
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.termsUpdated.subscribe(onNext: {_ in
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        viewModel.colorsUpdated.subscribe(onNext: { publisherResponse in
            if let publisherResponse = publisherResponse {
                let primaryColor = publisherResponse.primary_color == nil
                    ? UIColor.init(hex: "#291535FF")
                    : UIColor.init(hex: publisherResponse.primary_color!)
                self.viewModel.primaryColor = primaryColor
                
                let secondaryColor = publisherResponse.secondary_color == nil
                    ? UIColor.init(hex: "#44CA97FF")
                    : UIColor.init(hex: publisherResponse.secondary_color!)
                self.viewModel.secondaryColor = secondaryColor
                
                let iconColor = publisherResponse.icon_color == nil
                    ? UIColor.init(hex: "#FA5757FF")
                    : UIColor.init(hex: publisherResponse.icon_color!)
                self.shareImage.tintColor = iconColor
                
                let textLinkColor = publisherResponse.text_link_color == nil
                    ? UIColor.init(hex: "#F8F7FAFF")
                    : UIColor.init(hex: publisherResponse.text_link_color!)
                self.viewModel.textLinkColor = textLinkColor
                self.termsAndConditionsLabel.textColor = textLinkColor
                self.learnMoreLabel.textColor = textLinkColor
                
                let backgroundColor = publisherResponse.background_color == nil
                    ? UIColor.init(hex: "#291535FF")
                    : UIColor.init(hex: publisherResponse.background_color!)
                self.contentView.backgroundColor = backgroundColor
                
                self.collectionView.reloadData()
            }
        }).disposed(by: disposeBag)
    }
    
    @objc func handleTapOnLabel(_ recognizer: UITapGestureRecognizer) {
        
        guard let termsContentReference = termsContentReference, let text = termsContentReference.attributedText?.string, let checkBoxContents = viewModel.checkBoxContents else {
            return
        }
        
        var resultsUrlsArray: [String] = []
        do {
            let regex = try NSRegularExpression(pattern: "<a.+?href=\"([^\"]+)")
            let results = regex.matches(in: checkBoxContents, range: NSRange(checkBoxContents.startIndex..., in: checkBoxContents))
            resultsUrlsArray = results.compactMap {
                Range($0.range, in: checkBoxContents).map { String(checkBoxContents[$0]) }
            }
            for link in resultsUrlsArray {
                print(link[link.index(link.startIndex, offsetBy: 9)...])
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        var resultsLinksArray: [String] = []
        do {
            let regex = try NSRegularExpression(pattern: ">(.+)</a>")
            let results = regex.matches(in: checkBoxContents, range: NSRange(checkBoxContents.startIndex..., in: checkBoxContents))
            resultsLinksArray = results.compactMap {
                Range($0.range, in: checkBoxContents).map { String(checkBoxContents[$0]) }
            }
            for link in resultsLinksArray {
                print(link)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        //TODO: enumerate every link
        if let range = text.range(of: "Policy") {
            if recognizer.didTapAttributedTextInLabel(label: termsContentReference, inRange: NSRange(range, in: text)) {
                //TODO: go to site
                print("hi")
            }
        }
        /*guard let text = lblAgreeToTerms.attributedText?.string else {
            return
        }

        if let range = text.range(of: NSLocalizedString("_onboarding_terms", comment: "terms")),
            recognizer.didTapAttributedTextInLabel(label: lblAgreeToTerms, inRange: NSRange(range, in: text)) {
            goToTermsAndConditions()
        } else if let range = text.range(of: NSLocalizedString("_onboarding_privacy", comment: "privacy")),
            recognizer.didTapAttributedTextInLabel(label: lblAgreeToTerms, inRange: NSRange(range, in: text)) {
            goToPrivacyPolicy()
        }*/
    }
}

extension FanPowerView: UICollectionViewDelegateFlowLayout {
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if let cell = self.collectionView.cellForItem(at: indexPath) as? CarouselCell {
//            return CGSize(
//                width: self.frame.width - carouselMarginX,
//                height: cell.height()
//            )
//        } else {
//            return CGSize(width: self.frame.width - carouselMarginX, height: 500)
//        }
//    }
}

extension FanPowerView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        velocityX = velocity.x
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        setContentOffset(scrollView: collectionView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
    
        setContentOffset(scrollView: collectionView)
    }
    
    func setContentOffset(scrollView: UIScrollView) {
        let numOfItems = collectionView(collectionView, numberOfItemsInSection: 0)
        let stopOver = scrollView.contentSize.width / CGFloat(numOfItems)
        var x = round((scrollView.contentOffset.x + (velocityX * 150)) / stopOver) * stopOver // 150 is for test. Change it for your liking
        
        x = max(0, min(x, scrollView.contentSize.width - scrollView.frame.width))
        
        if x == 0 {
            pageControl.currentPage = 0
        } else {
            pageControl.currentPage = Int(x / stopOver)
        }
        
        scrollView.setContentOffset(CGPointMake(x, scrollView.contentOffset.y), animated: true)
    }
        
}

extension FanPowerView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.propIds.count//viewModel.propsData.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CarouselCell.cellId, for: indexPath) as! CarouselCell
        if let carouselViewModel = viewModel.carouselViewModels[viewModel.propIds[indexPath.item]] {
            cell.viewModel = carouselViewModel
            cell.stopStartScrollDelegate = self
            cell.initialize()
        }
        cell.registrationHolder.isHidden = true
        if var checkBoxContents = viewModel.checkBoxContents {
            cell.viewModel.needsCheckbox = true
            cell.registrationSendButton.isUserInteractionEnabled = false
            cell.registrationSendButton.isHidden = true
            let fixer = "<!DOCTYPE html><html><head><meta name='viewport' content='initial-scale=1, user-scalable=no, width=device-width' /><style>@font-face { font-family: 'Outfit'; src: url('Outfit-VariableFont_wght.ttf') format('truetype'); } body { font-size: 10px; font-family: 'Outfit'; }</style></head><body>"
            checkBoxContents = fixer + checkBoxContents + "</body></html>"
            cell.termsContent.set(html: checkBoxContents)
            cell.termsContent.isUserInteractionEnabled = true
            cell.termsContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnLabel(_:))))
            cell.termsContent.translatesAutoresizingMaskIntoConstraints = true
            cell.termsContent.sizeToFit()
            self.termsContentReference = cell.termsContent
            self.termsContentWebviewHeight = cell.termsWebViewHeight
            
            let bundle = Bundle(for: FanPowerView.self).path(forResource: "FanpowerPackage", ofType: "bundle")
            if let bundle = bundle {
                cell.termsWebView.loadHTMLString(checkBoxContents, baseURL: Bundle(path: bundle)?.bundleURL)
                
            } else {
                cell.termsWebView.loadHTMLString(checkBoxContents, baseURL: Bundle.module.bundleURL)
                
            }
            cell.termsWebView.navigationDelegate = self
            cell.termsWebView.scrollView.isScrollEnabled = false
            cell.termsWebView.backgroundColor = .clear
            cell.termsWebView.isOpaque = false
            cell.termsWebView.scrollView.backgroundColor = .clear
            cell.termsContent.isHidden = true
            
            cell.termsHolder.isHidden = false
        } else {
            cell.termsHolder.isHidden = true
        }
        cell.viewModel.primaryColor = viewModel.primaryColor
        cell.viewModel.secondaryColor = viewModel.secondaryColor
        cell.viewModel.textLinkColor = viewModel.textLinkColor
        cell.viewModel.adLink = viewModel.adLink
        if let propsData = viewModel.propsData[viewModel.propIds[indexPath.item]] {
            cell.title.text = propsData.proposition
            if let adUrl = viewModel.adUrl {
                if let url = URL(string: adUrl) {
                    cell.adImage.load(url: url)
                }
            }
            cell.setPicks(picks: propsData.picks)
            cell.viewModel.propId = viewModel.propIds[indexPath.item]
            cell.viewModel.title = propsData.proposition
            if cell.viewModel.pickRow == nil {
                cell.viewModel.getFanPicks()
            }
            
            let constantValue = propsData.picks.count > 4
                ? 0.0
                : (4 - Double(propsData.picks.count)) * 40
            print("constant value \(constantValue)")
            cell.bottomMargin.constant = max(0, constantValue)
        }
        
        
        return cell
    }
}

extension FanPowerView: StopStartScrollDelegate {
    func changeScrollState(canScroll: Bool) {
        collectionView.isScrollEnabled = canScroll
        if !canScroll {
            pageControl.isEnabled = false
        } else {
            updateScrollMeta()
        }
    }
}


extension FanPowerView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url { UIApplication.shared.open(url) }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState") { complete, error in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight") { height, error in
                    print("height to \(height)")
                    //self.termsContentWebviewHeight?.constant = (height as! CGFloat) * 4
                }
            }
        }
    }
}
