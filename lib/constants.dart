// lib/constants/constants.dart

// Supabase 설정
const String baseUrl = 'https://jschbqhrzkdqcpbidqhj.supabase.co';
const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzY2hicWhyemtkcWNwYmlkcWhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NDM3MjMsImV4cCI6MjA1MzAxOTcyM30.0LZdDrL_MvVUOdHQm8quR1xfpWIyxq7MofdaJ_hNRJQ';

// Supabase Edge Functions
const String getChatMessagesEdgeFunctionUrl = '$baseUrl/functions/v1/get_chat_messages';
const String putChatMessageEdgeFunctionUrl = '$baseUrl/functions/v1/put_chat_message';
const String getThreadChatMessagesEdgeFunctionUrl = '$baseUrl/functions/v1/get_thread_chat_messages';
const String putThreadChatMessageEdgeFunctionUrl = '$baseUrl/functions/v1/put_thread_chat_message';
const String getThreadsEdgeFunctionUrl = '$baseUrl/functions/v1/get_threads_by_work_room_id';
const String getParentMessageEdgeFunctionUrl = '$baseUrl/functions/v1/get_chat_message_by_id';
const String getUserNotificationsEdgeFunctionUrl = '$baseUrl/functions/v1/get_user_notifications';
const String putDocumentAnnotationEdgeFunctionUrl = '$baseUrl/functions/v1/put_document_annotation';


// JWT Token
const String jwtToken = anonKey; // 재사용 가능하도록 alias 설정

// for test
const String TEST_USER_NAME = "TEST USER";
const String TEST_USER_EMAIL = "iamjaehaklee@gmail.com";

const String appTitle = "Legal FactFinder";
const String appSubtitle = "철저한 팩트 파악은 법률 문제 해결의 핵심입니다!";


 const double ICON_SIZE_AT_APPBAR = 24;