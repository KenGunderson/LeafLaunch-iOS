
//
//  APIService+Employees.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 8/24/23.
//

import Foundation
import SwiftDate

extension APIService {
    
    // MARK: - EMPLOYEES
    
    func getEmployees(businessId: String) async throws -> [Employee] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("business/\(businessId)"))
            )
            
            let result: [Employee] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getEmployees(locationId: String) async throws -> [Employee] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("location/\(locationId)"))
            )
            
            let result: [Employee] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getEmployeeByUserIdForLocation(userId: String,
                                        locationId: String) async throws -> String {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("user/\(userId)/location/\(locationId)"))
            )
            
            let result: Employee = try parseData(data: data)
            return result.id
            
        }
        catch {
            throw error
        }
        
    }
    
    func getEmployee(id: String) async throws -> Employee {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("\(id)"))
            )
            
            let result: Employee = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getLocationEmployee(employeeId: String,
                             locationId: String) async throws -> LocationEmployee {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .locationEmployee("user/\(employeeId)/location/\(locationId)"))
            )
            
            let result: LocationEmployee = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createEmployee(employee: Employee) async throws -> Employee {
        
        let parameters: [String: Any] = [
            "user_id": employee.userId,
            "business_id": employee.businessId
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .employee("")),
                parameters: parameters
            )
            
            return .DUMMY_DATA()
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateEmployee(employee: Employee) async throws {
        
        let parameters: [String: Any] = [
            "user_id": employee.userId,
            "business_id": employee.businessId
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .employee("\(employee.id)")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteEmployee(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .employee("\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
