//
//  APIService+Notes.swift
//  GlowPro
//
//  Created by Sako Hovaguimian on 9/13/25.
//

extension APIService {
    
    func getNotes(clientId: String,
                  query: Query,
                  noteTypeFilter: NoteType?) async throws -> [Note] {
        
        var queryParameters: [String: String] = [
            "limit": "\(query.limit)",
            
        ]
        
        if let filter = noteTypeFilter {
            queryParameters["type"] = filter.rawValue
        }
        
        do {
            
            let data = try await buildRequest(
                method: .get,
                apiPath: .init(path: .notes("clients/\(clientId)")),
                queryParameters: queryParameters
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
            "type": note.type.rawValue,
            "metadata": note.metadata?.toDictionary(),
            "media_urls": note.mediaURLs.map({ $0.absoluteString })
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
            "type": note.type.rawValue,
            "metadata": note.metadata?.toDictionary(),
            "media_urls": note.mediaURLs.map({ $0.absoluteString })
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

