//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import Alamofire
import EVReflection

/**
 Storefront object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Storefront.html)
 */
public class Storefront: EVObject {

    public var name: String?
    public var storefrontId: Int?
    public var supportedLanguageTags: [String]?
    public var defaultLanguageTag: String?

    public override func setValue(_ value: Any!, forUndefinedKey key: String) {
        if key == "storefrontId" {
            if let rawValue = value as? Int {
                storefrontId = rawValue
            }
        }
    }

}

public extension ASAppleMusic {

    /**
     Get Storefront based on the `id` of the store

     - Parameters:
        - id: The id of the store in two-letter code. Example: `"us"`
        - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
        - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *AMError*
        - storefront: the `Storefront` object itself
        - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts/us*
     */
    func getStorefront(withID id: String, lang: String? = nil, completion: @escaping (_ storefront: Storefront?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let data = response["data"] as? [[String:Any]],
                        let resource = data.first,
                        let attributes = resource["attributes"] as? NSDictionary {
                        let storefront = Storefront(dictionary: attributes)
                        completion(storefront, nil)
                        self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    } else if let response = response.result.value as? [String:Any],
                        let errors = response["errors"] as? [[String:Any]],
                        let errorDict = errors.first as NSDictionary? {
                        let error = AMError(dictionary: errorDict)

                        self.print("[ASAppleMusic] 🛑: \(error.title ?? "") - \(error.status ?? "")")

                        completion(nil, error)
                    } else {
                        self.print("[ASAppleMusic] 🛑: Unauthorized request")

                        let error = AMError()
                        error.status = "401"
                        error.code = .unauthorized
                        error.title = "Unauthorized request"
                        error.detail = "Missing token, refresh current token or request a new token"
                        completion(nil, error)
                    }
            }
        }
    }

    /**
     Get several Storefront objects based on the `ids` of the stores that you want to get

     - Parameters:
         - ids: An id array of the stores in two-letter code. Example: `["us", "es", "jp"]`
         - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
         - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *Storefront*, *AMError*
         - storefront: the `Storefront` object itself
         - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts?ids=us,es,jp*
     */
    func getMultipleStorefronts(withIDs ids: [String], lang: String? = nil, completion: @escaping (_ storefronts: [Storefront]?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts?ids=\(ids.joined(separator: ","))"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var storefronts: [Storefront]?
                        if resources.count > 0 {
                            storefronts = []
                        }
                        resources.forEach { storefrontData in
                            if let attributes = storefrontData["attributes"] as? NSDictionary {
                                storefronts?.append(Storefront(dictionary: attributes))
                            }
                        }
                        completion(storefronts, nil)
                        self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    } else if let response = response.result.value as? [String:Any],
                        let errors = response["errors"] as? [[String:Any]],
                        let errorDict = errors.first as NSDictionary? {
                        let error = AMError(dictionary: errorDict)

                        self.print("[ASAppleMusic] 🛑: \(error.title ?? "") - \(error.status ?? "")")

                        completion(nil, error)
                    } else {
                        self.print("[ASAppleMusic] 🛑: Unauthorized request")

                        let error = AMError()
                        error.status = "401"
                        error.code = .unauthorized
                        error.title = "Unauthorized request"
                        error.detail = "Missing token, refresh current token or request a new token"
                        completion(nil, error)
                    }
            }
        }
    }

    /**
     Get all the Storefront objects. You can decide the limit of stores to get and the offset per page as *Optional* parameters

     - Parameters:
         - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
         - limit: (Optional) The limit of stores to get
         - offset: (Optional) The *page* of the results to get
         - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[Storefront]*, *AMError*
         - storefront: the `[Storefront]` array of objects
         - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/storefronts?l=en-us&limit=2&offset=2*
     */
    func getAllStorefronts(lang: String? = nil, limit: Int? = nil, offset: Int? = nil, completion: @escaping (_ storefronts: [Storefront]?, _ error: AMError?) -> Void) {
        callWithToken { token in
            guard let token = token else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            let headers = [
                "Authorization": "Bearer \(token)"
            ]
            var url = "https://api.music.apple.com/v1/storefronts"
            var params: [String] = []
            if let lang = lang {
                params.append("l=\(lang)")
            }
            if let limit = limit {
                params.append("limit=\(limit)")
            }
            if let offset = offset {
                params.append("offset=\(offset)")
            }
            if !params.isEmpty {
                url = url + "?" + params.joined(separator: "&")
            }
            Alamofire.request(url, headers: headers)
                .responseJSON { (response) in
                    self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                    if let response = response.result.value as? [String:Any],
                        let resources = response["data"] as? [[String:Any]] {
                        var storefronts: [Storefront]?
                        if resources.count > 0 {
                            storefronts = []
                        }
                        resources.forEach { storefrontData in
                            if let attributes = storefrontData["attributes"] as? NSDictionary {
                                storefronts?.append(Storefront(dictionary: attributes))
                            }
                        }
                        completion(storefronts, nil)

                        self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    } else if let response = response.result.value as? [String:Any],
                        let errors = response["errors"] as? [[String:Any]],
                        let errorDict = errors.first as NSDictionary? {
                        let error = AMError(dictionary: errorDict)

                        self.print("[ASAppleMusic] 🛑: \(error.title ?? "") - \(error.status ?? "")")

                        completion(nil, error)
                    } else {
                        self.print("[ASAppleMusic] 🛑: Unauthorized request")

                        let error = AMError()
                        error.status = "401"
                        error.code = .unauthorized
                        error.title = "Unauthorized request"
                        error.detail = "Missing token, refresh current token or request a new token"
                        completion(nil, error)
                    }
            }
        }
    }

}
