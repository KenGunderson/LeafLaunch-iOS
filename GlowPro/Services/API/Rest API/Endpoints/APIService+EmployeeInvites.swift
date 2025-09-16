//
//  APIService+EmployeeInvites.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/10/25.
//

extension APIService {
    
    func getEmployeeInvites(businessId: String) async throws -> [EmployeeInvite] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employeeInvite("/businesses/\(businessId)"))
            )
            
            let result: [EmployeeInvite] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getPendingInvitesForUser(email: String) async throws -> [EmployeeInvite] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employeeInvite("email/\(email)"))
            )
            
            let result: [EmployeeInvite] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func acceptEmployeeInvite(invite: EmployeeInvite) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .employeeInvite("\(invite.id)/accept"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func declineEmployeeInvite(invite: EmployeeInvite) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .employeeInvite("\(invite.id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func createEmployeeInvite(invite: EmployeeInvite) async throws {
        
        let parameters: [String: Any] = [
            "email": invite.email,
            "name": invite.name,
            "role": invite.role?.rawValue,
            "business_id": invite.businessId,
            "business_name": invite.businessName,
            "location_ids": invite.locationIds
        ]
        .compact()
        
        do {
            
            _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .employeeInvite("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteEmployeeInvite(invite: EmployeeInvite) async throws {
        
        do {
            
            _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .employeeInvite("\(invite.id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
