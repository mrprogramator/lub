//
//  BusquedaVC.swift
//  lub
//
//  Created by Luis Alberto Saucedo Quiroga on 4/5/20.
//  Copyright © 2020 Luis Alberto Saucedo Quiroga. All rights reserved.
//

import UIKit
import MobileCoreServices

class BusquedaVC: BasicVC {
    @IBOutlet weak var busquedaTextField: UITextField!
    @IBOutlet weak var loadingImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var results: [Result]!
    let RESULT_CELL_HEIGHT:CGFloat = 347
    let socketHandler = SocketHandler()
    var videoData: Data!
    var selectedResult: Result!
    var selectedCell: ResultCell!
    
    //Download vars
    var expectedContentLength = 0
    var buffer:NSMutableData = NSMutableData()
    var session:URLSession?
    var dataTask:URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField(self.busquedaTextField, " Buscar")
        self.loadingImg.loadGif(name: "loading")
        self.loadingImg.isHidden = true
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.estimatedRowHeight = RESULT_CELL_HEIGHT
        self.tableView?.register(ResultCell.nib, forCellReuseIdentifier: ResultCell.identifier)
        self.tableView?.separatorStyle = .singleLine;
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.buscar("")
        self.results = [Result]()
        
        //For Download
        let configuration = URLSessionConfiguration.default
        let manqueue = OperationQueue.main
        session = URLSession(configuration: configuration, delegate:self, delegateQueue: manqueue)
    }
    
    @IBAction func textFieldDidEndOnExit(textField: UITextField) {
        self.buscar(textField.text!, 50)
        textField.resignFirstResponder()
    }
    
    @IBOutlet weak var iconTextField: UITextField! {
        didSet {
            iconTextField.tintColor = UIColor.lightGray
            iconTextField.setIcon(UIImage(named: "search")!)
        }
    }
    
    func buscar(_ indicio: String, _ resultsCount: Int = 7) {
        let indicioQuery = indicio.replacingOccurrences(of: " ", with: "%20")
        let url = "search?indication=" + indicioQuery + "&resultsCount=" + String(resultsCount)
        self.results = [Result]()
        self.showLoading()
        
        HTTPRequester.request(url: url, method: "POST", body: nil, onSuccess: { stringResponse in
            if stringResponse != nil {
                let data = stringResponse!.data(using: String.Encoding.utf8)!
                let response = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                let obj = SearchResponse(dictionary: response)
                
                DispatchQueue.main.async {
                    self.results = obj.items
                    let scrollHeight = self.results.count * Int(self.RESULT_CELL_HEIGHT)
                    let screenSize = UIScreen.main.bounds
                    let screenWidth: Int = Int(roundf(Float(screenSize.width)))
                    self.scrollView.contentSize = CGSize(width: screenWidth, height: scrollHeight)
                    self.scrollView.scrollToTop()
                    self.tableView.reloadData()
                    self.hideLoading()
                }
            }
         }, onError: { httpError in
            print("Error :(")
        })
    }
    
    func showLoading() {
        self.loadingImg.isHidden = false
        self.scrollView.isHidden = true
    }
    
    func hideLoading() {
        self.loadingImg.isHidden = true
        self.scrollView.isHidden = false
    }
}

extension BusquedaVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        height = RESULT_CELL_HEIGHT
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let item = self.results[row]
        var frame = self.tableView.frame
        frame.size.height = self.tableView.contentSize.height
        tableView.frame = frame
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as? ResultCell {
            cell.item = item
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = results[indexPath.row]
        self.selectedResult = item
        
        let cell = tableView.cellForRow(at: indexPath) as? ResultCell
        cell?.percentLabel.isHidden = false
        cell?.percentLabel.text = "Descargando..."
        self.selectedCell = cell
        
        socketHandler.getMedia(videoId: (item.id.videoId)!, onData: { stringMsg in
            DispatchQueue.main.async {
                cell?.percentLabel.isHidden = false
                cell?.percentLabel.text = stringMsg
            }
        }, onFinish: { downloadURL in
            DispatchQueue.main.async {
                let fileURL = URL(string: HTTPRequester.baseURL + downloadURL)
                let request = URLRequest(url:fileURL!)

                let task = self.session?.dataTask(with: request)
                task?.resume()
            }
        })
    }
}

extension BusquedaVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let urlSelected = urls.first!
        
        guard urlSelected.startAccessingSecurityScopedResource() else {
            return
        }
        
        let localUrl = urlSelected.appendingPathComponent(selectedResult.snippet.title + ".mp4")
        
        do {
            try buffer.write(to: localUrl)
        }
        catch {
            print("Could not save file")
        }
        
        do { urlSelected.stopAccessingSecurityScopedResource() }
    }
}

extension BusquedaVC: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {

        //here you can get full lenth of your content
        expectedContentLength = Int(response.expectedContentLength)
        print(expectedContentLength)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)

        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        self.selectedCell.percentLabel.isHidden = false
        self.selectedCell.percentLabel.text = String(Int(percentageDownloaded * 100)) + "%"
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.selectedCell.percentLabel.isHidden = true
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
    
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                      CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                      CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
