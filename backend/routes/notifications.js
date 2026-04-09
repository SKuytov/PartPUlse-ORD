// backend/routes/notifications.js - Notification API
const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken } = require('../middleware/auth');

router.use(authenticateToken);

// GET /api/notifications - Get user's notifications
router.get('/', async (req, res) => {
    try {
        const [notifications] = await db.query(
            `SELECT * FROM notifications
             WHERE user_id = ?
             ORDER BY created_at DESC
             LIMIT 50`,
            [req.user.id]
        );
        res.json({ success: true, notifications });
    } catch (error) {
        console.error('Get notifications error:', error);
        res.json({ success: true, notifications: [] });
    }
});

// GET /api/notifications/unread-count
router.get('/unread-count', async (req, res) => {
    try {
        const [[result]] = await db.query(
            'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
            [req.user.id]
        );
        res.json({ success: true, count: result.count });
    } catch (error) {
        res.json({ success: true, count: 0 });
    }
});

// PUT /api/notifications/:id/read - Mark notification as read
router.put('/:id/read', async (req, res) => {
    try {
        await db.query(
            'UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?',
            [req.params.id, req.user.id]
        );
        res.json({ success: true });
    } catch (error) {
        console.error('Mark read error:', error);
        res.json({ success: false, message: 'Failed to mark notification as read' });
    }
});

// PUT /api/notifications/read-all - Mark all notifications as read
router.put('/read-all', async (req, res) => {
    try {
        await db.query(
            'UPDATE notifications SET is_read = 1 WHERE user_id = ?',
            [req.user.id]
        );
        res.json({ success: true });
    } catch (error) {
        console.error('Mark all read error:', error);
        res.json({ success: false, message: 'Failed to mark all as read' });
    }
});

// Helper: Create notification (used by other modules)
async function createNotification(userId, type, title, message, orderId = null, approvalId = null) {
    try {
        await db.query(
            `INSERT INTO notifications (user_id, type, title, message, related_order_id, related_approval_id)
             VALUES (?, ?, ?, ?, ?, ?)`,
            [userId, type, title, message, orderId, approvalId]
        );
    } catch (error) {
        console.error('Create notification error:', error);
    }
}

module.exports = router;
module.exports.createNotification = createNotification;
