//
//  AlamofirNetworkConnection.swift
//  NearBy Demo
//
//  Created by Subhankar Singha.
//  Copyright © 2017 Subhnakar Singha. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import SwiftyJSON


class AlamofireNetworkConnection: NSObject {
    
    func getNearbyPlaces(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        Alamofire.SessionManager.default
            .requestWithoutCache(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    let refineJSON = JSON(items!)
                    let finalValue = refineJSON["results"].arrayValue
                    for items1 in finalValue {
                        ServiceData.palceName.append(items1["name"].stringValue)
                        ServiceData.icon.append(items1["icon"].stringValue)
                        ServiceData.vicinity.append(items1["vicinity"].stringValue)
                        ServiceData.openNow.append(items1["open_now"].intValue)
                        ServiceData.photoReference.append(items1["reference"].stringValue)
                        Geometry.lat.append(items1["geometry"]["location"]["lat"].stringValue)
                        Geometry.long.append(items1["geometry"]["location"]["lng"].stringValue)
                        Type.typesArray = (items1["types"].arrayObject as! [String])
                        ServiceData.types.append(Type.typesArray)
                    }
                    print(ServiceData.types)
                    print(ServiceData.photoReference)
                    print(Geometry.lat)
                    print(Type.typesArray)
                    print(ServiceData.openNow)
                    
                    if (items != nil) {
                        success(ServiceData.photoReference)
                    }
                    break
                case .failure( _):
                    print("error in response")
                    break
                }
        }
        
    }
    
    //Tried to implement the Google Photos service but not returning data till date
    func getPlacePhoto(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        // let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.SessionManager.default
            .requestWithoutCache(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        success(ServiceData.photoReference)
                    }
                    break
                case .failure( _):
                    print("error in response")
                    break
            }
        }
        
    }
}


extension Alamofire.SessionManager{
    @discardableResult
    open func requestWithoutCache(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil)
        -> DataRequest
    {
        do {
            var urlRequest = try URLRequest(url: url, method: method, headers: headers)
            urlRequest.cachePolicy = .reloadIgnoringCacheData // <- Cache disabled
            let encodedURLRequest = try encoding.encode(urlRequest, with: parameters)
            return request(encodedURLRequest)
        } catch {
            print(error)
            return request(URLRequest(url: URL(string: "")!))
        }
    }
}
