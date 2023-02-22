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
    
    @IBOutlet private var contentView: UIView!
    
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
    @IBOutlet private weak var pageControlHolderHeight: NSLayoutConstraint!
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
    
    public func setup(tokenForJwtRequest: String, publisherToken: String, publisherId: String, shareUrl: String, propIds: [String], completionHandler: @escaping () -> Void) {
        FanpowerApi.shared.tokenForJwtRequest = tokenForJwtRequest
        FanpowerApi.shared.publisherToken = publisherToken
        FanpowerApi.shared.publisherId = publisherId
        FanpowerApi.shared.publisherShareUrl = shareUrl
        viewModel.propIds = propIds
        self.completionHandler = completionHandler
        
        initSubviews()
    }
    
    private func initSubviews() {
        let nib = UINib(nibName: "FanPowerView", bundle: Bundle.module)
        nib.instantiate(withOwner: self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)
        
        pageControl.numberOfPages = collectionView(collectionView, numberOfItemsInSection: 0)
        pageControl.currentPage = 0
        
        collectionView.register(UINib(nibName: CarouselCell.cellId, bundle: Bundle.module), forCellWithReuseIdentifier: CarouselCell.cellId)
        
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.scrollDirection = .horizontal
//        print("Width: \(self.frame.width) Height: \(self.frame.height)")
//        print("Width: \(self.window?.frame.width) Height: \(self.window?.frame.height)")
        carouselLayout.itemSize = .init(
            width: self.frame.width - carouselMarginX,
            height: self.frame.height - carouselMarginY
        )
        carouselLayout.sectionInset = .zero
        collectionView.collectionViewLayout = carouselLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
        collectionView.layer.cornerRadius = 24
        //collectionView.roundCorners(topLeft: 24, topRight: 24, bottomLeft: 12, bottomRight: 12)
        if viewModel.propIds.count < 2 {
            collectionView.isScrollEnabled = false
            pageControlHolderHeight.constant = 0
        }
        
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
    
    @objc private func tapTerms(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://fanpower.io/terms/")!))
        }
        print("tapped terms")
        webViewHolder.isHidden = false
        closeWebviewButton.isHidden = false
    }
    
    @objc private func tapLearnMore(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: URL(string: "https://fanpower.io")!))
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
        }).disposed(by: disposeBag)
        
        viewModel.adUrlUpdated.subscribe(onNext: {_ in
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
}

extension FanPowerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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
            pageControl.currentPage = Int(scrollView.contentSize.width / (scrollView.contentSize.width - x))
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
        cell.registrationHolder.isHidden = true
        cell.viewModel.primaryColor = viewModel.primaryColor
        cell.viewModel.secondaryColor = viewModel.secondaryColor
        cell.viewModel.textLinkColor = viewModel.textLinkColor
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
            cell.viewModel.getFanPicks()
        }
        return cell
    }
}
