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
    
}
