//
//  CarouselCell.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 1/29/23.
//

import UIKit
import RxSwift

protocol StopStartScrollDelegate {
    func changeScrollState(canScroll: Bool)
}

class CarouselCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registrationHolder: UIView!
    
    @IBOutlet weak var codeEntryField: UITextField!  {
        didSet {
            codeEntryField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForNumericTextField)))
        }
    }
    @IBOutlet weak var innerRegistrationHeader: UILabel!
    @IBOutlet weak var registrationTopMessage: UILabel!
    @IBOutlet weak var adImage: UIImageView!
    @IBOutlet weak var innerRegistrationHeaderHolder: UIView!
    @IBOutlet weak var innerRegistrationHolder: UIView!
    @IBOutlet weak var innerRegistrationBodyHolder: UIView!
    @IBOutlet weak var twoMinuteWarningLabel: UILabel!
    @IBOutlet weak var phoneFlagImage: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var registrationSendButton: UIImageView!
    @IBOutlet weak var phoneTextField: UITextField! {
        didSet {
            phoneTextField?.addDoneCancelToolbar(onDone: (target: self, action: #selector(doneButtonTappedForNumericTextField)))
        }
    }
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var moreIndicatorTop: UIView!
    @IBOutlet weak var moreIndicatorBottom: UIView!
    @IBOutlet weak var registrationFooter: UILabel!
    
    static let cellId = "CarouselCell"
    let rowCellId = "PropsRowCell"
    var viewModel = CarouselCellViewModel()//The view that instatntiates this cell will change this
    let disposeBag = DisposeBag()
    var timer: Timer? = nil
    var stopStartScrollDelegate: StopStartScrollDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func doneButtonTappedForNumericTextField() {
        print("Done");
        codeEntryField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
    
    func initialize() {        
        self.initSubviews()
        self.registerListeners()
        self.registerActions()
    }
    
    func registerActions() {
        self.registrationSendButton.isUserInteractionEnabled = true
        self.registrationSendButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.send (_:)))
        )
        self.registrationFooter.isUserInteractionEnabled = true
        self.registrationFooter.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.reSend (_:)))
        )
        codeEntryField.addTarget(self, action: #selector(codeEntryDidChange), for: .editingChanged)
        phoneTextField.addTarget(self, action: #selector(phoneEntryDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(emailEntryDidChange), for: .editingChanged)
        self.adImage.isUserInteractionEnabled = true
        self.adImage.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action:  #selector (self.tapAd (_:)))
        )
    }
    
    @objc func send(_ sender:UITapGestureRecognizer) {
        self.registrationTopMessage.text = "Enter the code within 2 minutes to verify your pick"
        self.registrationTopMessage.textColor = Constants.black
        if viewModel.waitingForCode {
            if let text = codeEntryField.text {
                viewModel.sendCode(code: text)
                self.codeEntryField?.endEditing(true)
            }
        } else {
            var phone: String? = nil
            if let phoneText = phoneTextField.text {
                phone = "+1 \(phoneText)".replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "")
            }
            if !emailTextField.isHidden {
                viewModel.send(number: nil, email: emailTextField.text)
                self.emailTextField?.endEditing(true)
            } else {
                viewModel.send(number: phone, email: nil)
                self.phoneTextField?.endEditing(true)
            }
            restartTimer()
        }
    }
    
    func restartTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2.0 * 60.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: false)
    }
    
    @objc func fireTimer() {
        self.registrationTopMessage.isHidden = true
        self.registrationFooter.text = "Or use your email address"
        self.innerRegistrationHeader.text = "Verify your pick to see results"
        self.phoneFlagImage.isHidden = false
        self.phoneTextField.isHidden = false
        self.codeEntryField.isHidden = true
        self.countryCodeLabel.isHidden = false
    }
    
    @objc func tapAd(_ sender:UITapGestureRecognizer) {
        if let adLink = viewModel.adLink {
            if let link = URL(string: adLink) {
                UIApplication.shared.open(link)
            }
        }
    }
    
    @objc func reSend(_ sender:UITapGestureRecognizer) {
        if viewModel.waitingForCode {
            viewModel.reSend()
            restartTimer()
        } else {
            emailTextField.isHidden = !emailTextField.isHidden
            phoneTextField.isHidden = !phoneTextField.isHidden
            if phoneTextField.isHidden {
                self.registrationFooter.text = "Or use your phone number"
                phoneFlagImage.isHidden = true
                countryCodeLabel.isHidden = true
            } else {
                self.registrationFooter.text = "Or use your email address"
                phoneFlagImage.isHidden = false
                countryCodeLabel.isHidden = false
            }
        }
    }
    
    func registerListeners() {
        viewModel.showScreen.subscribe(onNext: { screen in
            if screen == .register {
                self.registrationHolder.alpha = 0
                self.registrationHolder.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.registrationHolder.alpha = 1
                }
                self.stopStartScrollDelegate?.changeScrollState(canScroll: false)
            } else if screen == .results {
                self.stopStartScrollDelegate?.changeScrollState(canScroll: true)
                self.timer?.invalidate()
                UIView.animate(withDuration: 0.5) {
                    self.registrationHolder.alpha = 0
                    self.registrationHolder.isHidden = true
                }
                self.tableView.reloadData()
            }
        }).disposed(by: disposeBag)
        
        viewModel.entrySubmittedSuccessfully.subscribe(onNext: {
            self.registrationTopMessage.isHidden = false
            self.registrationTopMessage.text = "Enter the code within 2 minutes to verify your pick"
            self.registrationFooter.text = "Didn't get the code? Click to resend it"
            self.innerRegistrationHeader.text = "ENTER THE CODE YOU RECEIVED ⏳"
            self.phoneFlagImage.isHidden = true
            self.phoneTextField.isHidden = true
            self.emailTextField.isHidden = true
            self.codeEntryField.isHidden = false
            self.countryCodeLabel.isHidden = true
        }).disposed(by: disposeBag)
        
        viewModel.adUrlUpdated.subscribe(onNext: {_ in
            if let adUrl = self.viewModel.adUrl {
                self.adImage.load(url: URL(string: adUrl)!)
            }
        }).disposed(by: disposeBag)
        
        viewModel.invalidEntry.subscribe(onNext: {_ in
            self.registrationTopMessage.text = "Incorrect Verification Code!"
            self.registrationTopMessage.textColor = Constants.errorRed
        }).disposed(by: disposeBag)
        
        viewModel.invalidPhoneOrEmailEntry.subscribe(onNext: {_ in
            self.emailTextField.textColor = Constants.errorRed
            self.phoneTextField.textColor = Constants.errorRed
        }).disposed(by: disposeBag)
    }
    
    @objc func codeEntryDidChange(textField: UITextField) {
        if let text = textField.text {
            if text.count > 0 {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(NSAttributedString.Key.kern, value: 15.0, range: NSMakeRange(0, text.count-1))
                textField.attributedText = attributedString
            }
        }
    }
    
    @objc func phoneEntryDidChange(textField: UITextField) {
        self.emailTextField.textColor = Constants.black
        self.phoneTextField.textColor = Constants.black
        guard let text = textField.text else { return }
        textField.text = text.applyPatternOnNumbers(pattern: "(###) ###-####", replacementCharacter: "#")
    }
    
    @objc func emailEntryDidChange(textField: UITextField) {
        self.emailTextField.textColor = Constants.black
        self.phoneTextField.textColor = Constants.black
    }
    
    func initSubviews() {
        codeEntryField.isHidden = true
        
        tableView.register(UINib(nibName: rowCellId, bundle: Bundle.module), forCellReuseIdentifier: rowCellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = true
        tableView.separatorStyle = .none
        
        let gradientTop = CAGradientLayer()
        gradientTop.frame = moreIndicatorTop.bounds
        gradientTop.colors = [UIColor.lightGray.cgColor, UIColor.clear.cgColor]
        gradientTop.cornerRadius = 6
        gradientTop.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        moreIndicatorTop.layer.insertSublayer(gradientTop, at: 0)
        moreIndicatorTop.layer.cornerRadius = 6
        moreIndicatorTop.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        moreIndicatorTop.clipsToBounds = true
        let gradientBottom = CAGradientLayer()
        gradientBottom.frame = moreIndicatorBottom.bounds
        gradientBottom.colors = [UIColor.clear.cgColor, UIColor.lightGray.cgColor]
        gradientBottom.cornerRadius = 6
        gradientBottom.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        moreIndicatorBottom.layer.insertSublayer(gradientBottom, at: 0)
        moreIndicatorBottom.layer.cornerRadius = 6
        moreIndicatorBottom.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        moreIndicatorBottom.clipsToBounds = true
        
        innerRegistrationHeaderHolder.backgroundColor = Constants.headerBgColor
        innerRegistrationHeaderHolder.clipsToBounds = true
        innerRegistrationHeaderHolder.layer.cornerRadius = 12
        innerRegistrationHeaderHolder.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        innerRegistrationBodyHolder.layer.borderColor = Constants.black.cgColor
        innerRegistrationBodyHolder.layer.borderWidth = 1
        innerRegistrationBodyHolder.layer.cornerRadius = 6
        innerRegistrationBodyHolder.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        innerRegistrationBodyHolder.clipsToBounds = true
        
        if let secondaryColor = viewModel.secondaryColor,
            let textLinkColor = viewModel.textLinkColor {
            
            self.innerRegistrationHeader.textColor = textLinkColor
            self.innerRegistrationHeaderHolder.backgroundColor = secondaryColor
            self.registrationFooter.textColor = secondaryColor
        }
        
        adImage.layer.cornerRadius = 8
        
        //let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = BlurEffectView()//UIVisualEffectView(effect: blurEffect)
        //blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.frame = registrationHolder.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        registrationHolder.insertSubview(blurEffectView, at: 0)
    }
    
    func setPicks(picks: [Pick]) {
        viewModel.picks = picks
        tableView.reloadData()
        didScroll()
    }
}

extension CarouselCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.picks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rowCellId, for: indexPath) as! PropsRowCell
        cell.mainLabel.text = viewModel.picks[indexPath.item].display_title
        
        if viewModel.currentScreen == .results {
            cell.subLabel.isHidden = false
            cell.subLabel.text = "\(Int(viewModel.picks[indexPath.row].pick_popularity))%"
            cell.mainLabel.textAlignment = .left
        } else {
            if let primaryColor = self.viewModel.primaryColor {
                cell.mainLabel.textColor = primaryColor
                cell.subLabel.textColor = primaryColor
            }
            cell.subLabel.isHidden = true
            cell.mainLabel.textAlignment = .center
        }
        if viewModel.currentScreen == .results {
            let popularity = viewModel.picks[indexPath.row].pick_popularity
            cell.progressBarWidth.constant = 0
            UIView.animate(withDuration: 0.5) {
                cell.progressBarWidth.constant = CGFloat(
                    Float(cell.labelsHolder.frame.width) * (popularity / 100.0)
                )
                cell.progressBarView.isHidden = false
                cell.layoutIfNeeded()
            }
            if (popularity / 100.0) > 0.96 {
                cell.progressBarView.layer.borderWidth = 1
                cell.progressBarView.layer.borderColor = Constants.white.cgColor
                cell.progressBarView.layer.cornerRadius = 23
                cell.progressBarView.backgroundColor = Constants.progressYellow
                cell.progressBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                cell.progressBarView.clipsToBounds = true
            }
            if viewModel.hasPicked(index: indexPath.item) {
                if let primaryColor = self.viewModel.primaryColor {
                    cell.mainLabel.textColor = primaryColor
                    cell.subLabel.textColor = primaryColor
                }
                if let primaryColor = self.viewModel.primaryColor {
                    cell.labelsHolder.layer.borderColor = primaryColor.cgColor
                } else {
                    cell.labelsHolder.layer.borderColor = Constants.pickedBorderYellow.cgColor
                }
                
                if let secondaryColor = self.viewModel.secondaryColor {
                    cell.progressBarView.backgroundColor = secondaryColor
                } else {
                    cell.progressBarView.backgroundColor = Constants.pickedBorderYellow
                }
            } else {
                cell.mainLabel.textColor = Constants.notChosen
                cell.subLabel.textColor = Constants.notChosen
                cell.labelsHolder.layer.borderColor = Constants.notChosen.cgColor
                cell.progressBarView.backgroundColor = Constants.notChosenBackground
                cell.labelsHolder.layer.borderColor = Constants.black.cgColor
            }
        } else {
            cell.progressBarView.isHidden = true
            cell.labelsHolder.layer.borderColor = Constants.black.cgColor
        }
        return cell
    }
}

extension CarouselCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.fanPickId == nil {
            viewModel.tapButton(index: indexPath.item)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScroll()
    }
    
    func didScroll() {
        let visibleCells = self.tableView.visibleCells
        if visibleCells.count > 0 && viewModel.picks.count > 0
            && (visibleCells[0] as! PropsRowCell).mainLabel.text != viewModel.picks[0].display_title {
            //first row hidden
            self.moreIndicatorTop.isHidden = false
        } else {
            self.moreIndicatorTop.isHidden = true
        }
        if visibleCells.count > 0 && viewModel.picks.count > 0
            && (visibleCells[visibleCells.count - 1] as! PropsRowCell).mainLabel.text != viewModel.picks[viewModel.picks.count - 1].display_title {
            //last row hidden
            self.moreIndicatorBottom.isHidden = false
        } else {
            self.moreIndicatorBottom.isHidden = true
        }
    }
}
