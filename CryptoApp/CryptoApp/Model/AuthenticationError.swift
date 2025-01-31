enum AuthenticationError: Error {
    case invalidCredentials
    case userNotFound
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials provided."
        case .userNotFound:
            return "User not found."
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 