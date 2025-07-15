import Foundation

public final class APIConstants {
    public static let applicationJson = "application/json"
    public static let userAgentName = "BiologerApp"
    public static let grantTypeRefreshToken = "refresh_token"
    public static let grantTypePassword = "password"
    public static let scope = "*"
    
    public static let taxonsPerPage = 200
    public static let filesTimestamp: Int64 = 1752595284
    
    public static let loginUserPath = "/oauth/token"
    public static let taxonPath = "/api/taxa"
    public static let registerUserPath = "/api/register"
    public static let myProfilePath = "/api/my/profile"
    public static let deleteUserPath = "/api/users"
    public static let observationTypesPath = "/api/observation-types"
    
    public static let updatedAfter = "updated_after"
    
    public static let uploadFindingImagePath = "/api/uploads/photos"
    public static let uploadFindingPath = "/api/field-observations"
    
    public static let getAltitudePath = "/api/elevation"
    
    public static let serbiaHost = "biologer.rs"
    public static let serbiaLangPath = "/sr-Latn"
    
    public static let croatiaHost = "biologer.hr"
    public static let croatiaLangPath = "/hr"
    
    public static let bosnianAndHerzegovinHost = "biologer.ba"
    public static let bosnianAndHerzegovinaLangPath = "/bs"
    
    public static let montenegroHost = "biologer.me"
    public static let montenegroLangPath = "/me"
    
    public static let devHost = "dev.biologer.org"
    public static let devLangPath = "/en"
}
