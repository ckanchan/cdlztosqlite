//
//  DatabaseSchema.swift
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
import SQLite

enum OraccSQLDB {
    //Base data
    static let textid = Expression<String>("textid")
    static let project = Expression<String>("project")
    static let displayName = Expression<String>("display_name")
    static let title = Expression<String>("title")
    static let ancientAuthor = Expression<String?>("ancient_author")
    
    // Additional catalogue data
    static let chapterNumber = Expression<Int?>("chapter_num")
    static let chapterName = Expression<String?>("chapter_name")
    static let museumNumber = Expression<String?>("museum_num")
    
    //Archaeological data
    static let genre = Expression<String?>("genre")
    static let material = Expression<String?>("material")
    static let period = Expression<String?>("period")
    static let provenience = Expression<String?>("provenience")
    
    
    //Publication data
    static let primaryPublication = Expression<String?>("primary_publication")
    static let publicationHistory = Expression<String?>("publication_history")
    static let notes = Expression<String?>("notes")
    static let credits = Expression<String?>("credits")
    
    //Location data
    static let pleiadesID = Expression<Int?>("pleiades_id")
    static let pleiadesCoordinateX = Expression<Double?>("pleiades_coordinate_x")
    static let pleiadesCoordinateY = Expression<Double?>("pleiades_coordinate_y")
    
    // A place to encode TextEditionStringContainer with NSCoding
    static let textStrings = Expression<Data>("Text")
    
    
    static let texts = Table("texts")
    static func initTable(on connection: Connection){
        do {
            try connection.run(OraccSQLDB.texts.create(ifNotExists: true) { t in
                
                //Base data
                t.column(OraccSQLDB.textid, primaryKey: true)
                t.column(OraccSQLDB.project)
                t.column(OraccSQLDB.displayName)
                t.column(OraccSQLDB.title)
                t.column(OraccSQLDB.ancientAuthor)
                
                // Additional catalogue data
                t.column(OraccSQLDB.chapterNumber)
                t.column(OraccSQLDB.chapterName)
                t.column(OraccSQLDB.museumNumber)
                
                //Archaeological data
                t.column(OraccSQLDB.genre)
                t.column(OraccSQLDB.material)
                t.column(OraccSQLDB.period)
                t.column(OraccSQLDB.provenience)
                
                //Publication data
                t.column(OraccSQLDB.primaryPublication)
                t.column(OraccSQLDB.publicationHistory)
                t.column(OraccSQLDB.notes)
                t.column(OraccSQLDB.credits)
                
                //Pleiades data
                t.column(OraccSQLDB.pleiadesID)
                t.column(OraccSQLDB.pleiadesCoordinateX)
                t.column(OraccSQLDB.pleiadesCoordinateY)
                
                t.column(OraccSQLDB.textStrings)
            })
        } catch {
            print(error)
        }
    }
}


 







