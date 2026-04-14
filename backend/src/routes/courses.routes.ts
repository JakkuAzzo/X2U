import { Router, Request, Response } from 'express';
import { authenticateToken } from '../middleware/auth';
import {
  listCourses,
  getUserCourseSubscriptions,
  subscribeToCourse,
  unsubscribeFromCourse,
  getCourseById,
} from '../services/courses.service';
import { createAuditLog } from '../services/auth.service';

const router = Router();

/**
 * GET /api/courses
 * Get all available courses
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const courses = await listCourses();
    res.json({ courses });
  } catch (error) {
    console.error('Courses fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch courses' });
  }
});

/**
 * GET /api/courses/:courseId
 * Get a specific course by ID
 */
router.get('/:courseId', async (req: Request, res: Response) => {
  try {
    const courseId = Number(req.params.courseId);
    if (!Number.isInteger(courseId) || courseId <= 0) {
      res.status(400).json({ error: 'Invalid course id' });
      return;
    }

    const course = await getCourseById(courseId);
    if (!course) {
      res.status(404).json({ error: 'Course not found' });
      return;
    }

    res.json(course);
  } catch (error) {
    console.error('Course fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch course' });
  }
});

/**
 * GET /api/courses/user/subscriptions
 * Get authenticated user's course subscriptions
 */
router.get('/user/subscriptions', authenticateToken, async (req: Request, res: Response) => {
  try {
    const subscriptions = await getUserCourseSubscriptions(req.userId!);
    res.json({ subscriptions });
  } catch (error) {
    console.error('Course subscriptions fetch error:', error);
    res.status(500).json({ error: 'Failed to fetch subscriptions' });
  }
});

/**
 * POST /api/courses/:courseId/subscribe
 * Subscribe authenticated user to a course
 */
router.post('/:courseId/subscribe', authenticateToken, async (req: Request, res: Response) => {
  try {
    const courseId = Number(req.params.courseId);
    if (!Number.isInteger(courseId) || courseId <= 0) {
      res.status(400).json({ error: 'Invalid course id' });
      return;
    }

    const course = await getCourseById(courseId);
    if (!course) {
      res.status(404).json({ error: 'Course not found' });
      return;
    }

    await subscribeToCourse(req.userId!, courseId);
    await createAuditLog(
      req.userId ?? null,
      'course_subscribed',
      'course',
      courseId,
      null,
      { courseTitle: course.title },
      req.ip,
      req.headers['user-agent']
    );

    res.json({ message: `Subscribed to ${course.title}` });
  } catch (error) {
    console.error('Course subscription error:', error);
    res.status(500).json({ error: 'Failed to subscribe to course' });
  }
});

/**
 * POST /api/courses/:courseId/unsubscribe
 * Unsubscribe authenticated user from a course
 */
router.post('/:courseId/unsubscribe', authenticateToken, async (req: Request, res: Response) => {
  try {
    const courseId = Number(req.params.courseId);
    if (!Number.isInteger(courseId) || courseId <= 0) {
      res.status(400).json({ error: 'Invalid course id' });
      return;
    }

    const course = await getCourseById(courseId);
    if (!course) {
      res.status(404).json({ error: 'Course not found' });
      return;
    }

    await unsubscribeFromCourse(req.userId!, courseId);
    await createAuditLog(
      req.userId ?? null,
      'course_unsubscribed',
      'course',
      courseId,
      null,
      { courseTitle: course.title },
      req.ip,
      req.headers['user-agent']
    );

    res.json({ message: `Unsubscribed from ${course.title}` });
  } catch (error) {
    console.error('Course unsubscribe error:', error);
    res.status(500).json({ error: 'Failed to unsubscribe from course' });
  }
});

export default router;
