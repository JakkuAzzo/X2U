-- Driving Theory Test Courses
CREATE TABLE IF NOT EXISTS courses (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  course_category VARCHAR(100) NOT NULL, -- 'driving_theory'
  level VARCHAR(50), -- 'car', 'motorcycle', 'hgv', 'pcv', 'adi'
  duration_minutes INTEGER,
  total_questions INTEGER,
  passing_score DECIMAL(5, 2), -- e.g., 86.0 for 86%
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS course_subscriptions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  subscribed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  unsubscribed_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  UNIQUE(user_id, course_id)
);

CREATE INDEX IF NOT EXISTS idx_courses_category ON courses(course_category);
CREATE INDEX IF NOT EXISTS idx_courses_level ON courses(level);
CREATE INDEX IF NOT EXISTS idx_course_subscriptions_user_id ON course_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_course_subscriptions_course_id ON course_subscriptions(course_id);
CREATE INDEX IF NOT EXISTS idx_course_subscriptions_is_active ON course_subscriptions(is_active);

-- Seed driving theory courses
INSERT INTO courses (title, description, course_category, level, duration_minutes, total_questions, passing_score)
VALUES
  ('Car Theory Test', 'UK car theory test preparation with official DVSA questions', 'driving_theory', 'car', 90, 50, 86.0),
  ('Motorcycle Theory Test', 'UK motorcycle theory test preparation', 'driving_theory', 'motorcycle', 75, 50, 86.0),
  ('HGV Theory Test', 'UK heavy goods vehicle theory test preparation', 'driving_theory', 'hgv', 90, 100, 80.0),
  ('PCV Theory Test', 'UK passenger carrying vehicle theory test preparation', 'driving_theory', 'pcv', 90, 100, 80.0),
  ('ADI Theory Test', 'UK approved driving instructor theory test preparation', 'driving_theory', 'adi', 120, 100, 86.0)
ON CONFLICT DO NOTHING;
