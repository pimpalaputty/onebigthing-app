-- One Big Thing App - Adatbázis setup
-- Futtasd le a Supabase SQL Editor-ben

-- Napi célok tábla
CREATE TABLE IF NOT EXISTS daily_goals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  big_goal TEXT NOT NULL,
  big_goal_completed BOOLEAN DEFAULT false,
  small_goal_1 TEXT NOT NULL,
  small_goal_1_completed BOOLEAN DEFAULT false,
  small_goal_2 TEXT NOT NULL,
  small_goal_2_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(user_id, date)
);

-- Felhasználói statisztikák tábla
CREATE TABLE IF NOT EXISTS user_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
  total_days INTEGER DEFAULT 0,
  big_goals_completed INTEGER DEFAULT 0,
  small_goals_completed INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_activity_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- RLS (Row Level Security) engedélyezése
ALTER TABLE daily_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;

-- RLS policy-k - felhasználók csak a saját adataikat láthatják/módosíthatják
CREATE POLICY "Users can view own daily goals" ON daily_goals
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily goals" ON daily_goals
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily goals" ON daily_goals
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own daily goals" ON daily_goals
  FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own stats" ON user_stats
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON user_stats
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON user_stats
  FOR UPDATE USING (auth.uid() = user_id);

-- Indexek a jobb teljesítményért
CREATE INDEX IF NOT EXISTS idx_daily_goals_user_date ON daily_goals(user_id, date);
CREATE INDEX IF NOT EXISTS idx_daily_goals_date ON daily_goals(date);
CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON user_stats(user_id);

-- Trigger a updated_at automatikus frissítéséhez
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_daily_goals_updated_at BEFORE UPDATE ON daily_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_stats_updated_at BEFORE UPDATE ON user_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
