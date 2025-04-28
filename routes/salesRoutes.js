const express = require('express');
const router = express.Router();
const salesController = require('../controllers/salesController');
const { authenticateToken } = require('../middleware/authMiddleware');

// Apply auth middleware to all routes
router.use(authenticateToken);

// Create a new sale
router.post('/', salesController.createSale);

// Get all sales
router.get('/', salesController.getSales);

// Get sales summary
router.get('/summary', salesController.getSalesSummary);

// Get sale details
router.get('/:id', salesController.getSaleDetails);

// Update sale status
router.patch('/:id/status', salesController.updateSaleStatus);

// Lock a sale
router.patch('/:id/lock', salesController.lockSale);

module.exports = router; 
