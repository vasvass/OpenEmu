/*
 Copyright (c) 2015, OpenEmu Team
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import Foundation

extension NSURL {
    
    var hasImageSuffix: Bool {
        
        guard let urlSuffix = pathExtension?.lowercased() else {
            return false
        }
        
        return NSImage.imageTypes().contains(urlSuffix)
    }
    
    @objc(isSubpathOfURL:)
    func isSubpath(of url: NSURL) -> Bool {
        
        guard let parentPathComponents = url.standardized?.pathComponents,
            ownPathComponents = standardized?.pathComponents else {
                return false
        }
        
        let ownPathCount = ownPathComponents.count
        
        for i in 0..<parentPathComponents.count {
            if i >= ownPathCount || parentPathComponents[i] != ownPathComponents[i] {
                return false
            }
        }
        
        return true
    }
    
    var isDirectory: Bool {
        
        guard let resourceValues = try? resourceValues(forKeys: [URLResourceKey.isDirectoryKey, URLResourceKey.isPackageKey]) else {
            return false
        }
        
        return (resourceValues[URLResourceKey.isDirectoryKey]! as! NSNumber).boolValue &&
               !(resourceValues[URLResourceKey.isPackageKey]! as! NSNumber).boolValue
    }
    
    var fileSize: NSNumber {
        
        guard let resourceValues = try? resourceValues(forKeys: [URLResourceKey.fileSizeKey]) else {
            return 0
        }
        
        return resourceValues[URLResourceKey.fileSizeKey]! as! NSNumber
    }
    
    @objc(uniqueURLUsingBlock:)
    func uniqueURL(using block: (Int) -> NSURL) -> NSURL {
        
        var result = self
        var triesCount = 1
        
        while result.checkResourceIsReachableAndReturnError(nil) {
            triesCount += 1
            result = block(triesCount)
        }
        
        return result
    }
    
    @objc(validFilenameFromString:)
    class func validFilename(from fileName: String) -> String {
        let illegalFileNameCharacters = CharacterSet(charactersIn: "/\\?%*|\":<>")
        return fileName.components(separatedBy: illegalFileNameCharacters).joined(separator: "")
    }
    
    @objc(urlRelativeToURL:)
    func url(relativeTo url: NSURL) -> NSURL? {
        
        guard let selfAbsoluteString = standardized?.absoluteString,
                  urlAbsoluteString = url.standardized?.absoluteString else {
            return nil
        }
        
        let range = (selfAbsoluteString as NSString).range(of: urlAbsoluteString)
        
        if range.location != NSNotFound && range.location == 0 {
            return NSURL(string: (selfAbsoluteString as NSString).substring(from: range.length))
        } else {
            return standardized
        }
    }
}
