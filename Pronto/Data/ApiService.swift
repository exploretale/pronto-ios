//
//  ApiService.swift
//  Pronto
//
//  Created by John Eris Villanueva on 12/2/17.
//  Copyright © 2017 John Eris Villanueva. All rights reserved.
//

import Alamofire
import Moya
import ObjectMapper

class ApiService: RxMoyaProvider<Service> {
    
    static let instance: ApiService = ApiService()
    
    init() {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: true
            )
        ]
        
        let manager = Manager(
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        super.init(manager: manager, plugins: [NetworkLoggerPlugin()])
    }
}

enum Service {
    
    case search(param: FoodParam)
    
}

extension Service: TargetType {
    
    static func getBaseUrl() -> String {
        //128.199.217.76
        let urlString = "http://128.199.217.76/py/pronto-py/api/"
        return urlString
    }
    
    var baseURL: URL {
        let urlString = Service.getBaseUrl()
        return URL(string: urlString)!
    }
    
    var path: String {
        switch self {
        case .search:
            return "search"
        }
    }
    
    var method: Moya.Method {
        switch self {
//        case .login:
//            return .post
        default:
            return .get
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .search(let param):
            return param.toJSON()
            //        case .jsonArrayParam(let param):
            //            return ["jsonArray": param.toJSON()]
            //        default:
            //            return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
//        case :
//            return JsonArrayEncoding.default
        default:
            if self.method == .get {
                return URLEncoding.default
            }
            return JSONEncoding.default
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    
    // sample multipart upload
    var task : Task {
        //        switch self {
        //        case .updateProfileImage(let image):
        //            let imageData = UIImageJPEGRepresentation(image, 1.0)
        //            let formData = [MultipartFormData(provider: .data(imageData!), name: "image", fileName: "photo.jpg", mimeType: "image/jpeg")]
        //            return .upload(UploadType.multipart(formData))
        //        default:
        return .request
        //        }
    }
    
}

extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}

struct JsonArrayEncoding: Moya.ParameterEncoding {
    
    public static var `default`: JsonArrayEncoding { return JsonArrayEncoding() }
    
    /// Creates a URL request by encoding parameters and applying them onto an existing request.
    ///
    /// - parameter urlRequest: The request to have parameters applied.
    /// - parameter parameters: The parameters to apply.
    ///
    /// - throws: An `AFError.parameterEncodingFailed` error if encoding fails.
    ///
    /// - returns: The encoded request.
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var req = try urlRequest.asURLRequest()
        let json = try JSONSerialization.data(withJSONObject: parameters!["jsonArray"]!, options: JSONSerialization.WritingOptions.prettyPrinted)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        req.httpBody = json
        return req
    }
    
}
