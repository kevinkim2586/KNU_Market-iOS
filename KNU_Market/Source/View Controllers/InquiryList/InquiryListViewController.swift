//
//  InquiryListViewController.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/11.
//

import UIKit
import SnapKit
import Alamofire
import SDWebImage

class InquiryListViewController: UIViewController {
    
    var inquiryModel = [InquiryListModel]()
    
    private let profileImageView: UIImageView = {
        let profileImg = UIImageView()
        profileImg.contentMode = .scaleAspectFit
        
        let url = URL(string: K.MEDIA_REQUEST_URL + User.shared.profileImageUID)
        profileImg.sd_setImage(with: url, placeholderImage: UIImage(named: K.Images.chatBubbleIcon), options: .continueInBackground, context: .none)
        
        return profileImg
    }()
    
    private let profileNameLabel: UILabel = {
        let profileName = UILabel()
        profileName.font = .systemFont(ofSize: 15)
        profileName.adjustsFontSizeToFitWidth = true
        profileName.text = User.shared.nickname
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
        tableView.register(InquiryTableViewCell.self, forCellReuseIdentifier: "InquiryCell")
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
        setNavigationBar()
        inquiryList.delegate = self
        inquiryList.dataSource = self
        self.view.backgroundColor = .white
        print(User.shared.profileImageUID)
    }
    
    override func viewDidLayoutSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width * 0.5
        getList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getList()
    }
    
    private func setUpSubViews() {
        [profileImageView, profileNameLabel, isDoneImageView, isDoneLabel, isInPrograssImageView, isInPrograssLabel, inquiryList].forEach({ self.view.addSubview($0) })
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(52)
            $0.top.equalToSafeArea(view).offset(50)
            $0.centerX.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
            $0.centerX.equalToSafeArea(view)
        }
        
        isDoneImageView.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom).offset(40)
            $0.trailing.equalTo(isDoneLabel.snp.leading).offset(-3)
            $0.width.equalTo(20)
            $0.height.equalTo(10)
        }
        
        isDoneLabel.snp.makeConstraints {
            $0.centerY.equalTo(isDoneImageView)
            $0.trailing.equalTo(isInPrograssImageView.snp.leading).offset(-7)
        }
        
        isInPrograssImageView.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom).offset(40)
            $0.trailing.equalTo(isInPrograssLabel.snp.leading).offset(-3)
            $0.width.equalTo(20)
            $0.height.equalTo(10)
        }
        
        isInPrograssLabel.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom).offset(40)
            $0.trailing.equalToSafeArea(view).offset(-20)
        }
        
        inquiryList.snp.makeConstraints {
            $0.top.equalTo(isInPrograssLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSafeArea(view)
            $0.width.equalToSafeArea(view)
        }
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.backgroundColor = nil
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationItem.title = "문의내역"
    }
}

extension InquiryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inquiryModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryCell", for: indexPath)
                        as? InquiryTableViewCell else { return UITableViewCell() }
        
        cell.dateLabel.text = formatDate(inquiryModel[indexPath.row].date)
        cell.inquieryTitleLabel.text = ": " + inquiryModel[indexPath.row].title

        if inquiryModel[indexPath.row].isArchived == true {
            cell.prograssImageView.image = UIImage(named: "doneImg")
        } else {
            cell.prograssImageView.image = UIImage(named: "inPrograssImg")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        DetailMessageViewController(reactor: DetailMessageViewReactor(title: title, content: content, answer: nil))
    }
    
    private func getList() {
        let url = "https://knumarket.kro.kr:5051/api/v1/reports?page=1"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["authentication": User.shared.accessToken])
            .validate(statusCode: 200..<300)
            .responseJSON{res in
                do {
                    let model = try JSONDecoder().decode(InquiryListModel.self, from: res.data!)
                    self.inquiryModel.removeAll()
                    self.inquiryModel.append(model)
                    self.inquiryList.reloadData()
                    print(model)
                } catch {
                    print(error)
                }
            }
    }
    
    private func formatDate(_ startDate: String)-> String {
        let finalDate = startDate.components(separatedBy: ["-", ":"," "])
        let formattedDate = finalDate[1] + "월 " + finalDate[2] + "일 " + finalDate[3] + ":" + finalDate[4]
        
        return formattedDate
    }
}
