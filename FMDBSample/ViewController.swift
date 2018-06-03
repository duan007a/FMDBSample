//
//  ViewController.swift
//  FMDBSample
//
//  Created by 段洪春 on 2018/6/3.
//  Copyright © 2018年 RS. All rights reserved.
//

import UIKit
import FMDB

class ViewController: UIViewController {
    var dbPath: String!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString;
        dbPath = documentDir.appendingPathComponent("user.sqlite");
        print("%@", dbPath);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func createTable(_ sender: Any) {
        print("createTable")
        
        if (!FileManager.default.fileExists(atPath: self.dbPath)) {
            // create it
            let db = FMDatabase.init(path: self.dbPath)
            if (db.open()) {
                let sql = "CREATE TABLE 'User' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'name' VARCHAR(30), 'password' VARCHAR(30))";
                let res = db.executeStatements(sql)
                if (!res) {
                    print("error when creating db table");
                } else {
                    print("succ to creating db table");
                }
                db.close()
            } else {
                print("error when open db");
            }
        }
    }
    
    @IBAction func insertTable(_ sender: Any) {
        print("insertTable")
        struct Holder {
            static var idx = 1
        }
        
        let db = FMDatabase.init(path: self.dbPath)
        if db.open() {
            let sql = "insert into user (name, password) values(?, ?) "
            let name = NSString.init(format: "dhc%d", Holder.idx)
            Holder.idx += 1
            let res = db.executeUpdate(sql, withArgumentsIn: [name as String, "boy"])
            if !res {
                print("error to insert data")
            } else {
                print("succ to insert data")
            }
            db.close()
        }
    }
    
    @IBAction func queryTable(_ sender: Any) {
        print("queryTable")
        let db = FMDatabase.init(path: self.dbPath)
        if db.open() {
            let sql = "select * from user"
            let res = try! db.executeQuery(sql, values: nil)
            while res.next() {
                let userId = res.int(forColumn: "id");
                let name = res.string(forColumn: "name");
                let pwd = res.string(forColumn: "password");
                
                print(userId, name ?? "", pwd ?? "");
            }
            db.close()
        }
    }
    
    @IBAction func clearAll(_ sender: Any) {
        print("clearAll Table")
        let db = FMDatabase.init(path: self.dbPath)
        if db.open() {
            let sql = "delete from user"
            let res = db.executeStatements(sql)
            if !res {
                print("error to delete db data")
            } else {
                print("succ to deleta db data")
            }
            db.close()
        }
    }
    
    @IBAction func multiThreads(_ sender: Any) {
        print("multiThreads Table")
        let dbq = FMDatabaseQueue.init(path: self.dbPath)
        DispatchQueue.init(label: "queue1")
        let queue1 = DispatchQueue.init(label: "queue1")
        let queue2 = DispatchQueue.init(label: "queue2")
        
        queue1.async {
            for idx in 1...100 {
                dbq.inDatabase({ (db) in
                    let sql = "insert into user (name, password) values(?, ?) "
                    let name = String.init(format: "queue111 %d", idx)
                    let res = db.executeUpdate(sql, withArgumentsIn: [name, "boy"])
                    if !res {
                        print("error to add db data: ", idx)
                    } else {
                        print("error to add db data: ", idx)
                    }
                })
            }
        }
        
        queue2.async {
            for idx in 1...100 {
                dbq.inDatabase({ (db) in
                    let sql = "insert into user (name, password) values(?, ?) "
                    let name = String.init(format: "queue222 %d", idx)
                    let res = db.executeUpdate(sql, withArgumentsIn: [name, "boy"])
                    if !res {
                        print("error to add db data: ", idx)
                    } else {
                        print("error to add db data: ", idx)
                    }
                })
            }
        }
    }
}

