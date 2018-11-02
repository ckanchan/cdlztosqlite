//
//  Main.swift
//  cdlztosqlite: generates a SQLite store from Oracc CDL ZIP archives
//  Copyright (C) 2018 Chaitanya Kanchan
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import CDKSwiftOracc
import SQLite
import ZIPFoundation

let fileManager = FileManager.default

let decoder = JSONDecoder()

let usageString = """
cdlztosqlite
Generates an SQLite store for use with CDSwiftOracc-based iOS and macOS apps

USAGE

cdlztosqlite [DBPATH] [ARCHIVEPATH]

DBPATH - Path to database; created if it doesn't exist
ARCHIVEPATH - path to archive files. If a folder, recursively imports each archive within the folder.
"""

func getArchive(from path: String) -> Archive? {
    guard fileManager.fileExists(atPath: path) else {return nil}
    guard let archive = Archive(url: URL(fileURLWithPath: path), accessMode: .read) else {return nil}
    
    return archive
}

func main() -> Bool {

    // Check args have been supplied else return
    guard CommandLine.arguments.count == 3 else {
        print(usageString)
        return false
    }
    
    let databasePath = CommandLine.arguments[1]
    let archivePath = CommandLine.arguments[2]
    
    // Initialise a database if valid file at path, else create one
    let database: Connection
    do {
        database = try Connection(databasePath)
        OraccSQLDB.initTable(on: database)
    } catch {
        print(error.localizedDescription)
        return false
    }
    
    // If the path supplied is a folder, check to see if it contains archives and if it does, loop over the archives
    if let contentsOfFolder = try? fileManager.contentsOfDirectory(atPath: archivePath) {
        let absolutePaths = contentsOfFolder.filter({!$0.hasPrefix(".")})
            .sorted()
            .map({archivePath + $0})
        for path in absolutePaths {
            autoreleasepool {
                guard let archive = getArchive(from: path) else {return}
                let prefix = archive.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: "/")
                do {
                    try database.insert(archive: archive, prefix: prefix)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    } else {
        // If path is a single ZIP file, add all CDL JSON
        guard let archive = getArchive(from: archivePath) else {return false}
        let prefix = archive.url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: "/")
        do {
            try database.insert(archive: archive, prefix: prefix)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    return true
}

extension Connection {
    func insert(archive: Archive, prefix: String) throws {
        guard let entry = archive["\(prefix)/catalogue.json"] else {return}
        var data = Data()
        _ = try! archive.extract(entry, consumer: {d in data.append(d)})
        
        let catalogue = try decoder.decode(OraccCatalog.self, from: data)
        let sortedEntries = catalogue.members.values.sorted {
            $0.displayName < $1.displayName
        }
     
        let count = sortedEntries.count
        var counter = 0
        
        for entry in sortedEntries {
            counter += 1
            
            // If the text is already present in the database move on.
            let present = try self.scalar(OraccSQLDB.texts.filter(OraccSQLDB.textid == entry.id.description).count)
            if present != 0 {continue}
            
            guard let textEntry = archive["\(prefix)/corpusjson/\(entry.id).json"] else {continue}
            
            try autoreleasepool {
                var textData = Data()
                _ = try archive.extract(textEntry){textData.append($0)}
                guard let text = try? decoder.decode(OraccTextEdition.self, from: textData) else {return}
                let container = TextEditionStringContainer(text)
                let archiver = NSKeyedArchiver()
                container.encode(with: archiver)
                let data = archiver.encodedData
                
                try self.run(OraccSQLDB.texts.insert(
                    OraccSQLDB.textid <- entry.id.description,
                    OraccSQLDB.project <- entry.project,
                    OraccSQLDB.displayName <- entry.displayName,
                    OraccSQLDB.title <- entry.title,
                    OraccSQLDB.ancientAuthor <- entry.ancientAuthor,
                    
                    OraccSQLDB.chapterNumber <- entry.chapterNumber,
                    OraccSQLDB.chapterName <- entry.chapterName,
                    OraccSQLDB.museumNumber <- entry.museumNumber,
                    
                    OraccSQLDB.genre <- entry.genre,
                    OraccSQLDB.material <- entry.material,
                    OraccSQLDB.period <- entry.period,
                    OraccSQLDB.provenience <- entry.provenience,
                    
                    OraccSQLDB.primaryPublication <- entry.primaryPublication,
                    OraccSQLDB.publicationHistory <- entry.publicationHistory,
                    OraccSQLDB.notes <- entry.notes,
                    OraccSQLDB.credits <- entry.credits,
                    
                    OraccSQLDB.textStrings <- data
                    
                ))
                print("Inserted \(entry.id): \(entry.displayName): \(entry.title), entry \(counter) of \(count)")
            }
        }
    }
}

if main() {
    exit(EXIT_SUCCESS)
} else {
    exit(EXIT_FAILURE)
}
