-- Phase 4: 클라우드 동기화를 위한 추가 테이블

-- 1. Notification settings 테이블 (기존에 없는 경우)
CREATE TABLE IF NOT EXISTS public.notification_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    is_enabled BOOLEAN DEFAULT FALSE,
    reminder_time TIME NOT NULL DEFAULT '09:00:00',
    selected_days BOOLEAN[] DEFAULT ARRAY[true, true, true, true, true, true, true],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id)
);

-- 2. 동기화 상태 추적 테이블
CREATE TABLE IF NOT EXISTS public.sync_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    table_name TEXT NOT NULL,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_status TEXT CHECK (sync_status IN ('pending', 'syncing', 'completed', 'failed')),
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    UNIQUE(user_id, table_name)
);

-- 3. 오프라인 큐 테이블
CREATE TABLE IF NOT EXISTS public.offline_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    operation TEXT NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
    processed_at TIMESTAMP WITH TIME ZONE,
    is_processed BOOLEAN DEFAULT FALSE
);

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_notification_settings_user_id ON public.notification_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_sync_status_user_id ON public.sync_status(user_id);
CREATE INDEX IF NOT EXISTS idx_offline_queue_user_id ON public.offline_queue(user_id);
CREATE INDEX IF NOT EXISTS idx_offline_queue_processed ON public.offline_queue(is_processed, created_at);

-- RLS 활성화
ALTER TABLE public.notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offline_queue ENABLE ROW LEVEL SECURITY;

-- RLS 정책 추가

-- Notification settings policies
CREATE POLICY "Users can view own notification settings" ON public.notification_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own notification settings" ON public.notification_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification settings" ON public.notification_settings
    FOR UPDATE USING (auth.uid() = user_id);

-- Sync status policies
CREATE POLICY "Users can view own sync status" ON public.sync_status
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own sync status" ON public.sync_status
    FOR ALL USING (auth.uid() = user_id);

-- Offline queue policies
CREATE POLICY "Users can view own offline queue" ON public.offline_queue
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own offline queue" ON public.offline_queue
    FOR ALL USING (auth.uid() = user_id);

-- Trigger for notification_settings updated_at
CREATE TRIGGER update_notification_settings_updated_at BEFORE UPDATE ON public.notification_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger for sync_status updated_at
CREATE TRIGGER update_sync_status_updated_at BEFORE UPDATE ON public.sync_status
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();