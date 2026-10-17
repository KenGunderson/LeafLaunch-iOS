import Foundation

internal enum HTTPRequestMethod: String, Sendable {

    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
    case head = "HEAD"

}
