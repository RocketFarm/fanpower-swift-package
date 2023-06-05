//
//  FanPowerViewModel.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation
import RxSwift
import Alamofire
import UIKit

class FanPowerViewModel {
    var logoUrl = PublishSubject<String>()
    var adUrlUpdated = PublishSubject<Void>()
    var propUpdated = PublishSubject<String>()
    var colorsUpdated = PublishSubject<PublisherResponse?>()
    var termsUpdated = PublishSubject<Void>()
    var adUrl: String? = nil
    var adLink: String? = nil
    var primaryColor: UIColor? = nil
    var secondaryColor: UIColor? = nil
    var textLinkColor: UIColor? = nil
    var checkBoxContents: String? = nil
    
    var propIds: [String] = []
    var propsData: [String: PropResponse] = [:]
    var carouselViewModels: [String: CarouselCellViewModel] = [:]
    
    
    func initialize() {
        FanpowerApi.shared.getJwt() { response in
            do {
                let fullString = try response.result.get()
                FanpowerApi.shared.jwt = String(fullString[1..<(fullString.count-1)])
                
                if let cellIp = Constants.getAddress(for: .cellular) {
                    self.getIpLookup(ip: cellIp)
                } else {
                    AF.request("https://api.ipify.org").responseString { response in
                        let ip = response.value ?? Constants.getAddress(for: .cellular) ?? Constants.getAddress(for: .wifi)
                        if let ip = ip {
                            self.getIpLookup(ip: ip)
                        } else {
                            print("error getting ip!")
                        }
                    }
                }
            } catch {
                print("error fetching jwt!")
            }
        }
    }
    
    func getIpLookup(ip: String) {
        FanpowerApi.shared.getIpLookup(ip: ip) { response in
            FanpowerApi.shared.ipResponse = response.value
            
            FanpowerApi.shared.getAd(adZoneId: "1") { response in
                self.adUrl = response.value?.first?.ad_image
                self.adLink = response.value?.first?.ad_url
                self.adUrlUpdated.onNext(Void())
            }
            
            self.getPublisher()
            if self.propIds.isEmpty {
                self.updateAllProps()
            } else {
                for prop in self.propIds {
                    self.getProps(propId: prop)
                }
            }
            self.getFanProfile()
        }
    }
    
    func getFanProfile() {
        if FanpowerDb.shared.isLoggedIn() {
            FanpowerApi.shared.getFanProfile() { response in
                //TODO: something with this???
            }
        }
    }
    
    func showIntroHolder() -> Bool {
        return !FanpowerApi.shared.isLoggedIn
    }
    
    func updateAllProps() {
        FanpowerApi.shared.getCarousel() { response in
            if let value = response.value {
                self.propIds.removeAll()
                for prop in value.prop_ids {
                    self.propIds.append("\(prop.prop_id)")
                }
                
                for prop in self.propIds {
                    self.getProps(propId: prop)
                }
            }
        }
    }
    
    func getProps(propId: String) {
        FanpowerApi.shared.getProp(propId: propId) { response in
            if let value = response.value {
                self.propsData[propId] = value[0]
                if self.carouselViewModels[propId] == nil {
                    self.carouselViewModels[propId] = CarouselCellViewModel()
                }
                self.propUpdated.onNext(propId)
            }
        }
    }
    
    func getPublisher() {
        FanpowerApi.shared.getPublisher() { response in
            self.logoUrl.onNext(response.value?.picker_logo_url ?? "")
                        
            self.colorsUpdated.onNext(response.value)
            
            if let doCheckbox = response.value?.settings?.require_terms_checkbox,
                doCheckbox.caseInsensitiveCompare("true") == .orderedSame {
                
                self.checkBoxContents = response.value?.settings?.require_terms_content?.replacingOccurrences(of: "'", with: "\"")
                self.termsUpdated.onNext(Void())
            }
        }
    }
}
