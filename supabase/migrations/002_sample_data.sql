-- Sample data for development and testing
-- WARNING: Do not run in production

-- Insert sample profiles (requires auth.users to exist)
-- Note: In real scenario, users are created through Supabase Auth

-- Sample weight records for testing charts
-- These would be inserted after a test user is created
/*
INSERT INTO public.weight_records (user_id, weight, bmi, recorded_at, notes)
VALUES 
  ('user-uuid', 70.5, 24.22, NOW() - INTERVAL '7 days', '시작 체중'),
  ('user-uuid', 70.2, 24.12, NOW() - INTERVAL '6 days', NULL),
  ('user-uuid', 69.8, 23.98, NOW() - INTERVAL '5 days', '운동 시작'),
  ('user-uuid', 69.5, 23.88, NOW() - INTERVAL '4 days', NULL),
  ('user-uuid', 69.7, 23.95, NOW() - INTERVAL '3 days', '회식'),
  ('user-uuid', 69.3, 23.81, NOW() - INTERVAL '2 days', NULL),
  ('user-uuid', 69.0, 23.71, NOW() - INTERVAL '1 day', '목표에 가까워짐'),
  ('user-uuid', 68.8, 23.64, NOW(), '오늘의 체중');
*/

-- Views for easier data access
CREATE OR REPLACE VIEW public.weight_statistics AS
SELECT 
  user_id,
  COUNT(*) as total_records,
  MIN(weight) as min_weight,
  MAX(weight) as max_weight,
  AVG(weight) as avg_weight,
  MAX(weight) - MIN(weight) as weight_change,
  MIN(recorded_at) as first_record,
  MAX(recorded_at) as last_record
FROM public.weight_records
GROUP BY user_id;

-- View for latest weight record per user
CREATE OR REPLACE VIEW public.latest_weight AS
SELECT DISTINCT ON (user_id)
  user_id,
  weight,
  bmi,
  recorded_at
FROM public.weight_records
ORDER BY user_id, recorded_at DESC;