import Foundation

public final class APIConstants {
    public static let applicationJson = "application/json"
    public static let grantTypeRefreshToken = "refresh_token"
    public static let grantTypePassword = "password"
    public static let scope = "*"
    
    public static let loginUserPath = "/oauth/token"
    public static let taxonPath = "/api/taxa"
    public static let registerUserPath = "/api/register"
    public static let myProfilePath = "/api/my/profile"
    public static let deleteUserPath = "/api/users"
    public static let observationsPath = "/api/field-observations"
    
    public static let uploadFindingImagePath = "/api/uploads/photos"
    public static let uploadFindingPath = "/api/field-observations"
    
    public static let getAltitudePath = "/api/elevation"
}
