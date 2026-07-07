import Foundation

final class RequestAllPermissionsUseCase {

    private let permissionService: PermissionServiceProtocol

    init(permissionService: PermissionServiceProtocol) {
        self.permissionService = permissionService
    }

    func execute() async throws -> PermissionState {
        try await permissionService.requestAllPermissions()
    }
}
