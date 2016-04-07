//
//  FontTableViewController.swift
//  MemeMe
//
//  Created by david lobo on 07/04/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//

import UIKit

protocol FontTableViewControllerDelegate: class {
    func didFinishTask(sender: FontTableViewController)
}

class FontTableViewController: UITableViewController {
    
    // Properties
    
    var availableFonts: [String]?
    var currentFontname: String?
    var fontSelected: ((result: String) -> Void)?
    var isLoaded: String?
    weak var delegate: FontTableViewControllerDelegate?
    
    // Allowed fonts to choose
    let fontWhitelist = [
        "AcademyEngravedLetPlain",
        "Baskerville-Bold",
        "BradleyHandITCTT-Bold",
        "ChalkboardSE-Bold",
        "Chalkduster",
        "Copperplate-Bold",
        "Futura-CondensedExtraBold",
        "Georgia-Bold",
        "GillSans-UltraBold",
        "Impact",
        "IowanOldStyle-Bold",
        "Noteworthy-Bold"
    ]
    
    // MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 40
        availableFonts = availableFontnames()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let availableFonts = availableFonts {
            return availableFonts.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FontCell", forIndexPath: indexPath)
        
        if let availableFonts = availableFonts {
            let fontName = availableFonts[indexPath.row]
            
            let memeTextAttributes = [
                NSStrokeColorAttributeName : UIColor.lightTextColor(),
                NSForegroundColorAttributeName : UIColor.darkTextColor(),
                NSFontAttributeName : UIFont(name: fontName, size: 20)!,
                NSStrokeWidthAttributeName : -1.0
            ]
            
            let text = NSAttributedString(string: fontName, attributes: memeTextAttributes)
            cell.textLabel?.attributedText = text
            
            if let currentFontname = currentFontname where currentFontname == fontName {
                cell.accessoryType = .Checkmark
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let fontName = availableFonts![indexPath.row]
        self.currentFontname = fontName
        self.delegate?.didFinishTask(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Helper functions
    
    func availableFontnames() -> [String] {
        
        var fonts = [String]()
        
        for familyName in UIFont.familyNames() {
            for fontName in UIFont.fontNamesForFamilyName(familyName) {
                if fontWhitelist.contains(fontName) {
                    fonts.append(fontName)
                }
            }
        }
        
        fonts.sortInPlace()
        
        return fonts
    }
    
    // MARK: - IB actions
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
