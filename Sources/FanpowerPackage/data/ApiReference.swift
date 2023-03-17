//
//  ApiReference.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation
import Alamofire

protocol ApiReference {    
    func getJwt(completionHandler: @escaping (AFDataResponse<String>) -> Void)
    func getPublisher(completionHandler: @escaping (DataResponse<PublisherResponse, AFError>) -> Void)
    func getProp(propId: String, completionHandler: @escaping (DataResponse<[PropResponse], AFError>) -> Void)
    func getCarousel(completionHandler: @escaping (DataResponse<Carousel, AFError>) -> Void)
    func getPropPosts(propId: String, completionHandler: @escaping (DataResponse<PropPostsResponse, AFError>) -> Void)
    func getAd(adZoneId: String, completionHandler: @escaping (DataResponse<[AdResponse], AFError>) -> Void)
    func postNumber(number: String?, email: String?, completionHandler: @escaping (AFDataResponse<String>) -> Void)
    func getIpLookup(ip: String, completionHandler: @escaping (DataResponse<IpResponse, AFError>) -> Void)
    func createFanPick(
        pickId: String,
        propId: String,
        ipAddress: String?,
        fanCity: String?,
        fanState: String?,
        fanCountry: String?,
        fanZipCode: String?,
        fanGeoLocation: String?,
        fanTimeZone: String?,
        completionHandler: @escaping (Alamofire.DataResponse<CreateFanPickResponse, Alamofire.AFError>) -> Void)
    func postCode(code: String, completionHandler: @escaping (Alamofire.DataResponse<VerifyCodeResponse, Alamofire.AFError>) -> Void)
    func associateFanWithPick(fanPickId: String, propId: String, adZoneId: String, completionHandler: @escaping (Alamofire.DataResponse<FanPickAssocationResponse, Alamofire.AFError>) -> Void)
    func getFanPicks(propId: String, completionHandler: @escaping (DataResponse<[FanPicksResponse], AFError>) -> Void)
    func getFanProfile(completionHandler: @escaping (DataResponse<FanProfile, AFError>) -> Void)
    func getReferralCode(propId: String, completionHandler: @escaping (DataResponse<ReferralCodeResponse, AFError>) -> Void)
}
