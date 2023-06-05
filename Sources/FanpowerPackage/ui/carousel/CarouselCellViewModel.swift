//
//  CarouselCellViewModel.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation
import UIKit
import RxSwift

class CarouselCellViewModel {
    var picks: [Pick] = []
    
    var showScreen = PublishSubject<Screen>()
    var invalidEntry = PublishSubject<Void>()
    var invalidPhoneOrEmailEntry = PublishSubject<Void>()
    var entrySubmittedSuccessfully = PublishSubject<Void>()
    var currentScreen = Screen.props
    var waitingForCode = false
    var submittedNumber: String? = nil
    var submittedEmail: String? = nil
    var propId: String? = nil
    var title: String? = nil
    var fanPickId: String? = nil
    var pickRow: Int? = nil
    var adUrl: String? = nil
    var adLink: String? = nil
    var adUrlUpdated = PublishSubject<Void>()
    var referralUrl: String? = nil
    var primaryColor: UIColor? = nil
    var secondaryColor: UIColor? = nil
    var textLinkColor: UIColor? = nil
    var needsCheckbox = false
    
    enum Screen {
        case props
        case register
        case results
    }
    
    func getReferralString() -> String? {
        if let referralUrl = referralUrl {
            if let title = title {
                return "\(title) \(referralUrl) #makeyourpick"
            }
        } else {
            if let title = title {
                return "\(title) \(FanpowerApi.shared.publisherShareUrl) #makeyourpick"
            }
        }
        return nil
    }
    
    func getFanPicks() {
        if let propId = propId {
            if FanpowerDb.shared.isLoggedIn() {
                FanpowerApi.shared.getFanPicks(propId: propId) { response in
                    if let responseValue = response.value {
                        for pick in responseValue {
                            if String(pick.prop_id) == self.propId {
                                self.fanPickId = String(pick.pick_id)
                                
                                for (index, listPick) in self.picks.enumerated() {
                                    if listPick.id == self.fanPickId {
                                        self.pickRow = index
                                        print("retrieved some pick: pick id \(listPick.id), prop id \(pick.prop_id)")
                                    }
                                }
                                
                                self.showScreen.onNext(.results)
                                self.currentScreen = .results
                            }
                        }
                    }
                }
                
                getReferralCode()
            }
        }
    }
    
    func tapButton(index: Int) {
        pickRow = index
        
        FanpowerApi.shared.getAd(adZoneId: "2") { response in
            self.adUrl = response.value?.first?.ad_image
            self.adLink = response.value?.first?.ad_url
            self.adUrlUpdated.onNext(Void())
        }
        
        if FanpowerApi.shared.isLoggedIn {
            //send pick
            FanpowerApi.shared.createFanPick(
                pickId: picks[index].id,
                propId: propId!,
                ipAddress: nil,
                fanCity: nil,
                fanState: nil,
                fanCountry: nil,
                fanZipCode: nil,
                fanGeoLocation: nil,
                fanTimeZone: nil
            ) { response in
                self.fanPickId = response.value?.fanPick
                if let allSomePicks = response.value?.picks {
                    for somePick in allSomePicks {
                        print("setting some pick 1: pick id \(somePick.id), prop id \(self.propId!)")
                    }
                }
                self.associatePick()
            }
        } else {
            //login/register
            FanpowerApi.shared.createFanPick(
                pickId: picks[index].id,
                propId: propId!,
                ipAddress: nil,
                fanCity: nil,
                fanState: nil,
                fanCountry: nil,
                fanZipCode: nil,
                fanGeoLocation: nil,
                fanTimeZone: nil
            ) { response in
                self.fanPickId = response.value?.fanPick
                if let allSomePicks = response.value?.picks {
                    for somePick in allSomePicks {
                        print("setting some pick 2: pick id \(somePick.id), prop id \(self.propId!)")
                    }
                }
                self.showScreen.onNext(Screen.register)
                self.currentScreen = .register
            }
        }
    }
    
    func reSend() {
        if waitingForCode {
            send(number: submittedNumber, email: submittedEmail)
        }
    }
    
    func sendCode(code: String) {
        FanpowerApi.shared.postCode(code: code) { result in
            if (result.value?.message != nil) {
                self.invalidEntry.onNext(Void())
            } else if result.value != nil {
                FanpowerApi.shared.verifyCodeResponse = result.value
                
                let userId = result.value?.id
                FanpowerDb.shared.setUserId(userId: userId)
                
                self.associatePick()
                
                self.getReferralCode()
            } else {
                print("error posting code!")
            }
        }
    }
    
    func getReferralCode() {
        if let propId = propId {
            FanpowerApi.shared.getReferralCode(propId: propId) { result in
                self.referralUrl = result.value?.referral_url
            }
        }
    }
    
    func associatePick() {
        guard let fanPickId = self.fanPickId else {
            print("fanPickId was nil")
            self.showScreen.onNext(.results)
            self.currentScreen = .results
            return
        }
        guard let propId = self.propId else {
            print("fanPickId was nil")
            return
        }
        if FanpowerApi.shared.verifyCodeResponse == nil
            && FanpowerDb.shared.getUserId() == nil {
            print("verify code response and user id were nil!")
            return
        }
        FanpowerApi.shared.associateFanWithPick(fanPickId: fanPickId, propId: propId, adZoneId: "1") { result in
            FanpowerApi.shared.getAd(adZoneId: "4") { response in
                self.adUrl = response.value?.first?.ad_image
                self.adLink = response.value?.first?.ad_url
                self.adUrlUpdated.onNext(Void())
            }
            
            self.showScreen.onNext(.results)
            self.currentScreen = .results
        }
    }
    
    func send(number: String?, email: String?) {
        submittedNumber = number
        submittedEmail = email
        if let submittedEmail = submittedEmail {
            FanpowerApi.shared.postEmail(email: submittedEmail) { result in
                self.sendCode(code: "validated")
            }
        } else {
            FanpowerApi.shared.postNumber(number: number, email: email) { result in
                if result.value?.contains("Invalid") == true {
                    print("invalid phone or email error")
                    self.invalidPhoneOrEmailEntry.onNext(Void())
                    self.waitingForCode = false
                } else if result.value?.contains("pending") == true {
                    print("Message sent scucessfully")
                    self.waitingForCode = true
                    self.entrySubmittedSuccessfully.onNext(Void())
                }
            }
        }
    }
    
    func hasPicked() -> Bool {
        return pickRow != nil
    }
    
    func hasPicked(index: Int) -> Bool {
        if pickRow == index { return true }
        return false
    }
}
