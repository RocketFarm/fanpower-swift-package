//
//  FanpowerApi.swift
//  Fanpower SDK
//
//  Created by Christopher Wyatt on 2/1/23.
//

import Foundation
import Alamofire

class FanpowerApi: ApiReference {
    static var shared: FanpowerApi = FanpowerApi()
    
    var access: String?
    
    static var base = "https://developer.fanpower.io/"
    var tokenForJwtRequest = ""
    var publisherToken = ""
    var publisherShareUrl = "https://www.google.com/"
    var publisherId = ""
    var jwt = ""
    var ipResponse: IpResponse? = nil
    var email: String? = nil
    var phoneNumber: String? = nil
    var verifyCodeResponse: VerifyCodeResponse? = nil
    
    var isLoggedIn: Bool { return FanpowerDb.shared.isLoggedIn() }
    
    func getJwt(completionHandler: @escaping (AFDataResponse<String>) -> Void) {
        let requestUrl = "\(FanpowerApi.base)v1/auth/jwt?token=\(tokenForJwtRequest)"
        print(requestUrl)
        AF.request(requestUrl).responseString(completionHandler: completionHandler)
    }
    
    func getPublisher(completionHandler: @escaping (Alamofire.DataResponse<PublisherResponse, Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        AF.request("\(FanpowerApi.base)v1/publisher?token=\(publisherToken)&publisher_id=\(publisherId)",
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default
        )
            .responseString(completionHandler: {string in print("getPublisher result \(string)")})
            .responseDecodable(of: PublisherResponse.self, completionHandler: completionHandler)
    }
    
    func getProp(propId: String, completionHandler: @escaping (Alamofire.DataResponse<[PropResponse], Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/props?id=\(propId)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default
        )
            .responseString(completionHandler: {string in print("getProp result \(string)")})
            .responseDecodable(of: [PropResponse].self, completionHandler: completionHandler)
    }
    
    func getCarousel(completionHandler: @escaping (Alamofire.DataResponse<[PropResponse], Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v2/carousels/\(publisherId)?token=\(publisherToken)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default
        )
            .responseString(completionHandler: {string in print("getCarousel result \(string)")})
            .responseDecodable(of: [PropResponse].self, completionHandler: completionHandler)
    }
    
    func getPropPosts(propId: String, completionHandler: @escaping (Alamofire.DataResponse<PropPostsResponse, Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/posts?prop_id=\(propId)&anchor=true"
        print(requestUrl)
        AF.request(requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default
        )
            .responseString(completionHandler: {string in print("getPropPosts result \(string)")})
            .responseDecodable(of: PropPostsResponse.self, completionHandler: completionHandler)
    }
    
    func getAd(adZoneId: String, completionHandler: @escaping (Alamofire.DataResponse<[AdResponse], Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/adsPublic?token=\(publisherToken)&ad_zone_id=\(adZoneId)&publisher_id=\(publisherId)&tags=12"
        print(requestUrl)
        AF.request(
            requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default,
                   headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("getAd result \(string)")})
            .responseDecodable(of: [AdResponse].self, completionHandler: completionHandler)
    }
    
    func postNumber(number: String?, email: String?, completionHandler: @escaping (AFDataResponse<String>) -> Void) {
        let params = AuthRequest(email: email, phoneNumber: number)
        self.email = email
        self.phoneNumber = number
        let requestUrl = "\(FanpowerApi.base)v1/fans/auth?token=\(publisherToken)"
        AF.request(requestUrl,
            method: .post,
            parameters: params,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("postNumber result \(string)")})
            .responseString(completionHandler: completionHandler)
    }
    func getIpLookup(ip: String, completionHandler: @escaping (Alamofire.DataResponse<IpResponse, Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/ip-lookup?token=\(publisherToken)&ip=\(ip)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default,
            headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("getIpLookup result \(string)")})
            .responseDecodable(of: IpResponse.self, completionHandler: completionHandler)
    }
    
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
        completionHandler: @escaping (Alamofire.DataResponse<CreateFanPickResponse, Alamofire.AFError>) -> Void) {
        
        let params = CreateFanPickRequest(
            pick_id: pickId,
            prop_id: propId,
            publisher_id: publisherId,
            proposition: Proposition(id: propId),
            ip_address: (ipAddress ?? self.ipResponse?.ipAddress) ?? "",
            fanCity: (fanCity ?? self.ipResponse?.fanCity) ?? "",
            fanState: (fanState ?? self.ipResponse?.fanState) ?? "",
            fanCountry: (fanCountry ?? self.ipResponse?.fanCountry) ?? "",
            fanZipCode: (fanZipCode ?? self.ipResponse?.fanZipCode) ?? "",
            fanGeoLocation: (fanGeoLocation ?? self.ipResponse?.fanGeoLocation) ?? "",
            fanTimeZone: (fanTimeZone ?? self.ipResponse?.fanTimeZone) ?? ""
        )
        let requestUrl = "\(FanpowerApi.base)v1/fans/pick?token=\(publisherToken)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .post,
            parameters: params,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("createFanPick result \(string)")})
            .responseDecodable(of: CreateFanPickResponse.self, completionHandler: completionHandler)
    }
    
    func postCode(code: String, completionHandler: @escaping (Alamofire.DataResponse<VerifyCodeResponse, Alamofire.AFError>) -> Void) {
        let params = VerifyCodeRequest(
            code: code,
            phoneNumber: self.phoneNumber,
            email: self.email
        )
        let requestUrl = "\(FanpowerApi.base)v1/fans/auth/verify?token=\(publisherToken)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .post,
            parameters: params,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("postCode result \(string)")})
            .responseDecodable(of: VerifyCodeResponse.self, completionHandler: completionHandler)
    }
    
    func associateFanWithPick(fanPickId: String, propId: String, adZoneId: String, completionHandler: @escaping (Alamofire.DataResponse<FanPickAssocationResponse, Alamofire.AFError>) -> Void) {
        let params = FanPickAssocationRequest(
            token: publisherToken,
            fan_pick_id: fanPickId,
            fan_id: verifyCodeResponse!.id!,
            prop_id: propId,
            ad_zone_id: adZoneId
        )
        let requestUrl = "\(FanpowerApi.base)v1/fans/fanpick?token=\(publisherToken)"
        print(requestUrl)
        AF.request(requestUrl,
            method: .post,
            parameters: params,
            encoder: JSONParameterEncoder.default,
            headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("associateFanWithPick result \(string)")})
            .responseDecodable(of: FanPickAssocationResponse.self, completionHandler: completionHandler)
    }
    
    func getFanPicks(propId: String, completionHandler: @escaping (Alamofire.DataResponse<[FanPicksResponse], Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/fanpicks?token=\(publisherToken)&fanId=\(FanpowerDb.shared.getUserId() ?? "")&prop=\(propId)"
        print(requestUrl)
        AF.request(
            requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default,
                   headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("getFanPicks result \(string)")})
            .responseDecodable(of: [FanPicksResponse].self, completionHandler: completionHandler)
    }
    func getFanProfile(completionHandler: @escaping (Alamofire.DataResponse<FanProfile, Alamofire.AFError>) -> Void) {
        let params: NilRequest? = nil
        let requestUrl = "\(FanpowerApi.base)v1/fans/profile?token=\(publisherToken)&fanId=\(FanpowerDb.shared.getUserId() ?? "")"
        print(requestUrl)
        AF.request(
            requestUrl,
            method: .get,
            parameters: params,
            encoder: JSONParameterEncoder.default,
                   headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
        )
            .responseString(completionHandler: {string in print("getFanProfile result \(string)")})
            .responseDecodable(of: FanProfile.self, completionHandler: completionHandler)
    }
    func getReferralCode(propId: String, completionHandler: @escaping (Alamofire.DataResponse<ReferralCodeResponse, Alamofire.AFError>) -> Void) {
        if let userId = FanpowerDb.shared.getUserId() {
            let shareUrl = publisherShareUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            let params: NilRequest? = nil
            let requestUrl = "\(FanpowerApi.base)v2/referrals/\(publisherId)/fan/\(userId)?token=\(publisherToken)&url=\(shareUrl!)&prop_id=\(propId)"
            print(requestUrl)
            AF.request(
                requestUrl,
                method: .get,
                parameters: params,
                encoder: JSONParameterEncoder.default,
                headers: HTTPHeaders.init(arrayLiteral: HTTPHeader.init(name: "Authorization", value: "Bearer \(jwt)"))
            )
                .responseString(completionHandler: {string in print("getReferralCode result \(string)")})
                .responseDecodable(of: ReferralCodeResponse.self, completionHandler: completionHandler)
        } else {
            print("tried to get referral code but user ID was nil!")
        }
    }
}
