import Foundation

struct APIErrorResponse: Decodable {

    let name: String
    let statusCode: Int?
    let message: String?
    let metadata: APIError.PlatformError?

}
