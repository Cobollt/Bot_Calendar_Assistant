import Foundation

protocol PermissionServiceProtocol {
    func checkPermissions() -> PermissionState
    func requestCalendarAccess() async throws -> Bool
}
