import Foundation

enum RequestBody {

    case none
    case json([String: Any])
    case multipart(boundary: String, data: Data)

}
