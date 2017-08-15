//
//  AlamofirNetworkConnection.swift
//  Price Hedging
//
//  Created by Cognizant.
//  Copyright © 2017 Cognizant Technologies. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import RealmSwift
import ObjectMapper
import AlamofireObjectMapper
import SwiftyJSON


class AlamofireNetworkConnection: NSObject {
    
    func getCommoditiesNew(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.SessionManager.default
            .requestWithoutCache(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        LoginWebServiceData.loginStatusCode = (response.response?.statusCode)!
                        success(items as! Array<Any>)
                    }
                    break
                case .failure( _):
                    print("error in response")
                    if let statusCode = response.response?.statusCode {
                        LoginWebServiceData.loginStatusCode = statusCode
                    }
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
        
    }
    
    func serviceRequest <T: Object> (_ type: T.Type, url : String,methodType : HTTPMethod,headers : Dictionary<String,String>, params : Dictionary<String, Any>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void)->Void where T:Mappable {
        
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        let postHeader = headers
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        _ = Alamofire.request(url, method: methodType, parameters: params, encoding: URLEncoding.default , headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseArray { (response: DataResponse<[T]>) in
                let items = response.result.value
                if (items != nil) {
                    autoreleasepool {
                        do {
                            
                            let setTrade = items?.first as! SetTradeData
                            print(setTrade.contractMonth!)
                            //                            success(items!)
                        }                     }
                    success(items!)
                }else{
                    fail("Unable to connect to Server")
                }
        }
    }
    
    func geRiskProducts(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        success(items as! Array<Any>)
                    }
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
        
    }
    
    //MARK : geMonthPrices
    func geMonthPrices(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        
        // let urlString = "https://externalstage.commodityhedging.com/extracense/api/quotes"
        let getMonthPriceURLString = CargillConstants.WebservicesConstant.BaseURL + "quotes"
        let fileUrl = NSURL(string: getMonthPriceURLString)
        //let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        let credential = URLCredential(user: UserCredentials.userName, password: UserCredentials.password, persistence: URLCredential.Persistence.none)
        var request = URLRequest(url: fileUrl as! URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //we need to send the quote type as "mkt" here as mentioned in th services document
        let parametersDictionary:[String: Any] = ["quoteType":SetTradeUserInput.priceQuoteType , "underlyings": SetTradeUserInput.monthCode]
        print(parametersDictionary)
        var header = [String: String]()
        header.updateValue("application/json", forKey: "Content-Type")
        
        Alamofire.request(url, method: methodType, parameters: parametersDictionary, encoding: encodingType, headers: header)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        let refinedResponse = JSON(items!)
                        
                        SetTradeUserInput.askPriceList.removeAll()
                        SetTradeUserInput.bidPriceList.removeAll()
                        //Create Ask Price Array
                        for responseObj in refinedResponse["quotes"] {
                            SetTradeUserInput.askPriceList.append((responseObj.1.dictionary?["askPrice"]?.stringValue)!)
                            
                        }
                        
                        //Create Bid price Array
                        for responseObj in refinedResponse["quotes"] {
                            SetTradeUserInput.bidPriceList.append((responseObj.1.dictionary?["bidPrice"]?.stringValue)!)
                        }
                        
                        print(refinedResponse)
                        success(SetTradeUserInput.bidPriceList)
                        
                    }
                    break
                    
                case .failure( _):
                    print("error in response")
                    if let statusCode = response.response?.statusCode {
                        SetTradeUserInput.priceServiceStatusCode = statusCode
                    }
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    //get the first monthprices , This returns first month's bid price
    func getFirstMonthPrices(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseString:String) -> Void, fail:@escaping (_ error:String)->Void) {
        
        let urlString = CargillConstants.WebservicesConstant.BaseURL + "quotes"
        
        
        let fileUrl = NSURL(string: urlString)
        
        //let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        let credential = URLCredential(user: UserCredentials.userName, password: UserCredentials.password, persistence: URLCredential.Persistence.forSession)
        var request = URLRequest(url: fileUrl as! URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //we need to send the quote type as "mkt" here as mentioned in th services document
        //let parametersDictionary:[String: Any] = ["quoteType":SetTradeUserInput.priceQuoteType , "underlyings": SetTradeUserInput.monthCode]
        //print(parametersDictionary)
        var header = [String: String]()
        header.updateValue("application/json", forKey: "Content-Type")
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: header)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        let refinedResponse = JSON(items!)
                        //Create Bid price Array
                        //for responseObj in refinedResponse["quotes"] {
                        if let bidPrice = (refinedResponse["quotes"].first?.1.dictionary?["bidPrice"]?.stringValue) {
                            FirstMonthBidPrice.bidPrice = bidPrice
                        }else {
                            FirstMonthBidPrice.bidPrice = "0"
                        }
                        
                        if let askPrice = (refinedResponse["quotes"].first?.1.dictionary?["askPrice"]?.stringValue) {
                            FirstMonthBidPrice.askPrice = askPrice
                        }else {
                            FirstMonthBidPrice.askPrice = "0"
                        }
                        print(refinedResponse)
                        success(FirstMonthBidPrice.bidPrice)
                        
                    }
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    
    //get the expirationDate
    
    func getExpirationDate(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        //success(items as! Array<Any>)
                        let refinedResponse = JSON(items!)
                        print(refinedResponse["lastTradeDate"])
                        SetTradeUserInput.serviceOrderExpirationDate = (refinedResponse.dictionary?["lastTradeDate"]?.stringValue)!
                    }
                    success([SetTradeUserInput.serviceOrderExpirationDate])
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
        
    }
    
    
    
    func getQuotePrice(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        //success(items as! Array<Any>)
                        let refinedJson = JSON(items!).dictionaryValue
                        if response.response?.statusCode == 200 {
                            SetTradeUserInput.serviceStatusCode = 200
                            if let marketPrice = (refinedJson["midMarketMark"]) {
                                SetTradeUserInput.midMarketPrice = marketPrice.stringValue
                            }
                            if let quoteID = (refinedJson["quoteId"]) {
                                SetTradeUserInput.generatedQuoteID = quoteID.stringValue
                            }
                        }else {
                            SetTradeUserInput.serviceStatusCode = (response.response?.statusCode)!
                        }
                    }
                    success(SetTradeUserInput.monthsArray)
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
        
    }
    
    func placeTrade(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        //success(items as! Array<Any>)
                        let refinedJson = JSON(items!).dictionary
                        if response.response?.statusCode == 201 {
                            SetTradeUserInput.serviceStatusCode = 201
                            if let confirmationID = (refinedJson?["id"]) {
                                SetTradeUserInput.tradeConfirmationID = confirmationID.stringValue
                            }
                            //SetTradeUserInput.generatedQuoteID = (refinedJson["quoteId"]?.stringValue)!
                            SetTradeUserInput.serviceStatusCode = (response.response?.statusCode)!

                        }else {
                            SetTradeUserInput.serviceStatusCode = (response.response?.statusCode)!
                            if !(JSON(value).first?.1["message"].stringValue)!.isEmpty {
                                ErrorMessage.errorMessage = (JSON(value).first?.1["message"].stringValue)!
                            } else {
                                ErrorMessage.errorMessage = ""
                            }
                        }
                    }
                    success(SetTradeUserInput.monthsArray)
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
        
    }
    
    //Service to call Open Orders
    func fetchOrders<T: Object> (_ type: T.Type, url : String,methodType : HTTPMethod,headers : Dictionary<String,String>, params : Dictionary<String, Any>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void)->Void where T:Mappable {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        let postHeader = headers
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        _ = Alamofire.request(url, method: methodType, parameters: params, encoding: URLEncoding.default , headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseObject { (response: DataResponse<T>) in
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        
                        let orders = Array((items! as! Orders).value)
                        success(orders)
                    }
                    break
                    
                case .failure( _):
                    print("error in response")
                    OrdersScrennServiceData.workingOrdersStatusCode = (response.response?.statusCode)!
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    
    //Service to call Open Positions
    func fetchOpenPositions<T: Object> (_ type: T.Type, url : String,methodType : HTTPMethod,headers : Dictionary<String,String>, params : Dictionary<String, Any>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void)->Void where T:Mappable {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        let postHeader = headers
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        _ = Alamofire.request(url, method: methodType, parameters: params, encoding: URLEncoding.default , headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseArray { (response: DataResponse<[T]>) in
                if let statusCode = response.response?.statusCode {
                    OrdersScrennServiceData.openPositionsStatusCode = statusCode
                }
                if OrdersScrennServiceData.openPositionsStatusCode == 200 {
                    let items = response.result.value
                    if (items != nil) {
                        autoreleasepool {
                            do {
                                
                                let openPositions = items?.first as! OpenPositions
                                print(openPositions.positionID)
                                //                            success(items!)
                            } catch let error as NSError {
                                fail(error.localizedDescription)
                            }
                        }
                        success(items!)
                        
                    } else {
                        success([])
                        
                    }
                }else{
                    if response.response?.statusCode != nil {
                        OrdersScrennServiceData.openPositionsStatusCode = (response.response?.statusCode)!
                    } else {
                        OrdersScrennServiceData.openPositionsStatusCode = 0
                    }
                    fail("Unable to connect to Server")
                }
        }
    }
    
    
    //Service to call Closed Positions
    func fetchClosedPositions<T: Object> (_ type: T.Type, url : String,methodType : HTTPMethod,headers : Dictionary<String,String>, params : Dictionary<String, Any>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void)->Void where T:Mappable {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        let postHeader = headers
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        _ = Alamofire.request(url, method: methodType, parameters: params, encoding: URLEncoding.default , headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseArray { (response: DataResponse<[T]>) in
                if let statusCode = response.response?.statusCode {
                    OrdersScrennServiceData.openPositionsStatusCode = statusCode
                }
                if OrdersScrennServiceData.openPositionsStatusCode == 200 {
                    let items = response.result.value
                    if (items != nil) {
                        autoreleasepool {
                            do {
                                
                                //let closedPositions = items?.first as! Orders
                                //print(closedPositions.orderId)
                                //                            success(items!)
                            } catch let error as NSError {
                                fail(error.localizedDescription)
                            }
                        }
                        success(items!)
                    }else {
                        success([])
                        
                    }
                }else{
                    OrdersScrennServiceData.closedOrdersStatusCode = (response.response?.statusCode)!
                    fail("Unable to connect to Server")
                }
        }
    }
    
    //Service to call Closed Positions
    func unwindOpenPosition<T: Object> (_ type: T.Type, url : String,methodType : HTTPMethod,headers : Dictionary<String,String>, params : Dictionary<String, Any>, success:@escaping (_ responseArray:T) -> Void, fail:@escaping (_ error:String)->Void)->Void where T:Mappable {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        let postHeader = headers
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        _ = Alamofire.request(url, method: methodType, parameters: params, encoding: URLEncoding.default , headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseObject { (response: DataResponse<T>) in
                let items = response.result.value
                if (items != nil) {
                    autoreleasepool {
                        do {
                            
                            //let closedPositions = items?.first as! Orders
                            //print(closedPositions.orderId)
                            //                            success(items!)
                        } catch let error as NSError {
                            fail(error.localizedDescription)
                        }
                    }
                    success(items!)
                }else{
                    fail("Unable to connect to Server")
                }
        }
    }
    
    
    //Cancel order service
    
    
    func cancelOrder(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseArray:Array<Any>) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        //success(items as! Array<Any>)
                        let refinedJson = JSON(items!).dictionary
                        // 202 Cancel status code
                        if response.response?.statusCode == 202 {
                            SetTradeUserInput.serviceStatusCode = 202
                            if let confirmationID = (refinedJson?["id"]) {
                                SetTradeUserInput.tradeConfirmationID = confirmationID.stringValue
                            }
                            //SetTradeUserInput.generatedQuoteID = (refinedJson["quoteId"]?.stringValue)!
                        }else {
                            SetTradeUserInput.serviceStatusCode = (response.response?.statusCode)!
                            if !(JSON(value).first?.1["message"].stringValue)!.isEmpty {
                                ErrorMessage.errorMessage = (JSON(value).first?.1["message"].stringValue)!
                            } else {
                                ErrorMessage.errorMessage = ""
                            }
                        }
                    }else {
                        
                         CancelStatusCode.statusCode = ServiceErrorCodeHandler().handleServiceErrorcCodes(statusCode: (response.response?.statusCode)!)

                    }
                    success(SetTradeUserInput.monthsArray)
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    func fetchWorkingOrdersCountInDashBoard(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseString:String) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        let refinedResponse = JSON(items!).dictionaryValue
                        print(refinedResponse)
                        DashboardServiceData.workingOrdersCount = (refinedResponse["totalCount"]!.stringValue)
                        DashboardServiceData.workingOrdersQuantity = (refinedResponse["totalQuantity"]!.stringValue)
                        success(DashboardServiceData.workingOrdersCount)
                        
                    }
                    
                    
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    func fetchOpenPositionsCountInDashBoard(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseString:String) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        let refinedResponse = JSON(items!).dictionaryValue
                        print(refinedResponse)
                        DashboardServiceData.openPositionsCount = (refinedResponse["totalCount"]!.stringValue)
                        DashboardServiceData.openPositionsValue = (refinedResponse["totalTradeAmount"]!.stringValue)
                        DashboardServiceData.openPositionsQuantity = (refinedResponse["totalQuantity"]!.stringValue)
                        success(DashboardServiceData.openPositionsQuantity )
                        
                    }
                    
                    
                    break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
    
    
    func fetchOpenPositionsCountInSetTradeScreen(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>, success:@escaping (_ responseString:String) -> Void, fail:@escaping (_ error:String)->Void) {
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        //postHeader.updateValue("application/json", forKey:"content-type")
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseJSON { response in
                
                
                
                switch response.result {
                case .success(let value):
                    print("responseObject = \(value)")
                    let items = response.result.value
                    if (items != nil) {
                        let refinedResponse = JSON(items!).dictionaryValue
                        print(refinedResponse)
                        SetTradeOpenPositionsServiceData.openPositionsCount = (refinedResponse["totalCount"]!.stringValue)
                        SetTradeOpenPositionsServiceData.openPositionsValue = (refinedResponse["totalTradeAmount"]!.stringValue)
                        SetTradeOpenPositionsServiceData.openPositionsQuantity = (refinedResponse["totalQuantity"]!.stringValue)
                        success(SetTradeOpenPositionsServiceData.openPositionsQuantity )
                        
                    }
                      break
                    
                case .failure( _):
                    print("error in response")
                    fail((response.error?.localizedDescription
                        )!)
                    break
                    //completionHandler(nil, error)
                }
        }
    }
     func getURLCredential(username: String, password: String) -> URLCredential {
        let credential = URLCredential(user: username, password: password, persistence: URLCredential.Persistence.none)
        return credential
    }
    
    func getUnderlying(url : String, methodType: HTTPMethod, encodingType: ParameterEncoding, params : Dictionary<String, Any>, postHeader : Dictionary<String, String>) {
        
        let credential = getURLCredential(username: UserCredentials.userName, password: UserCredentials.password)
        
        Alamofire.request(url, method: methodType, parameters: params, encoding: encodingType, headers: postHeader)
            .authenticate(usingCredential: credential)
            .responseArray { (response: DataResponse<[SetTradeData]>) in
                
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
            return request(URLRequest(url: URL(string: CargillConstants.WebservicesConstant.BaseURL)!))
        }
    }
}
