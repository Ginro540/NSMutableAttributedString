//
//  ViewController.swift
//  testLabelString
//
//  Created by 古賀貴伍 on 2021/04/22.
//

import UIKit

class ViewController: UIViewController {

    enum TextPatternList: String ,CaseIterable{
        case Gray   = "<color:gray>"
        case Red   = "<color:red>"
        case DeepPink  = "<color:deeppink>"
        case Green = "<color:green>"
        case Blue  = "<color:blue>"
        case Purple = "<color:purple>"
        case Brown = "<color:brown>"
        case Bold  = "<b>"
        case Link = "<link>"
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textview2: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        var contents = " <color:gray>(#808080)の色文字</color>になっているか確認\n<color:red>red(#ff0000)の色文字</color>になっているか確認\n<color:deeppink>deeppink(#ff1493)の色文字</color>になっているか確認\n<color:green>green(#008000)の色文字</color>になっているか確認\n<color:blue>blue(#0000ff)の色文字</color>になっているか確認\n<color:purple>purple(#800080)の色文字</color>になっているか確認\n<color:brown>brown(#a52a2a7)の色文字</color>になっているか確認\n\n太文字が<b>ここに</b>なっているか確認\n<b>太文字</b>になっているか確認\n行が続くとどんな見栄えになるかを<b>確認</b>\n\n<link>https://ouchi-de-curves-ex.com/tel/</link>"
        
        
        self.customizeContentText(contents: contents)
    }
    
        private func customizeContentText(contents: String?){
            
            guard let content = contents else {
                self.textView.text = ""
                return
            }
            let tabItems = self.checkTab( content: content)
            guard !tabItems.isEmpty else {
                self.textView.text = content
                return
            }

            self.textView.text = content
            let attributeText = NSMutableAttributedString(string: textView.text!)
            for tabItem in tabItems {
                
                switch tabItem.1 {
                case .Bold:
                    attributeText.addAttribute(.font,
                                         value: UIFont.boldSystemFont(ofSize: getUIFont()),
                                         range: NSString(string: content).range(of: tabItem.0))
                case .Link:
                    attributeText.addAttribute(.link,
                                         value: tabItem.0,
                                         range: NSString(string: content).range(of: tabItem.0))
                default:
                    attributeText.addAttribute(.foregroundColor,
                                               value: getTextColor(pattern: tabItem.1),
                                               range: NSString(string: content).range(of: tabItem.0))
                }
            }
            self.textView.attributedText = attributeText
            for pattern in TextPatternList.allCases {
                
                self.textView?.attributedText = self.textView.attributedText!.replace(pattern: pattern.rawValue, replacement: "")
                self.textView?.attributedText = self.textView.attributedText!.replace(pattern: endPattern(pattern: pattern.rawValue), replacement: "")
            }
            return
        }
        private func getUIFont() -> CGFloat {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return 14.0
            } else {
                return 20.0
            }
        }
        
        private func getTextColor(pattern:TextPatternList) -> UIColor {
            
            switch pattern {
            case TextPatternList.Gray:
                return UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
            case TextPatternList.Red:
                return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            case TextPatternList.DeepPink:
                return UIColor(red: 255/255, green: 20/255, blue: 147/255, alpha: 1)
            case TextPatternList.Green:
                return UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
            case TextPatternList.Purple:
                return UIColor(red: 128/255, green: 0/255, blue: 128/255, alpha: 1)
            case TextPatternList.Brown:
                return UIColor(red: 165/255, green: 42/255, blue: 42/255, alpha: 1)
            case TextPatternList.Blue:
                return UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
            default:
                return UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            }
        }
        
        private func checkTab(content:String) -> [(String,TextPatternList)]{
            var stringList: [(String,TextPatternList)] = []
            for pattern in TextPatternList.allCases {
                var nextRange = content.startIndex..<content.endIndex
                while let range = content.range(of: pattern.rawValue, options: .caseInsensitive, range: nextRange) {
                    guard let endRes = content[range.upperBound...].range(of: self.endPattern(pattern: pattern.rawValue))  else {
                        /// 文字列不正
                        return []
                    }
                    let items = checkTab(content: String(content[range.upperBound..<endRes.lowerBound]))
                    if !items.isEmpty {
                        for item in items{
                            stringList.append((item.0,item.1))
                        }
                    }
                    stringList.append((String(content[range.lowerBound..<endRes.upperBound]),pattern))
                    nextRange = range.upperBound..<content.endIndex
                }
            }
            return stringList
        }
        
        private func endPattern(pattern:String) -> String {
            switch pattern {
            case "<b>":
                return "</b>"
            case "<link>":
                return "</link>"
            default:
                return "</color>"
            }
        }
}

extension String {
    func replace(_ from: String) -> String {
        var replacedString = self
        while((replacedString.range(of: from)) != nil){
            if let range = replacedString.range(of: from) {
                replacedString.replaceSubrange(range, with: "")
            }
        }
        return replacedString
    }
}




extension UIFont {
    
    enum FontType: String {
        case genJyuuGothic = "GenJyuuGothic-Monospace-Bold"
        case hiraginoUDSansRStdW6 = "HiraginoUDSansRStd-W6"
    }
    
    convenience init(font: FontType, size: CGFloat = 10.0) {
        self.init(name: font.rawValue, size: size)!
    }
    
}
extension NSAttributedString {

    func replace(pattern: String, replacement: String) -> NSMutableAttributedString {
        let mutableAttributedString = self.mutableCopy() as! NSMutableAttributedString
        let mutableString = mutableAttributedString.mutableString
        while mutableString.contains(pattern) {
            let range = mutableString.range(of: pattern)
            mutableAttributedString.replaceCharacters(in: range, with: replacement)
        }
        return mutableAttributedString
    }
}
