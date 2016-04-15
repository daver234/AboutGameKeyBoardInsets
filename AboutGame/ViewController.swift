/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var bgScrollView: UIScrollView!
  @IBOutlet weak var fgScrollView: UIScrollView!
  @IBOutlet weak var felipeImageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    // animate the wings
    var animationFrames = [UIImage]()
    for i in 0...3 {
      if let image = UIImage(named: "Bird\(i)") {
        animationFrames.append(image)
      }
    }

    felipeImageView.animationImages = animationFrames
    felipeImageView.animationDuration = 0.4
    felipeImageView.startAnimating()

    let topInset = CGRectGetHeight(navigationController!.navigationBar.frame) +
      CGRectGetHeight(UIApplication.sharedApplication().statusBarFrame)
    let bottomInset = CGRectGetHeight(navigationController!.toolbar.frame)
    fgScrollView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    fgScrollView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
  }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        let userInfo = notification.userInfo ?? [:]
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) - CGRectGetHeight(navigationController!.toolbar.frame) + 20) * (show ? 1 : -1)
        
        fgScrollView.contentInset.bottom += adjustmentHeight
        fgScrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
}

extension ViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(scrollView: UIScrollView) {
    // we're only interested in the foreground
    if scrollView != fgScrollView {
      return
    }

    // calculate how much of the foreground has scrolled
    let foregroundHeight = fgScrollView.contentSize.height - CGRectGetHeight(fgScrollView.bounds)
    let scrollPct = fgScrollView.contentOffset.y / foregroundHeight

    // leave a little padding to account for the bounce
    let scrollPadding: CGFloat = 20
    let backgroundHeight = bgScrollView.contentSize.height - CGRectGetHeight(bgScrollView.bounds)
    let paddedHeight = backgroundHeight - scrollPadding * 2

    // scroll the background relative to the foreground amount
    bgScrollView.contentOffset = CGPoint(x: 0, y: scrollPadding + (paddedHeight * scrollPct))
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
