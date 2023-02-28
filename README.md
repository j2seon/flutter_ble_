# flutter_ble

## flutter 블루투스 연결

1. reactive_ble 라이브러리사용
2. 화면 열자마자 자동스캔.
3. shared_preferences 이용해서 auto connect 예정이였으나 구현미숙
4. 현재 conncet을 index를 이용하여 각 기기를 탐색 
  -> Map에 각 기기의 serviceid를 key로 device를 value로 저장 
  -> serviceid로 찾을 수 있도록 connect 함수로직은 전부 수정할 필요성 보임..
5. 값을 보내고 기기에서 보낸 값을 읽도록 구현 (아두이노)
  -> 응답값 없는 쓰기와 읽기는 가능
  -> BUT 응답값이 있는 쓰기는 에러남....
 
6.쓰다보니 connect함수가 길어져서 분리해서 재작성해야함.
