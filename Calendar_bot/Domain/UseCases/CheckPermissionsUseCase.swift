import Foundation

final class CheckPermissionsUseCase {

    private let permissionService: PermissionServiceProtocol

    init(permissionService: PermissionServiceProtocol) {
        self.permissionService = permissionService
    }

    func execute() -> PermissionState {
        permissionService.checkPermissions()
    }
}
