//  ViewController.swift
//  okashiNoToriko//  Created by jobs steve on 2022/03/11.

import UIKit
import SafariServices
import Alamofire
import Foundation
class ViewController: UIViewController ,UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,SFSafariViewControllerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        searchText.delegate = self
        searchText.placeholder = "お菓子名"
        tableView.dataSource = self
        tableView.delegate = self
    }
    @IBOutlet weak var searchText: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var okashiArray : [Okashi] = []//Okashi構造体の配列
    ////////////////////////
    struct ItemJson: Codable {
        let name: String
        let maker: String
        let url: URL
        let image: URL
    }
    struct ResultJson: Codable {
        let item:[ItemJson]
    }
    struct Okashi {
        let name: String
        let maker: String
        let link: URL
        let image: URL
    }
    ///////////////////////////
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        if let searchWord = searchBar.text {
            print("\(searchWord):searchWord")
            request(keyword: searchWord)
        }
    }
    func request(keyword : String) {
        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return
        }
        AF.request("https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r")
            .responseDecodable(of:ItemJson.self) { response in
                guard let data = response.data else { return }
                do {//エラー処理
                    let decoder = JSONDecoder()//インスタンスの取得(オブジェクトの作成)
                    let json = try decoder.decode(ResultJson.self, from: data)
                    let items = json.item
                    self.okashiArray.removeAll()//配列の中身の削除（初期化）
                    for item in items {//itemsを配列へ追加
                        self.okashiArray.append(Okashi(name: item.name, maker: item.maker, link: item.url, image: item.image))
                    }
                    self.tableView.reloadData()//配列の再読み込み
                    print("-----------------")
                    print("okashiArray[0] = \(self.okashiArray.first!)")
                } catch {
                    print("エラーが出ました")//デバッグエリアへ出力
                }
                print(data)
            }
    }
    //////////////////////////////
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {//cellの総数
        return okashiArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//cellの値設定
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
        cell.textLabel?.text = okashiArray[indexPath.row].name//行番号と名前の取得
        if let imageData = try? Data(contentsOf: okashiArray[indexPath.row].image ) {//簡易エラーハンドリング
            cell.imageView?.image = UIImage(data: imageData)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)//セルの選択状態を解除する
        let safariViewController = SFSafariViewController(url: okashiArray[indexPath.row].link)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)//safariViewを閉じる
    }
}

//該当する商品が見つかりません。　は出せるの？？

//                    if let items = json.item{
//                        self.okashiArray.removeAll()//配列の中身の削除（初期化）
//                        for item in items {//itemsをUnwrap→タプルでまとめる→配列へ追加
//                            if let name = item.name , let maker = item.maker , let link = item.url , let image = item.image {
//                                //let okashi = (name,maker,link,image)//タプルでまとめる
//                                self.okashiArray.append(Okashi(name: item.name, maker: item.maker, link: item.url, image: item.image))
//                            }
//                        }

//↓URLSessionを利用した場合。(Alamofire利用に変更した為不要)
//    func searchOkashi(keyword : String) {
//        guard let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        else { return
//        }
//        guard let req_url = URL(string: "https://sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode)&max=10&order=r") else { return
//        }
//        print(req_url)//デバッグエリアへ出力
//        let req = URLRequest(url: req_url)
//        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
//        let task = session.dataTask(with: req, completionHandler: {
//            (data , response , error) in
//            session.finishTasksAndInvalidate()//タスク完了後セッション終了
//            do {//エラー処理
//                let decoder = JSONDecoder()//インスタンスの取得(オブジェクトの作成)
//                let json = try decoder.decode(ResultJson.self, from: data!)
//                if let items = json.item{
//                    self.okashiList.removeAll()//配列の中身の削除（初期化）
//                    for item in items {//itemsをUnwrap→タプルでまとめる→配列へ追加
//                        if let name = item.name , let maker = item.maker , let link = item.url , let image = item.image {
//                            let okashi = (name,maker,link,image)//タプルでまとめる
//                            self.okashiList.append(okashi)//配列に追加(タプルを)
//                        }
//                    }
//                    self.tableView.reloadData()//配列の再読み込み
//                    if let okashidbg = self.okashiList.first {//デバッグコード
//                        print("-----------------")
//                        print("okashiList[0] = \(okashidbg)")
//                    }
//                }
//            } catch {
//                print("エラーが出ました")//デバッグエリアへ出力
//            }
//        })
//        task.resume()//.dataTaskメソッドで登録された「リクエストタスク」の実行（JSONのダウンロード開始）
//    }
