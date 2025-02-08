import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' 
    )

    // Get the request body
    const { work_room_id } = await req.json()

    if (!work_room_id) {
      throw new Error('work_room_id is required')
    }

    // 1. 먼저 모든 부모 메시지(parent_message_id가 null인 메시지)를 가져옵니다.
    const { data: parentMessages, error: parentError } = await supabaseClient
      .from('chat_messages')
      .select('id, content, sender_id, created_at')
      .eq('work_room_id', work_room_id)
      .is('parent_message_id', null)
      .eq('is_deleted', false)
      .order('created_at', { ascending: false })

    if (parentError) throw parentError

    // 2. 각 부모 메시지에 대한 최신 답글과 답글 수를 가져옵니다.
    const threads = await Promise.all(
      parentMessages.map(async (parent) => {
        // 답글 수 조회
        const { count: threadCount, error: countError } = await supabaseClient
          .from('chat_messages')
          .select('*', { count: 'exact', head: true })
          .eq('parent_message_id', parent.id)
          .eq('is_deleted', false)

        if (countError) throw countError

        // 최신 답글 조회
        const { data: latestReplies, error: replyError } = await supabaseClient
          .from('chat_messages')
          .select('id, content, sender_id, created_at')
          .eq('parent_message_id', parent.id)
          .eq('is_deleted', false)
          .order('created_at', { ascending: false })
          .limit(1)

        if (replyError) throw replyError

        const latestReply = latestReplies[0] || null

        // Thread 객체 구성
        return {
          id: parent.id,
          parent_message_id: parent.id,
          parent_content: parent.content,
          parent_sender_id: parent.sender_id,
          parent_created_at: parent.created_at,
          latest_reply_id: latestReply?.id || '',
          latest_reply_content: latestReply?.content || '',
          latest_reply_sender_id: latestReply?.sender_id || '',
          latest_reply_created_at: latestReply?.created_at || parent.created_at,
          thread_count: threadCount
        }
      })
    )

    // 최신 답글이 있는 쓰레드를 우선 정렬하고, 그 다음 최신 업데이트 순으로 정렬
    threads.sort((a, b) => {
      // 둘 다 답글이 있는 경우 최신 답글 시간으로 정렬
      if (a.latest_reply_id && b.latest_reply_id) {
        return new Date(b.latest_reply_created_at).getTime() - new Date(a.latest_reply_created_at).getTime()
      }
      // 답글이 있는 쓰레드를 우선 순위
      if (a.latest_reply_id) return -1
      if (b.latest_reply_id) return 1
      // 둘 다 답글이 없는 경우 부모 메시지 시간으로 정렬
      return new Date(b.parent_created_at).getTime() - new Date(a.parent_created_at).getTime()
    })

    return new Response(
      JSON.stringify({
        threads: threads
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})
