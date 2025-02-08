# legalfactfinder2025

Legal FactFinder

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



[파일을 업로드하는 2가지 경우의 각각의 처리]

1. 스토리지에 (챗메시지 첨부파일이 아니라) 그냥 파일을 업로드할 때에는,
   1-1. 클라이언트에서 스토리지에 파일 업로드가 성공하면,
   1-2. 클라이언트가 put_file_data 라는 edge function 을 호출해서 files 테이블에 uploader_id 를 포함한 값들을 입력하고,
   1-3. 위와 같이 files 테이블에 행이 추가되면, 이에 대해 트리거가 작동하여 chat_messages 테이블에 새로운 챗메시지 추가.

2. 스토리지에 챗메시지 첨부파일로 업로드할 때에는,
   2-1. 클라이언트에서 스토리지에 파일 업로드가 성공하면,
   2-2. edge function 을 호출해서 chat_message 를 추가하고,
   2-3. 트리거가  put_file_data 라는 edge function 을 호출해서 files 테이블에 uploader_id , chat_message_id 를 포함한 값들을 입력하고,
   2-4. 이 경우에는 files 테이블에 chat_message_id 가 존재한다는 이유로, 위의 1-3에서 말한 트리거는 작동하지 않음. 

git push -u origin main     