# 크누마켓 (경북대학교 공동구매 플랫폼)

![mockup-of-four-floating-iphone-screens-against-a-customizable-background-2904](https://user-images.githubusercontent.com/44637101/155120247-34f82a67-b8ff-4872-b574-f8f7681bee43.png)

## 💡 무슨 앱이야?

- **경북대학교 공동구매 커뮤니티**
- **대량으로 사면 저렴한** 생활용품 살 때, 학교 기숙사에서 배달 음식이 먹고 싶은데 배달팁 때문에 너무 비싸 **비용을** **나누고 싶을 때**, **1+1 행사하는 쇼핑몰 옷을 하나만 사고 싶을 때** 같이 살 학생을 편리하게 찾을 수 있도록 도와주는 서비스

🎉   **총 다운로드 수 694**  (2022.02.22일 기준) 달성!

- 안드로이드 전용 앱과 합하면 총 **다운로드 수 1200 이상**!
- 총 회원가입자 수 1000 이상 달성!
- 앱스토어 소셜 네트워킹 카테고리 **110위 달성**! (2021.09.15일 기준)
- iOS, Android, 백엔드, 기획자, 마케터로 진로를 희망하는 경북대 학생들이 모여 애매한 강의 프로젝트말고 **제대로된 프로젝트**를 하나 해보자 하고 탄생한 앱![appstore](https://user-images.githubusercontent.com/44637101/155120461-d9e9767c-1c32-4581-95b1-db30eb58a088.jpg)


## ❓ 왜 만들었어?

- 대학생들의 지갑은 가볍습니다. 옷, 생활용품, 배달음식,
    
    어떤걸 사더라도 **최대한 싸고 가성비 좋게** 구매하고 싶어합니다. 
    

- 그런데 저렴하게 구매하고 싶으면 대량으로 또는 1+1으로 구매해야 할 때가 많습니다.
    
    그래서 **공동구매**라는게 존재합니다.
    

- 경북대학교에는 **공구에 대한 수요가 많아** 아래 사진과 같이 카카오톡 오픈채팅방 형태로 공구 모집이 많이 이루어져 왔습니다.

- 하지만 오픈채팅방은 게시글 형태로 구분되지 않아 **UI/UX적으로 많은 불편함을 느꼈습니다.**
    - 한 번에 많은 글이 올라오면 글이 묻히기 일쑤
    - 잡담과 섞여 공구 모집 글 구분이 어려움
    - 공구 참여자와 별도 채팅방을 다시 한 번 더 개설해야하는 불편함
    - 사기 또는 잠수에 대한 위험성 多

<img width="424" alt="Screen Shot 2021-12-28 at 4 55 25 PM" src="https://user-images.githubusercontent.com/44637101/155120616-b78191d9-b72e-4e69-8737-f323e5b44f44.png">


### ✻ 이러한 불편함과 수요를 파악하여 만든 앱이 바로 크누마켓입니다.

## ⭐️ 주요 기능

- **공구 모집 글 확인 및 신규 모집 글 개설 기능**
    - 모집 중인 공구와 모집 완료된 공구 구별 가능
    - 마감된 공구는 별도 마감처리하여 더 이상 채팅방 입장이 되지 않게 구현
    - 공구 글 수정 기능
    - 공구 글 검색 기능
- **채팅 기능**
    - 공구하고 싶은 품목을 올리면 자동으로 채팅방 개설 → 희망자가 채팅방에 참여하는 방식
    - WebSocket과 StarScream 라이브러리를 이용한 실시간 채팅 기능
    - Socket에 연결되어 있지 않으면 FCM을 통해 개인 알림 발송 가능
    - 채팅 참여, 나가기, 실시간  사용자 Ban 기능
    - 사진 보내기 기능
    

## 🌄 스크린샷 및 데모 영상
![IMG_3333](https://user-images.githubusercontent.com/44637101/155120778-a61213d6-17aa-4671-ae04-c05bc6881d18.PNG)
![IMG_3337](https://user-images.githubusercontent.com/44637101/155120807-40b1b7e1-419d-4f20-87b5-102ce14f1d17.PNG)
![IMG_3338](https://user-images.githubusercontent.com/44637101/155120837-f5e19f9e-9186-457d-942c-e490c01e0abd.PNG)
![IMG_3334](https://user-images.githubusercontent.com/44637101/155120882-107d0cad-b908-4d50-8f53-40acf7e9710d.PNG)
![IMG_3335](https://user-images.githubusercontent.com/44637101/155120903-da1dc0b2-79f2-4d35-aef3-f8e9211d5a66.PNG)
![IMG_3336](https://user-images.githubusercontent.com/44637101/155120922-04a21b2c-42df-41c4-beb0-df602f18c6ec.PNG)


데모 영상 링크 :
https://drive.google.com/file/d/1AWt3Opp9z7dmQ26cTil_KCyJ1GYzKdyv/view?usp=sharing

## ⚙️ Architecture

- **MVVM (ReactorKit)**

## 👨🏻‍💻 Team

- iOS 개발자 1명
- Android 개발자 2명
- 백엔드 개발자 1명
- 기획자 2명

## ✋🏻 맡은 부분

- **iOS 앱 전체 개발**
    - v 1.1 출시 이후 iOS 개발자 1명이 더 투입되어 협업 중
- **개발팀장**
    - 전체 개발 일정 조율 및 팀 전체와 함께 기능 구현 방안 토론 주도
    - 모두가 초보였기 때문에 iOS, Android와 백엔드 담당 팀원들과 수많은 시행착오가 있었지만 원활한 중재자 역할을 수행하여 순조로운 개발이 가능하였습니다.
- **디자인**
    - 초기에 디자이너를 구하지 못해 제가 Figma로 프로토타이핑을 진행했었습니다.

## 🎙 유저 피드백 받고 개선한 점

- 실제 유저의 피드백을 지속적으로 받고 싶어 “***개발자에게 건의사항 보내기***”라는 기능을 추가했었습니다.
- 건의사항이 접수되면 팀이 쓰는 협업툴과 즉시 연동이 되어 아래와 같이 어떤 불편함을 느끼는지 확인할 수 있었습니다.


![Screen Shot 2022-01-10 at 11 52 06 AM](https://user-images.githubusercontent.com/44637101/155121410-b0915e6f-a2d7-4348-a7d9-ee632edaa556.png)



[  **피드백 받고 개선 및 추가한 주요 기능**  ]

- 채팅방에서 **사진 보내기 기능** 추가
- 채팅방/공구글에서 상대방이 링크를 올리면 URL로 인식하고 이를 탭했을 때 브라우저로 이동
- 기존 단방향이던 건의사항 보내기 기능을 양방향으로 바꿔 **개발팀과 실제 1:1 문의**가 가능하게끔 변경
- 기존 학생 인증 방식인 웹메일 인증 방식에 대한 불편 접수가 많아 **모바일 학생증 캡쳐 (OCR 검사) 기능** 추가
- Firebase Dynamic Link를 이용한 **공구글 공유 기능** 추가
- 공구글 정렬 기능 추가 (’모집 중 우선’, 최신순’)

## 🛠 v 1.0 출시 이후 코드 개선사항 (Refactoring)


✅  **스토리보드 → 100% Code-based layout으로 전환**

- 협업 시 발생하는 conflict 최소화, 빌드 타임 단축과 code based UI에 대한 감각을 익히기 위해 존재하던 ***40개 이상의 Storyboard*** VC와 XIB를 전부 SnapKit, Then, BaseViewController를 이용하여 전환

<img width="776" alt="Screen Shot 2022-01-10 at 2 13 29 PM" src="https://user-images.githubusercontent.com/44637101/155121468-5542cea0-f666-434a-ad36-8e83b1cd8bbe.png">



✅  **Git Flow를 이용한 버전 관리 및 협업 연습**

- 좌측 사진: Git Flow 사용 ***전***
- 우측 사진: Git Flow 사용 ***후***

![Screen Shot 2022-01-10 at 2 14 12 PM](https://user-images.githubusercontent.com/44637101/155121526-1813d528-e2fb-4762-bdc3-aa032a4768d3.png)
![Screen Shot 2022-01-10 at 2 14 22 PM](https://user-images.githubusercontent.com/44637101/155121535-9062361e-8a60-435b-9df5-d982e19672fd.png)




✅  **팀원과의 코드 리뷰 실시** 

- 서로 오류를 봐주고 더 효율적인 방법은 없는지 체크하여 전체적인 코드 품질을 올릴 수 있었습니다.

![Screen Shot 2022-01-10 at 2 40 37 PM](https://user-images.githubusercontent.com/44637101/155121616-0d6b26bf-6566-4e1c-b611-75debb0dac40.png)




✅  **Shared Instance 사용 지양 및 Dependency Injection 적용**

- Thread-safe 하지 않은 Shared instance 사용을 지양하고, 필요한 곳에서 직접 생성 후 사용하는 것으로 변경
- 한 클래스가 다른 객체를 직접 생성하는 부담을 줄여주고, 해당 클래스가 정확히 어떤 다른 객체에 의존하는지 명확히 보여주기 위해 **Dependency Injection** 적용


<img width="791" alt="Screen Shot 2022-01-10 at 2 22 48 PM" src="https://user-images.githubusercontent.com/44637101/155121675-7a259fdc-eec9-4358-b1dd-aed0d4ec7ce3.png">
<img width="711" alt="Screen Shot 2022-01-10 at 2 47 58 PM" src="https://user-images.githubusercontent.com/44637101/155121688-8f0e26da-4a1b-4191-8cb3-176fa6cbce7e.png">



✅  **ReactorKit 전환**

- 기존에는 View Controller와 ViewModel의 통신을 위해서 **Delegate Pattern**을 이용
- 하지만 Delegate protocol이 커질수록 상태 관리가 어렵고 코드 가독성이 매우 떨어져 RxSwift를 이용한 바인딩이 절실해 보였음
    - 부분적으로 적용해 나가기 쉽고 상태 관리가 용이한 ReactorKit을 사용하기로 선택 후 **지금까지 70% 이상 전환 완료**
    - **코드의 가독성이 눈에 띄게 좋아졌고**, 어떤 함수가 실행되는지 파악하기 위해 **이리저리 파일을 찾는 횟수가 현저히 감소**


<img width="457" alt="Screen Shot 2022-01-10 at 2 28 29 PM" src="https://user-images.githubusercontent.com/44637101/155121719-64b1d454-dcd1-4039-b9b0-0f64f015e937.png">
<img width="681" alt="Screen Shot 2022-01-10 at 2 30 14 PM" src="https://user-images.githubusercontent.com/44637101/155121727-b0e7f73e-2eb4-48c3-b306-e26054711f3e.png">



✅  **Alamofire → Moya 전환**

- 모두 별개로 작성되어 있던 API 통신 함수는 유지보수하기 어렵고, 지나치게 코드의 양을 늘리기 때문에 Moya 를 사용하여 전부 리팩토링 완료
- 좌측 사진: Moya 사용 ***전***
- 우측 사진: Moya 사용 ***후***

<img width="1348" alt="Screen Shot 2022-01-10 at 3 04 47 PM" src="https://user-images.githubusercontent.com/44637101/155121760-aba6c2a1-5e71-4ccf-aeff-99a0e3d2b977.png">
<img width="364" alt="Screen Shot 2022-01-10 at 3 04 07 PM" src="https://user-images.githubusercontent.com/44637101/155121772-f30326ea-a300-4b4c-8cfe-e16148da56d9.png">


## 🎢 더 개선할 수 있는 부분

- **Coordinator Pattern 적용**
    - 기존 MVVM 구조에서 Coordinator 패턴을 적용시킨 **MVVM-C 구조**를 적용해 Navigation Logic을 ViewController와 분리 가능
        - [x]  RxFlow 적용 완료
    
- **채팅 Local Caching**
    - 채팅 목록 불러오기가 현재는 API 호출을 통해서만 이루어지는데, Local Caching을 이용하여 불필요한 API 호출 횟수를 줄이고 로딩 시간을 줄여 더 나은 사용자 경험 구현이 가능해 보인다.
        - [ ]  Realm 또는 CoreData를 이용한 Local Caching 적용 예정

- **Unit Test 적용**
    - 기능이 점점 많아지면서 테스트해야 할 기능도 많아지고 깜빡하고 테스트를 하지 않으면 치명적인 오류 발생 가능성이 농후
    - Index out of range error, UI error, nil 처리 등 다양한 에러를 자동적으로 테스트하기 위한 Unit Test 가 절실해보임
        - [ ]  Unit Test 적용 예정

- **Fast Lane 도입으로 배포 자동화**
    - v1.0, 1.0.1, 1.1, 1.1.1 등 다양한 버전을 앱스토어에 배포하면서 불필요하게 낭비되는 바이너리 업로드 시간과 심사 제출 준비 시간이 있다는 것을 깨달음
    - 배포 자동화를 통한 불필요하게 낭비되는 시간을 줄일 필요가 있어보임.
        - [ ]  Fast Lane 도입 예정
        

## 🧐 어려웠던 점

✅  **백엔드와 첫 협업**

- 처음으로 백엔드와 협업을 했던 프로젝트였습니다. iOS 기본 문법을 배우고 바로 시작해서 모르는 것이 투성이었습니다.
- 처음 들어보는 수많은 용어들 🤯: JWT, AccessToken, RefreshToken, MultipartFormData, JSON Encoding, PostMan, ERD, FCM 등등..
    - 모르는 것이 있으면 공부하고, 팀원과 함께 나아간다는 마인드로 **정기적으로 스터디 세션**을 열어 개념을 익히고 프로젝트에 개념을 적용하였습니다.
- 수십개의 각각 다른 API..어떤건 query string, 어떤건 multipartFormData, 또 어떤건 json string.. 처음에는 너무 혼란스러웠지만 백엔드 팀원과 차근차근 이야기하고 인터넷을 뒤져가며 어떻게든 API 통신이 이뤄지게 했습니다.
- 무엇보다, 협업이 처음이다보니 오류가 나면 프론트 문제인지 백엔드 문제인지 파악하는 것이 처음에 제일 힘들었습니다.
    - 백엔드 문제라도 왜 문제가 일어나는 것 같은지, 나는 무엇을 시도해봤고 이렇게 해도 안 된다는 것을 **차근차근 백엔드 팀원의 입장에서 생각하며 소통**하는 역량을 기르게 되었습니다.
    

✅  **채팅 기능 (WebSocket)**

- 제일 막막했었고 제일 시간이 오래 걸렸던 기능입니다.
- 단순히 채팅 내용이 왔다갔다하는 것을 넘어서 **실시간성 보장** + **이전 채팅 불러오기** + Socket이 끊기면 **FCM 보내고 알림 받기** 등 **사용자 입장**에서 생각하고 구현해야 할 것이 너무 많아 초보 입장에서 많이 어려웠습니다.
- 관련 문서나 블로그도 거의 없어 **맨 땅에 헤딩하듯 수 많은 오류를 맞닥뜨리면서 구현에 성공**했습니다.

✅  **수 많은 경우의 수 생각**

- 개발을 할 때는 항상 Golden Path을 생각하지만, 실제 유저는 **개발자가 상상하지도 못한 방법**으로 앱을 사용한다는 것을 몸소 느꼈습니다.
- 1.0 출시 후 수백명이 몰렸을 때 각종 **crash/error 로그가 Crashlytics와 자체 서버에 찍히는 것을 보고 식은 땀을 흘렸습니다**.
    - iOS, Android, 백엔드 할 것 없이 사전에 발견하지 못했던 문제가 다수 발생해 급하게 1.0.1, 1.0.2 버전 등을 배포했었습니다.

→ **다양한 에러 처리에 대한 필요성**을 느꼈고 각 **에러에 따라 사용자한테 적절하게 UI**로 표시해줘야 한다는 것을 깨달았습니다.

## 📌 배운 점

- `REST API` 연동 방식에 대해 알고 프로젝트에 적용해 볼 수 있었습니다.
- `Web Socket`을 이용한 **실시간 채팅 기능**을 구현해 볼 수 있었습니다.
- **Storyboard**와 **Code-Based Layout** 두 개 모두 활용해 볼 수 있었으며 둘 사이의 장단점을 몸소 느낄 수 있었습니다.
- `BaseViewController`, `Moya` 등을 적용하여 **코드** **재사용성**을 높이기 위한 고민을 해 볼 수 있었습니다.
- `Dependency Injection`에 대해서 공부하고 왜 필요한지 이해할 수 있었습니다.
- `Delegate Pattern`의 한계를 느끼고 `RxSwift`와 `ReactorKit`을 공부하고 직접 프로젝트를 개선해 볼 수 있었습니다.
- “ ***하위 호환*** "과 관련된 문제를 고민하고 적용해 볼 수 있었습니다. (크누마켓 앱 버전 & iOS 버전)
    - 무조건 최신 앱 버전을 사용하는 유저만 고려하지 않고, ***이전 버전*** 과 ***최신 버전*** 사용자들이 서로 호환될 수 있게 UI와 Model 부분을 고려하였습니다.

## 🎉  그 외 마케팅 활동

✅  **인스타그램 홍보 계정 개설**

- [https://instagram.com/knumarket?utm_medium=copy_link](https://instagram.com/knumarket?utm_medium=copy_link)


![IMG_2013](https://user-images.githubusercontent.com/44637101/155121966-f69af7b8-f738-4595-b5a4-11809cd498bb.PNG)

![IMG_2014](https://user-images.githubusercontent.com/44637101/155121993-0f7d68a9-8368-47cd-b740-96474f09d1e9.PNG)

**✅  인터뷰 영상 촬영**
- [https://www.instagram.com/tv/CUHyLQejuW2/?utm_medium=copy_link](https://www.instagram.com/tv/CUHyLQejuW2/?utm_medium=copy_link)
![IMG_2016](https://user-images.githubusercontent.com/44637101/155122034-47e51884-0dc1-4690-a18b-52ef93150888.PNG)



✅  **경북대 신문 인터뷰**

- [https://www.knun.net/news/article.html?no=20543](https://www.knun.net/news/article.html?no=20543)



<img width="579" alt="Screen Shot 2022-01-12 at 1 34 03 PM" src="https://user-images.githubusercontent.com/44637101/155122230-78a2682d-1a45-45a5-aa27-dadfce7278df.png">




---

⚠️ ”**크누마켓**” 앱을 직접 다운 받아서 사용하시려면 ***경북대학교 학생 인증***을 거쳐야지만 정상적으로 사용이 가능합니다. 

→ 따라서 별도로 사용하고 싶으시다면 kevinkim2586@gmail.com 으로 성함과 사유를 알려주시면 사용해 보실 수 있도록 테스트 계정을 임시로 보내드리도록 하겠습니다. 감사합니다 :)


