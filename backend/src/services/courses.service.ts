import { pool } from '../db';

export interface CourseData {
  id: number;
  title: string;
  description: string;
  courseCategory: string;
  level: string;
  durationMinutes: number;
  totalQuestions: number;
  passingScore: number;
}

export interface CourseSubscription {
  courseId: number;
  subscribedAt: string;
  isActive: boolean;
}

export async function listCourses(): Promise<CourseData[]> {
  const result = await pool.query(
    `SELECT id, title, description, course_category, level, duration_minutes, total_questions, passing_score
     FROM courses
     ORDER BY course_category, level ASC`
  );

  return result.rows.map((row) => ({
    id: row.id,
    title: row.title,
    description: row.description,
    courseCategory: row.course_category,
    level: row.level,
    durationMinutes: row.duration_minutes,
    totalQuestions: row.total_questions,
    passingScore: Number(row.passing_score),
  }));
}

export async function getUserCourseSubscriptions(userId: number): Promise<CourseSubscription[]> {
  const result = await pool.query(
    `SELECT cs.course_id, cs.subscribed_at, cs.is_active
     FROM course_subscriptions cs
     WHERE cs.user_id = $1
     ORDER BY cs.subscribed_at DESC`,
    [userId]
  );

  return result.rows.map((row) => ({
    courseId: row.course_id,
    subscribedAt: row.subscribed_at,
    isActive: row.is_active,
  }));
}

export async function subscribeToCourse(userId: number, courseId: number): Promise<void> {
  await pool.query(
    `INSERT INTO course_subscriptions (user_id, course_id)
     VALUES ($1, $2)
     ON CONFLICT(user_id, course_id) DO UPDATE
     SET is_active = true, unsubscribed_at = NULL`,
    [userId, courseId]
  );
}

export async function unsubscribeFromCourse(userId: number, courseId: number): Promise<void> {
  await pool.query(
    `UPDATE course_subscriptions
     SET is_active = false, unsubscribed_at = NOW()
     WHERE user_id = $1 AND course_id = $2`,
    [userId, courseId]
  );
}

export async function getCourseById(courseId: number): Promise<CourseData | null> {
  const result = await pool.query(
    `SELECT id, title, description, course_category, level, duration_minutes, total_questions, passing_score
     FROM courses
     WHERE id = $1`,
    [courseId]
  );

  if (result.rows.length === 0) {
    return null;
  }

  const row = result.rows[0];
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    courseCategory: row.course_category,
    level: row.level,
    durationMinutes: row.duration_minutes,
    totalQuestions: row.total_questions,
    passingScore: Number(row.passing_score),
  };
}
