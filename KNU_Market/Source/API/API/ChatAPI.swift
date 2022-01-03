//
//  ChatAPI.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/03.
//

import Foundation
import Moya

enum ChatFunction {
    case join
    case exit
    case getRoom
    case getRoomInfo
    case getChat
}

enum ChatAPI {
    case changeJoinStatus(chatFunction: ChatFunction, pid: String)              // 채팅방 참여 or 나가기
    case getRoom                                                                // 참여한 공구 채팅방 리스트 불러오기
    case getRoomInfo(pid: String)                                               // 참여한 공구 채팅방 자세한 정보 불러오기 (참여 인원 등..)
    case getPreviousChats(pid: String, index: Int)                              // 이전 채팅 기록 불러오기
    case getNewlyReceivedChats(pid: String, index: Int, lastChatDate: String)   // 특정 시점부터 도착한 채팅 불러오기 (헤더에 날짜 포함)
    case banUser(userUid: String, room: String)                                 // 방장인 경우 특정 사용자 채팅방에서 추방
}

extension ChatAPI: BaseAPI {
    
    var path: String {
        switch self {
        case let .changeJoinStatus(_, pid), let .getRoomInfo(pid):
            return "room/\(pid)"

        case .getRoom:
            return "room/"
            
        case let .getPreviousChats(pid, index), let .getNewlyReceivedChats(pid, index, _):
            return "room/\(pid)/\(index)"

        case let .banUser(userUid, room):
            return "room/\(room)/\(userUid)"
        }
    }
    
    var headers: [String : String]? {
        
        switch self {
            
        case let .getNewlyReceivedChats(_, _, lastChatDate):
            return [
                "isover": "1",
                "date":  lastChatDate
            ]
            
        default: return nil
        }
    }
    
    var method: Moya.Method {
        switch self {
        case let .changeJoinStatus(chatFunction, _):
            switch chatFunction {
            case .join: return .post
            case .exit: return .delete
            default:
                return .get
            }
        case .getRoom, .getRoomInfo, .getNewlyReceivedChats, .getPreviousChats:
                return .get
        case .banUser:
            return .delete
        }
    }
    
    var parameters: [String : Any]? {
        switch self {
            
        default: return nil
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
            
        default: return JSONEncoding.default
            
        }
    }
    
    var task: Task {
        
        switch self {
            
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
}
