//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation

/**
 LibraryArtist object representation. For more information take a look at [Apple Music API](https://developer.apple.com/documentation/applemusicapi/libraryartist)
 */
public class AMLibraryArtist: Codable, AMResource {

    public class Attributes: Codable {

        /// (Required) The artist’s name.
        public var name: String = ""

    }

    public class Relationships: Codable {

        /// The library albums associated with the artist. By default, albums is not included. It is available only when fetching a single library artist resource by ID.
        public var albums: AMRelationship.LibraryAlbum?

    }

    public class Response: Codable {

        /// The data included in the response for a library artist object request.
        public var data: [AMLibraryArtist]?

        /// An array of one or more errors that occurred while executing the operation.
        public var errors: [AMError]?

        /// A link to the request that generated the response data or results; not present in a request.
        public var href: String?

        /// A link to the next page of data or results; contains the offset query parameter that specifies the next page.
        public var next: String?

    }

    /// The attributes for the library artist.
    public var attributes: Attributes?

    /// The relationships for the library artist.
    public var relationships: Relationships?

    // Always libraryArtists.
    public var type: String = "libraryArtists"

}

public extension ASAppleMusic {

    /**
     Get LibraryArtist based on the id of the `storefront` and the artist `id`

     - Parameters:
     - id: The id of the artist (Number). Example: `"179934"`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *LibraryArtist*, *AMError*
     - artist: the `LibraryArtist` object itself
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/artists/179934*
     */
    func getLibraryArtist(withID id: String, lang: String? = nil, completion: @escaping (_ artist: AMLibraryArtist?, _ error: AMError?) -> Void) {
        callWithToken { devToken, userToken in
            guard let devToken = devToken, let userToken = userToken else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/me/library/artists/\(id)"
            if let lang = lang {
                url = url + "?l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibraryArtist.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMLibraryArtist.Response.self, from: data)
                    completion(response?.data?.first, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

    /**
     Get several LibraryArtist objects based on the `ids` of the artists that you want to get

     - Parameters:
     - ids: (Optional) An id array of the artists. Example: `["179934", "463106"]`
     - lang: (Optional) The language that you want to use to get data. **Default value: `en-us`**
     - completion: The completion code that will be executed asynchronously after the request is completed. It has two return parameters: *[LibraryArtist]*, *AMError*
     - artists: the `[LibraryArtist]` array of objects
     - error: if the request you will get an `AMError` object

     **Example:** *https://api.music.apple.com/v1/me/library/artists?ids=179934,463106*
     */
    func getMultipleLibraryArtists(withIDs ids: [String]? = nil, lang: String? = nil, completion: @escaping (_ artists: [AMLibraryArtist]?, _ error: AMError?) -> Void) {
        callWithToken { devToken, userToken in
            guard let devToken = devToken, let userToken = userToken else {
                let error = AMError()
                error.status = "401"
                error.code = .unauthorized
                error.title = "Unauthorized request"
                error.detail = "Missing token, refresh current token or request a new token"
                completion(nil, error)
                self.print("[ASAppleMusic] 🛑: Missing token")
                return
            }
            var url = "https://api.music.apple.com/v1/me/library/artists"
            if let ids = ids {
                url = url + "?ids=\(ids.joined(separator: ","))&"
            } else {
                url = url + "?"
            }
            if let lang = lang {
                url = url + "l=\(lang)"
            }
            guard let callURL = URL(string: url) else {
                self.print("[ASAppleMusic] 🛑: Failed to create URL")
                completion(nil, nil)
                return
            }
            var request = URLRequest(url: callURL)
            request.addValue("Bearer \(devToken)", forHTTPHeaderField: "Authorization")
            request.addValue(userToken, forHTTPHeaderField: "Music-User-Token")
            URLSession.init().dataTask(with: request, completionHandler: { data, response, error in
                self.print("[ASAppleMusic] Making Request 🌐: \(url)")
                let decoder = JSONDecoder()
                if let error = error {
                    self.print("[ASAppleMusic] 🛑: \(error.localizedDescription)")
                    if let data = data, let response = try? decoder.decode(AMLibraryArtist.Response.self, from: data),
                        let amError = response.errors?.first {
                        completion(nil, amError)
                    } else {
                        let amError = AMError()
                        if let response = response, let statusCode = response.getStatusCode(),
                            let code = Code(rawValue: String(statusCode * 100)) {
                            amError.status = String(statusCode)
                            amError.code = code
                        }
                        amError.detail = error.localizedDescription
                        completion(nil, amError)
                    }
                } else if let data = data {
                    self.print("[ASAppleMusic] Request Succesful ✅: \(url)")
                    let response = try? decoder.decode(AMLibraryArtist.Response.self, from: data)
                    completion(response?.data, nil)
                } else {
                    completion(nil, nil)
                }
            }).resume()
        }
    }

}
