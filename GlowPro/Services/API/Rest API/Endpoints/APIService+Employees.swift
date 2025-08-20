
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
                apiPath: .init(path: .employee(""))
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
                apiPath: .init(path: .employee(""))
            )
            
            let result: [Employee] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getEmployeeByUserIdForLocation(userId: String, locationId: String) async throws -> Employee {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("/\(userId)"))
            )
            
            let result: Employee = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getEmployee(id: String) async throws -> Employee {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .employee("/\(id)"))
            )
            
            let result: Employee = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createEmployee(employee: Employee) async throws -> Employee {
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .employee(""))
            )
            
            return .DUMMY_DATA()
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateEmployee(employee: Employee) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .employee(""))
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
                apiPath: .init(path: .employee("/\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
