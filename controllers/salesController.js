const { prisma } = require('../lib/prisma');

const salesController = {
  createSale: async (req, res) => {
    try {
      const { productId, quantity, unitPrice, total, clientId } = req.body;
      
      const sale = await prisma.sale.create({
        data: {
          productId,
          quantity,
          unitPrice,
          total,
          clientId,
          createdBy: req.user.id,
          status: 'pending',
          isLocked: false,
        },
        include: {
          product: true,
          client: true,
        },
      });

      res.status(201).json(sale);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getSales: async (req, res) => {
    try {
      const sales = await prisma.sale.findMany({
        include: {
          product: true,
          client: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      res.json(sales);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getSalesSummary: async (req, res) => {
    try {
      const totalSales = await prisma.sale.aggregate({
        _sum: {
          total: true,
        },
      });

      const salesByStatus = await prisma.sale.groupBy({
        by: ['status'],
        _count: {
          status: true,
        },
      });

      res.json({
        totalSales: totalSales._sum.total || 0,
        salesByStatus,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  getSaleDetails: async (req, res) => {
    try {
      const { id } = req.params;
      const sale = await prisma.sale.findUnique({
        where: { id: parseInt(id) },
        include: {
          product: true,
          client: true,
        },
      });

      if (!sale) {
        return res.status(404).json({ error: 'Sale not found' });
      }

      res.json(sale);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  updateSaleStatus: async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;

      const sale = await prisma.sale.findUnique({
        where: { id: parseInt(id) },
      });

      if (!sale) {
        return res.status(404).json({ error: 'Sale not found' });
      }

      if (sale.isLocked) {
        return res.status(403).json({ error: 'Sale is locked and cannot be modified' });
      }

      const updatedSale = await prisma.sale.update({
        where: { id: parseInt(id) },
        data: { status },
        include: {
          product: true,
          client: true,
        },
      });

      res.json(updatedSale);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },

  lockSale: async (req, res) => {
    try {
      const { id } = req.params;

      const sale = await prisma.sale.findUnique({
        where: { id: parseInt(id) },
      });

      if (!sale) {
        return res.status(404).json({ error: 'Sale not found' });
      }

      // Only allow locking if user is admin or created the sale
      if (req.user.role !== 'admin' && sale.createdBy !== req.user.id) {
        return res.status(403).json({ error: 'Not authorized to lock this sale' });
      }

      const updatedSale = await prisma.sale.update({
        where: { id: parseInt(id) },
        data: { isLocked: true },
        include: {
          product: true,
          client: true,
        },
      });

      res.json(updatedSale);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  },
};

module.exports = salesController; 