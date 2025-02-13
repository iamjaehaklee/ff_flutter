// lib/constants/constants.dart

// Supabase 설정
const String baseUrl = 'https://jschbqhrzkdqcpbidqhj.supabase.co';
const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzY2hicWhyemtkcWNwYmlkcWhqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc0NDM3MjMsImV4cCI6MjA1MzAxOTcyM30.0LZdDrL_MvVUOdHQm8quR1xfpWIyxq7MofdaJ_hNRJQ';

// Supabase Edge Functions
// chat_messages
const String getChatMessages_EdgeFunctionUrl = '$baseUrl/functions/v1/get_chat_messages';
const String putChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/put_chat_message';
const String updateChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/update_chat_message';
const String updateChatMessageHighlight_EdgeFunctionUrl = '$baseUrl/functions/v1/update_chat_message_highlight';
const String deleteChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/delete_chat_message';

// thread_chat_messages
const String getThreads_EdgeFunctionUrl = '$baseUrl/functions/v1/get_threads_by_work_room_id';
const String getThreadChatMessages_EdgeFunctionUrl = '$baseUrl/functions/v1/get_thread_chat_messages';
const String putThreadChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/put_thread_chat_message';
const String getParentMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/get_chat_message_by_id';
const String updateThreadChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/update_thread_chat_message';
const String updateThreadChatMessageHighlight_EdgeFunctionUrl = '$baseUrl/functions/v1/update_thread_chat_message_highlight';
const String deleteThreadChatMessage_EdgeFunctionUrl = '$baseUrl/functions/v1/delete_thread_chat_message';

// work_rooms
const String getWorkRoomLatestMessagesUrl = '$baseUrl/functions/v1/get_work_room_latest_messages';

// notifications
const String getUserNotificationsEdgeFunctionUrl = '$baseUrl/functions/v1/get_user_notifications';

// annotations
const String putDocumentAnnotationEdgeFunctionUrl = '$baseUrl/functions/v1/put_document_annotation';

//annotation threads
const String getAnnotationThreadsByAnnotationIdEdgeFunctionUrl = '$baseUrl/functions/v1/get_annotation_treads_by_annotation_id';
const String putAnnotationThreadEdgeFunctionUrl = '$baseUrl/functions/v1/put_annotation_thread';
const String deleteAnnotationThreadEdgeFunctionUrl = '$baseUrl/functions/v1/delete_annotation_thread';
const String updateAnnotationThreadEdgeFunctionUrl = '$baseUrl/functions/v1/update_annotation_thread';



const String getUsersByIdsUrl = '$baseUrl/functions/v1/get_users_by_ids';

// OCR
const String ocrkrNaverClovaEdgeFunctionUrl = '$baseUrl/functions/v1/ocr_kr_naver_clova';


// JWT Token
const String jwtToken = anonKey; // 재사용 가능하도록 alias 설정



const String appTitle = "Legal FactFinder";
const String appSubtitle = "철저한 팩트 파악은 법률 문제 해결의 핵심입니다!";


 const double ICON_SIZE_AT_APPBAR = 24;
 const double BOTTOM_SHEET_TOP_MARGIN = 60;