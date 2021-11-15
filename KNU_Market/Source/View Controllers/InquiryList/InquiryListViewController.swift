//
//  InquiryListViewController.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/11.
//

import UIKit
import SnapKit
import Alamofire

class InquiryListViewController: UIViewController {
    
    var inquiryModel = [InquiryListModel]()
    
    private let profileImageView: UIImageView = {
        let profileImg = UIImageView()
        profileImg.layer.cornerRadius = profileImg.bounds.height * 0.5
        profileImg.contentMode = .scaleAspectFit
        return profileImg
    }()
    
    private let profileNameLabel: UILabel = {
        let profileName = UILabel()
        profileName.font = .systemFont(ofSize: 12)
        profileName.adjustsFontSizeToFitWidth = true
        return profileName
    }()
    
    private let isDoneImageView: UIImageView = {
        let isDoneImg = UIImageView()
        isDoneImg.image = UIImage(named: "doneIcon")
        isDoneImg.contentMode = .scaleAspectFit
        return isDoneImg
    }()
    
    private let isDoneLabel: UILabel = {
        let isDoneLabel = UILabel()
        isDoneLabel.text = "완료"
        isDoneLabel.font = .boldSystemFont(ofSize: 10)
        isDoneLabel.adjustsFontSizeToFitWidth = true
        return isDoneLabel
    }()
    
    private let isInPrograssImageView: UIImageView = {
        let isInPrograssImg = UIImageView()
        isInPrograssImg.image = UIImage(named: "InprograssIcon")
        isInPrograssImg.contentMode = .scaleAspectFit
        return isInPrograssImg
    }()
    
    private let isInPrograssLabel: UILabel = {
        let isInPrograssLabel = UILabel()
        isInPrograssLabel.text = "대기중"
        isInPrograssLabel.font = .boldSystemFont(ofSize: 10)
        isInPrograssLabel.adjustsFontSizeToFitWidth = true
        return isInPrograssLabel
    }()
    
    private let inquiryList: UITableView = {
        let tableView = UITableView()
        tableView.register(InquiryTableViewCell.self, forCellReuseIdentifier: "InquiryTableViewCell")
        return tableView
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
        inquiryList.delegate = self
        inquiryList.dataSource = self
        getList()
    }
    
    private func setUpSubViews() {
        [profileImageView, profileNameLabel, isDoneImageView, isDoneLabel, isInPrograssImageView, isInPrograssLabel, inquiryList].forEach({ self.view.addSubview($0) })
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.top.equalToSuperview().offset(30)
            $0.centerX.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        isDoneImageView.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom).offset(40)
            $0.leading.equalTo(200)
            $0.width.equalTo(11)
            $0.height.equalTo(7)
        }
        
        isDoneLabel.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom).offset(40)
            $0.leading.equalTo(isDoneImageView.snp.trailing).offset(5)
        }
    }
}

extension InquiryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        inquiryModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryTableViewCell") as! InquiryTableViewCell
        
        cell.dateLabel.text = inquiryModel[indexPath.row].date
        cell.inquieryTitleLabel.text = inquiryModel[indexPath.row].title
        
        if inquiryModel[indexPath.row].isArchived == true {
            cell.prograssImageView.image = UIImage(named: "doneImg")
        } else {
            cell.prograssImageView.image = UIImage(named: "inPrograssImg")
        }
        
        return cell
    }
    
    private func getList() {
        let url = "https://knumarket.kro.kr:5051/api/v1/reports?page=1"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["authentication": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImFoclJodUJTSnRuZ2NKWEhxRDU3QUQiLCJpYXQiOjE2MzYxOTIyNTEsImV4cCI6MTYzNjE5OTQ1MX0.9kY1PPmEEFstaYKQgDB7tG-lCkIgAh5b6-wqHNtafrc"])
            .validate(statusCode: 200..<300)
            .responseJSON{res in
                do {
                    let model = try JSONDecoder().decode([InquiryModel].self, from: res.data!)
                    self.inquiryModel.removeAll()
                    self.inquiryModel.append(model)
                    self.inquiryList.reloadData()
                } catch {
                    print(error)
                }
            }
    }
}
