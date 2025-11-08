//
//  APIService+Form.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 11/6/25.
//

extension APIService {
    
    func getForms(businessId: String) async throws -> [Form] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .forms("businesses/\(businessId)"))
            )
            
            let result: [Form] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getForms(locationId: String) async throws -> [Form] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .forms("locations/\(locationId)"))
            )
            
            let result: [Form] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getForm(formId: String) async throws -> Form {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .forms("\(formId)"))
            )
            
            let result: Form
            = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createForm(form: Form) async throws {
        
        let parameters: [String: Any] = [
            "location_id": form.locationId,
            "title": form.title,
            "media_url": form.mediaURL.absoluteString
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .forms("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateForm(form: Form) async throws {
        
        let parameters: [String: Any] = [
            "id": form.id,
            "title": form.title,
            "location_id": form.locationId,
            "media_url": form.mediaURL.absoluteString
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .forms("\(form.id)")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteForm(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .forms("\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}
