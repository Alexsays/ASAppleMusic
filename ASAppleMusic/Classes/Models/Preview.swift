//
//  Alex Silva - 2018
//  alex@alexsays.info
//

import Foundation
import EVReflection

/**
 Playlist Type object representation. For more information take a look at [Apple Music API](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/Preview.html)
 */
public class Preview: EVObject {

    public var url: String?
    public var artwork: Artwork?

}
