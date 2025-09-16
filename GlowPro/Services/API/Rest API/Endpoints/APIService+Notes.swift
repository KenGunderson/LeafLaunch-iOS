//
//  APIService+Notes.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

extension APIService {

    func getNotes(clientId: String) async throws -> [Note] {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .notes("clients/\(clientId)"))
            )
            
            let result: [Note] = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func getNote(id: String) async throws -> Note {
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .notes("\(id)"))
            )
            
            let result: Note = try parseData(data: data)
            return result
            
        }
        catch {
            throw error
        }
        
    }
    
    func createNote(note: Note) async throws {
        
        let parameters: [String: Any] = [
            "client_id": note.clientId,
            "employee_id": note.employeeId,
            "title": note.title,
            "message": note.message,
            "media_urls": []
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .post,
                apiPath: .init(path: .notes("")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func updateNote(note: Note) async throws {
        
        let parameters: [String: Any] = [
            "id": note.id,
            "client_id": note.clientId,
            "employee_id": note.employeeId,
            "title": note.title,
            "message": note.message,
            "media_urls": []
        ]
        .compact()
        
        do {
            
            let _ = try await buildRequest(
                method: .put,
                apiPath: .init(path: .notes("\(note.id)")),
                parameters: parameters
            )
            
        }
        catch {
            throw error
        }
        
    }
    
    func deleteNote(id: String) async throws {
        
        do {
            
            let _ = try await buildRequest(
                method: .delete,
                apiPath: .init(path: .notes("\(id)"))
            )
            
        }
        catch {
            throw error
        }
        
    }
    
}

