//
//  AppServices.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation

struct AppServices {
    
    let sharingService: SharingServiceType
    let urlNavigator: URLNavigatorType
    
    let bannerService: BannerServiceType
    let chatListService: ChatListServiceType

    let myPageService: MyPageServiceType
    let popupService: PopupServiceType
    let mediaService: MediaServiceType
    let postService: PostServiceType
    let reportService: ReportServiceType
    let userService: UserServiceType
    
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    let userNotificationService: UserNotificationServiceType
    
    
    init() {
        
        self.sharingService = SharingService()
        self.urlNavigator = URLNavigator()
        
        self.bannerService = BannerService(network: Network<BannerAPI>())
        self.chatListService = ChatListService(
            network: Network<ChatAPI>(plugins: [
                AuthPlugin()
            ]),
            userDefaultsGenericService: UserDefaultsGenericService()
        )
        
        self.myPageService = MyPageService(network: Network<MyPageAPI>(plugins: [
            AuthPlugin()
        ]))
        
        self.popupService = PopupService(network: Network<PopupAPI>())
        
        self.mediaService = MediaService(network: Network<MediaAPI>(plugins: [
            AuthPlugin()
        ]))
        
        self.postService = PostService(network: Network<PostAPI>(plugins: [
            AuthPlugin()
        ]))
        
        self.reportService = ReportService(network: Network<ReportAPI>(plugins: [
            AuthPlugin()
        ]))
        
        self.userService = UserService(
            network: Network<UserAPI>(plugins: [
                AuthPlugin()
            ]), userDefaultsPersistenceService: UserDefaultsPersistenceService(
                userDefaultsGenericService: UserDefaultsGenericService()
            )
        )
        
        self.userDefaultsGenericService = UserDefaultsGenericService()
        self.userNotificationService = UserNotificationService(userDefaultsGenericService: UserDefaultsGenericService())
    }
}
