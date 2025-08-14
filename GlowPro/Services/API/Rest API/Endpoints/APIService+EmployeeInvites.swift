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
                apiPath: .init(path: .employee(""))
            )
            
            let result: [EmployeeInvite] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getPendingInvitesForUser() async throws -> [EmployeeInvite] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee(""))
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
                apiPath: .init(path: .employee(""))
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
                apiPath: .init(path: .employee(""))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
