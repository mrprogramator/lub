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
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var descargasTableView: UITableView!
    @IBOutlet weak var menuScrollView: UIScrollView!
    
    var results: [Result]!
    var downloads: [DescargaLub]!
    let RESULT_CELL_HEIGHT:CGFloat = 260
    let DOWNLOAD_CELL_HEIGHT: CGFloat = 53
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextField(self.busquedaTextField, " Buscar")
        self.loadingImg.loadGif(name: "loading")
        self.loadingImg.isHidden = true
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        self.tableView?.estimatedRowHeight = RESULT_CELL_HEIGHT
        self.tableView?.register(ResultCell.nib, forCellReuseIdentifier: ResultCell.identifier)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.rowHeight = UITableView.automaticDimension
        self.menuScrollView.isHidden = true
        
        self.descargasTableView.isHidden = true
        self.descargasTableView?.dataSource = self
        self.descargasTableView?.delegate = self
        self.descargasTableView?.estimatedRowHeight = DOWNLOAD_CELL_HEIGHT
        self.descargasTableView?.register(DescargaCell.nib, forCellReuseIdentifier: DescargaCell.identifier)
        self.descargasTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.descargasTableView.rowHeight = UITableView.automaticDimension
        self.downloads = [DescargaLub]()
        self.buscar("")
        self.results = [Result]()
    }
    
    @IBAction func textFieldDidEndOnExit(textField: UITextField) {
        self.buscar(textField.text!, 50)
        textField.resignFirstResponder()
    }
    
    @IBAction func onMenuBtnTap(_ sender: Any) {
        self.menuScrollView.isHidden = !self.menuScrollView.isHidden
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
        var rowCount = 0
        
        if tableView == self.tableView {
            rowCount = self.results.count
        }
        else if tableView == self.descargasTableView {
            rowCount = self.downloads.count
        }
        
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        
        if tableView == self.tableView {
            height = RESULT_CELL_HEIGHT
        }
        else if tableView == self.descargasTableView {
            height = DOWNLOAD_CELL_HEIGHT
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            let row = indexPath.row
            let item = self.results[row]
            var frame = self.tableView.frame
            frame.size.height = self.tableView.contentSize.height
            tableView.frame = frame
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.identifier, for: indexPath) as? ResultCell {
                cell.item = item
                return cell
            }
        }
        else if tableView == self.descargasTableView {
            let row = indexPath.row
            let item = self.downloads[row]
            var frame = self.descargasTableView.frame
            frame.size.height = self.descargasTableView.contentSize.height
            tableView.frame = frame
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: DescargaCell.identifier, for: indexPath) as? DescargaCell {
                cell.item = item
                
                item.selectedCell = cell
                if item.pendienteDescarga {
                    item.getMedia(onData: { stringMsg in
                        DispatchQueue.main.async {
                            item.selectedCell.lbProgreso.text = stringMsg
                        }
                    }, onFinish: { downloadURL in
                        let fileURL = URL(string: HTTPRequester.baseURL + downloadURL)
                        let request = URLRequest(url:fileURL!)
                        let session = URLSession(configuration: URLSessionConfiguration.default, delegate:item, delegateQueue: OperationQueue.main)
                        let task = session.dataTask(with: request)
                        task.resume()
                    })
                }
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableView {
            let selectedResult = results[indexPath.row]
            let cell = self.tableView.cellForRow(at: indexPath) as! ResultCell
            var descargaLub = downloads.filter({
                $0.selectedResult.id.videoId == selectedResult.id.videoId
            }).first
            
            if descargaLub == nil {
                cell.percentLabel.isHidden = false
                cell.percentLabel.text = "Descargando";
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    cell.percentLabel.isHidden = true
                    self.menuScrollView.isHidden = false
                    self.menuScrollView.scrollToBottom()
                })
                
                descargaLub = DescargaLub()
                descargaLub!.selectedResult = results[indexPath.row]
                descargaLub!.vcInvoker = self
                downloads.append(descargaLub!)
                
                let menuHeight = self.downloads.count * Int(self.DOWNLOAD_CELL_HEIGHT)
                var menuMaxHeight = CGFloat(menuHeight)
                
                if self.downloads.count > 3 {
                    menuMaxHeight = CGFloat(self.DOWNLOAD_CELL_HEIGHT) * 3
                }
                
                self.menuScrollView.frame = CGRect(x: self.menuScrollView.frame.origin.x,
                                                   y: self.menuScrollView.frame.origin.y,
                                                   width: self.menuScrollView.frame.width,
                                                   height: menuMaxHeight)
                self.menuScrollView.contentSize = CGSize(width: Int(self.menuScrollView.contentSize.width), height: menuHeight)
                self.descargasTableView.isHidden = false
                self.descargasTableView.reloadData()
            }
        }
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
    
    func scrollToBottom() {
        let desiredOffset = CGPoint(x: 0, y: contentInset.bottom)
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
