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
    
    var model = [InquiryListModel]()
    
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
        model.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryTableViewCell") as! InquiryTableViewCell
        
        cell.dateLabel.text = model[indexPath.row].date
        cell.inquieryTitleLabel.text = model[indexPath.row].title
        
        if model[indexPath.row].isArchived == true {
            cell.prograssImageView.image = UIImage(named: "doneImg")
        } else {
            cell.prograssImageView.image = UIImage(named: "inPrograssImg")
        }
        
        return cell
    }
    
    private func getList() {
        
    }
}
