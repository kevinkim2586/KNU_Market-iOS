import UIKit

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "PostCell")
        cell.selectionStyle = .none
        
        let postDetail = viewModel.model?.postDetail ?? "로딩 중.."
    
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : labelStyle]
        
        cell.textLabel?.numberOfLines = 0
        
        if let postDetailWithUrl = viewModel.postDetailWithUrl {
            cell.textLabel?.attributedText = postDetailWithUrl
        } else {
            cell.textLabel?.attributedText = NSAttributedString(
                string: postDetail,
                attributes: attributes
            )
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let url = viewModel.userIncludedURL else { return }
        presentSafariView(with: url)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderViewStyle()
    }
}
