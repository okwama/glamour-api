const { getPrismaClient } = require('../lib/prisma');
const prisma = getPrismaClient();

// Create order with order items
const createOrder = async (req, res) => {
  console.log('=== Create Order Request ===');
  console.log('Request Body:', {
    clientId: req.body.clientId,
    orderItems: req.body.orderItems,
    comment: req.body.comment,
    customerType: req.body.customerType,
    customerId: req.body.customerId,
    customerName: req.body.customerName
  });
  console.log('User:', req.user);

  const { clientId, orderItems } = req.body;
  const salesRepId = req.user.id;

  try {
    // Validate required fields
    if (!clientId || !orderItems || orderItems.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: clientId and orderItems are required',
      });
    }

    // Validate client exists
    const client = await prisma.clients.findUnique({
      where: { id: clientId },
    });
    if (!client) {
      return res.status(404).json({
        success: false,
        error: 'Client not found',
      });
    }

    // Get sales rep's region_id
    const salesRep = await prisma.salesRep.findUnique({
      where: { id: salesRepId },
      select: { region_id: true }
    });
    const regionId = salesRep.region_id;

    // Find all stores in the sales rep's region
    const stores = await prisma.stores.findMany({
      where: { regionId },
      select: { id: true }
    });
    const storeIds = stores.map(store => store.id);

    // Check product availability in region stores
    for (const item of orderItems) {
      if (!item.productId || !item.quantity) {
        return res.status(400).json({
          success: false,
          error: 'Each order item must have productId and quantity',
        });
      }

      // Fetch product and its category (for pack size)
      const product = await prisma.product.findUnique({
        where: { id: item.productId },
        include: { 
          category: true,
          storeQuantities: {
            include: {
              store: true
            }
          }
        }
      });

      if (!product) {
        return res.status(404).json({
          success: false,
          error: `Product with ID ${item.productId} not found`,
        });
      }

      // Get pack size
      let packSize = 1;
      if (product.packSize) packSize = product.packSize;
      else if (product.category && product.category.packSize) packSize = product.category.packSize;

      // Validate pack quantity
      if (packSize > 1) {
        if (!Number.isInteger(item.quantity) || item.quantity <= 0) {
          return res.status(400).json({
            success: false,
            error: `Invalid quantity for product ${product.name}: must be a positive integer number of packs`,
          });
        }
      }

      const totalNeeded = item.quantity * packSize;

      // Get all stores in the user's region
      const regionStores = await prisma.stores.findMany({
        where: { regionId: salesRep.region_id }
      });

      if (regionStores.length === 0) {
        return res.status(400).json({
          success: false,
          error: `No stores available in your region for product ${product.name}`,
        });
      }

      // Get store quantities for this product in the region
      const regionStoreQuantities = await prisma.storeQuantity.findMany({
        where: {
          productId: item.productId,
          storeId: { in: regionStores.map(store => store.id) }
        }
      });

      if (regionStoreQuantities.length === 0) {
        return res.status(400).json({
          success: false,
          error: `Product ${product.name} is out of stock in your region`,
        });
      }

      // Find the store with highest quantity
      const maxQuantity = regionStoreQuantities.reduce((max, sq) => 
        sq.quantity > max ? sq.quantity : max, 0);

      if (maxQuantity <= 0) {
        return res.status(400).json({
          success: false,
          error: `Product ${product.name} is out of stock in your region`,
        });
      }

      if (maxQuantity < totalNeeded) {
        return res.status(400).json({
          success: false,
          error: `Insufficient stock for product ${product.name} in your region. Maximum available: ${maxQuantity}`,
        });
      }

      // If price option is provided, validate it
      if (item.priceOptionId) {
        const categoryWithPriceOptions = await prisma.category.findUnique({
          where: { id: product.category_id },
          include: { priceOptions: true }
        });
        if (!categoryWithPriceOptions) {
          return res.status(404).json({
            success: false,
            error: `Category not found for product ${product.name}`,
          });
        }
        const priceOption = categoryWithPriceOptions.priceOptions.find(
          po => po.id === item.priceOptionId
        );
        if (!priceOption) {
          return res.status(404).json({
            success: false,
            error: `Price option with ID ${item.priceOptionId} not found for product ${product.name}`,
          });
        }
      }
    }

    // Get client type and map to a customer type string
    let customerType = "BUSINESS";
    if (client.client_type !== null && client.client_type !== undefined) {
      switch (client.client_type) {
        case 1:
          customerType = "RETAIL";
          break;
        case 2:
          customerType = "WHOLESALE";
          break;
        case 3:
          customerType = "DISTRIBUTOR";
          break;
        default:
          customerType = "BUSINESS";
      }
    }

    // Create new order
    const newOrder = await prisma.myOrder.create({
      data: {
        totalAmount: 0, // Will update later
        comment: req.body.comment || "",
        customerType: customerType,
        customerId: req.body.customerId || "",
        customerName: req.body.customerName || client.name,
        user: { connect: { id: salesRepId } },
        client: { connect: { id: clientId } }
      }
    });

    // Create order items and calculate totalAmount
    let totalAmount = 0;
    const createdOrderItems = [];
    for (const item of orderItems) {
      // Get product and its price options to calculate price
      const product = await prisma.product.findUnique({
        where: { id: item.productId }
      });
      if (!product) continue;
      const categoryWithPriceOptions = await prisma.category.findUnique({
        where: { id: product.category_id },
        include: { priceOptions: true }
      });
      let itemPrice = 0;
      if (item.priceOptionId) {
        const priceOption = categoryWithPriceOptions.priceOptions?.find(
          po => po?.id === item.priceOptionId
        );
        if (priceOption) itemPrice = priceOption.value || 0;
      }
      try {
        const orderItemData = {
          quantity: item.quantity,
          orderId: newOrder.id,
          productId: item.productId
        };
        const orderItem = await prisma.orderItem.create({
          data: orderItemData
        });
        if (item.priceOptionId) {
          try {
            await prisma.$executeRaw`
              UPDATE OrderItem 
              SET priceOptionId = ${item.priceOptionId} 
              WHERE id = ${orderItem.id}
            `;
          } catch (priceOptionError) {}
        }
        createdOrderItems.push(orderItem);
        totalAmount += itemPrice * item.quantity;
      } catch (error) {
        continue;
      }
    }
    if (createdOrderItems.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Failed to create any order items'
      });
    }
    // Update order with final amount
    try {
      const updatedOrder = await prisma.myOrder.update({
        where: { id: newOrder.id },
        data: {
          totalAmount: parseFloat((totalAmount || 0).toFixed(2))
        },
        include: {
          orderItems: {
            include: {
              product: true,
              priceOption: true
            }
          },
          client: true,
          user: {
            select: {
              id: true,
              name: true,
              phoneNumber: true
            }
          }
        }
      });
      res.status(201).json({
        success: true,
        data: updatedOrder
      });
    } catch (finalUpdateError) {
      res.status(201).json({
        success: true,
        data: {
          id: newOrder.id,
          message: 'Order created but final update failed'
        },
        warning: 'Order total could not be updated'
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      error: 'Failed to create order'
    });
  }
};

// Optimized order creation function (does not replace existing createOrder)
const createOrderOptimized = async (req, res) => {
  console.log('=== [Optimized] Create Order Request ===');
  console.log('Request Body:', {
    clientId: req.body.clientId,
    orderItems: req.body.orderItems,
    comment: req.body.comment,
    customerType: req.body.customerType,
    customerId: req.body.customerId,
    customerName: req.body.customerName
  });
  console.log('User:', req.user);

  const { clientId, orderItems } = req.body;
  const salesRepId = req.user.id;

  try {
    // Validate required fields
    if (!clientId || !orderItems || orderItems.length === 0) {
      console.log('Validation failed: Missing required fields');
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: clientId and orderItems are required',
      });
    }

    // Validate client exists
    const client = await prisma.clients.findUnique({ where: { id: clientId } });
    if (!client) {
      console.log('Validation failed: Client not found');
      return res.status(404).json({
        success: false,
        error: 'Client not found',
      });
    }

    // Map client_type to customerType
    let customerType = "BUSINESS";
    switch (client.client_type) {
      case 1:
        customerType = "RETAIL";
        break;
      case 2:
        customerType = "WHOLESALE";
        break;
      case 3:
        customerType = "DISTRIBUTOR";
        break;
      default:
        customerType = "BUSINESS";
    }

    // Gather all productIds and priceOptionIds
    const productIds = orderItems.map(item => item.productId);
    const priceOptionIds = orderItems.map(item => item.priceOptionId).filter(Boolean);

    console.log('Product IDs:', productIds);
    console.log('Price Option IDs:', priceOptionIds);

    // Batch fetch products
    const products = await prisma.product.findMany({
      where: { id: { in: productIds } }
    });
    console.log('Found products:', products.map(p => ({ id: p.id, name: p.name })));

    const productsById = Object.fromEntries(products.map(p => [p.id, p]));

    // Batch fetch categories (with priceOptions)
    const categoryIds = [...new Set(products.map(p => p.category_id).filter(Boolean))];
    console.log('Category IDs:', categoryIds);

    const categories = await prisma.category.findMany({
      where: { id: { in: categoryIds } },
      include: { priceOptions: true }
    });
    console.log('Found categories with price options:', categories.map(c => ({
      id: c.id,
      name: c.name,
      priceOptions: c.priceOptions
    })));

    const categoriesById = Object.fromEntries(categories.map(c => [c.id, c]));

    // Validate and prepare order items
    let totalAmount = 0;
    const orderItemsData = [];
    for (const item of orderItems) {
      console.log('Processing order item:', item);
      
      if (!item.productId || !item.quantity) {
        console.log('Validation failed: Missing productId or quantity');
        return res.status(400).json({
          success: false,
          error: 'Each order item must have productId and quantity',
        });
      }

      const product = productsById[item.productId];
      if (!product) {
        console.log('Validation failed: Product not found');
        return res.status(404).json({
          success: false,
          error: `Product with ID ${item.productId} not found`,
        });
      }

      // Check stock availability in region
      const regionStores = await prisma.stores.findMany({
        where: { regionId: req.user.region_id }
      });
      const storeIds = regionStores.map(store => store.id);
      
      const storeQuantities = await prisma.storeQuantity.findMany({
        where: {
          productId: item.productId,
          storeId: { in: storeIds }
        }
      });

      const maxQuantity = storeQuantities.reduce((max, sq) => 
        sq.quantity > max ? sq.quantity : max, 0);

      if (maxQuantity < item.quantity) {
        console.log('Validation failed: Insufficient stock');
        return res.status(400).json({
          success: false,
          error: `Insufficient stock for product ${product.name} in your region. Maximum available: ${maxQuantity}`,
        });
      }

      let itemPrice = 0;
      let priceOptionId = null;
      if (item.priceOptionId) {
        const category = categoriesById[product.category_id];
        if (!category) {
          console.log('Validation failed: Category not found');
          return res.status(404).json({
            success: false,
            error: `Category not found for product ${product.name}`,
          });
        }
        const priceOption = category.priceOptions.find(po => po.id === item.priceOptionId);
        if (!priceOption) {
          console.log('Validation failed: Price option not found');
          return res.status(404).json({
            success: false,
            error: `Price option with ID ${item.priceOptionId} not found for product ${product.name}`,
          });
        }
        itemPrice = priceOption.value || 0;
        priceOptionId = priceOption.id;
      }

      // Calculate total amount
      totalAmount += itemPrice * item.quantity;
      orderItemsData.push({
        quantity: item.quantity,
        productId: item.productId,
        priceOptionId: priceOptionId,
      });
    }

    console.log('Creating order with data:', {
      totalAmount,
      customerType,
      salesRepId,
      clientId,
      orderItemsData
    });

    // Transaction: create order and items
    const [newOrder] = await prisma.$transaction([
      prisma.myOrder.create({
        data: {
          totalAmount: totalAmount,
          comment: req.body.comment || "",
          customerType: customerType,
          customerId: req.body.customerId || "",
          customerName: req.body.customerName || client.name,
          user: { connect: { id: salesRepId } },
          client: { connect: { id: clientId } },
        }
      })
    ]);

    console.log('Created order:', newOrder);

    // Add orderId to each item
    const orderItemsWithOrderId = orderItemsData.map(item => ({ ...item, orderId: newOrder.id }));

    console.log('Creating order items:', orderItemsWithOrderId);

    // Batch create order items
    await prisma.orderItem.createMany({ data: orderItemsWithOrderId });

    console.log('Order creation completed successfully');

    return res.status(201).json({
      success: true,
      order: newOrder,
      orderItems: orderItemsWithOrderId
    });
  } catch (error) {
    console.error('[Optimized] Error creating order:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to create order (optimized)',
      details: error.message
    });
  }
};

// Get orders with pagination
const getOrders = async (req, res) => {
  const salesRepId = req.user.id;
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  try {
    // Get total count for pagination
    const total = await prisma.myOrder.count({
      where: { userId: salesRepId },
    });

    // Get orders with pagination and order items
    const orders = await prisma.myOrder.findMany({
      where: { userId: salesRepId },
      skip,
      take: limit,
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        orderItems: {
          include: {
            product: true,
          },
        },
        client: true,
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true,
          },
        },
      },
    });

    const totalPages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: orders,
      page,
      limit,
      total,
      totalPages,
    });
  } catch (error) {
    console.error('Error fetching orders:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch orders',
    });
  }
};


// Update order (updating order items)
const updateOrder = async (req, res) => {
  const { id } = req.params;
  const { orderItems } = req.body;
  const salesRepId = req.user.id;

  try {
    // Validate the order exists and belongs to the sales rep
    const existingOrder = await prisma.myOrder.findFirst({
      where: {
        id: parseInt(id),
        userId: salesRepId,
      },
    });

    if (!existingOrder) {
      return res.status(404).json({
        success: false,
        error: 'Order not found or unauthorized',
      });
    }

    // Ensure each order item has productId and quantity
    if (!orderItems || orderItems.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Missing orderItems in the request body',
      });
    }

    for (const item of orderItems) {
      if (!item.productId || !item.quantity) {
        return res.status(400).json({
          success: false,
          error: 'Each order item must have productId and quantity',
        });
      }

      // Check if the order already has an item for the product
      const existingOrderItem = await prisma.orderItem.findFirst({
        where: {
          orderId: existingOrder.id,
          productId: item.productId,
        },
      });

      if (existingOrderItem) {
        // Update the existing order item if it already exists
        await prisma.orderItem.update({
          where: { id: existingOrderItem.id },
          data: { quantity: item.quantity },
        });
      } else {
        // Create a new order item if it doesn't exist
        const newOrderItem = await prisma.orderItem.create({
          data: {
            productId: item.productId,
            quantity: item.quantity,
          },
        });
        
        // Connect the new order item to the order
        await prisma.myOrder.update({
          where: { id: existingOrder.id },
          data: {
            orderItems: {
              connect: { id: newOrderItem.id }
            }
          }
        });
      }
    }

    const updatedOrder = await prisma.myOrder.findUnique({
      where: { id: existingOrder.id },
      include: {
        orderItems: {
          include: {
            product: true,
          },
        },
        client: true,
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: updatedOrder,
    });
  } catch (error) {
    console.error('Error updating order:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update order',
    });
  }
};

// Delete order
const deleteOrder = async (req, res) => {
  try {
    const orderId = parseInt(req.params.id);
    const salesRepId = req.user.id;

    console.log(`[DELETE] Processing request - Order: ${orderId}, SalesRep: ${salesRepId}`);

    if (isNaN(orderId)) {
      console.log('[ERROR] Invalid order ID format');
      return res.status(400).json({
        success: false,
        error: 'Invalid order ID format'
      });
    }

    // First find the order with a single query including relations
    const existingOrder = await prisma.myOrder.findFirst({
      where: {
        id: orderId,
        userId: salesRepId,
      },
      include: {
        orderItems: true
      }
    });

    if (!existingOrder) {
      console.log(`[ERROR] Order ${orderId} not found or not owned by sales rep ${salesRepId}`);
      return res.status(404).json({
        success: false,
        error: 'Order not found'
      });
    }

    // Delete order in a transaction to ensure consistency
    await prisma.$transaction(async (tx) => {
      // Delete order items first by disconnecting them
      if (existingOrder.orderItems.length > 0) {
        await tx.myOrder.update({
          where: { id: orderId },
          data: {
            orderItems: {
              disconnect: existingOrder.orderItems.map(item => ({ id: item.id }))
            }
          }
        });
      }

      // Then delete the order
      await tx.myOrder.delete({
        where: { id: orderId }
      });
    });

    console.log(`[SUCCESS] Order ${orderId} deleted successfully`);
    return res.status(200).json({
      success: true,
      message: 'Order deleted successfully'
    });

  } catch (error) {
    console.error('[ERROR] Failed to delete order:', error);
    return res.status(500).json({
      success: false,
      error: 'Failed to delete order'
    });
  }
};

// Get total items sold by the current user (optionally within a date range)
const getUserSalesSummary = async (req, res) => {
  const salesRepId = req.user.id;
  // Optional: filter by last N days
  const { days } = req.query;
  let dateFilter = {};
  if (days) {
    const sinceDate = new Date();
    sinceDate.setDate(sinceDate.getDate() - parseInt(days));
    dateFilter = { gte: sinceDate };
  }

  try {
    // Get all orders for the user (optionally within date range)
    const orders = await prisma.myOrder.findMany({
      where: {
        userId: salesRepId,
        ...(dateFilter.gte ? { createdAt: dateFilter } : {})
      },
      select: { id: true }
    });
    const orderIds = orders.map(o => o.id);

    // Aggregate total quantity from order items
    const totalItems = await prisma.orderItem.aggregate({
      where: { orderId: { in: orderIds } },
      _sum: { quantity: true }
    });

    // Optionally, return recent orders as well
    const recentOrders = await prisma.myOrder.findMany({
      where: { userId: salesRepId },
      orderBy: { createdAt: 'desc' },
      take: 10,
      include: {
        orderItems: true,
        client: true
      }
    });

    res.json({
      success: true,
      totalItemsSold: totalItems._sum.quantity || 0,
      recentOrders
    });
  } catch (error) {
    console.error('Error aggregating user sales:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to aggregate user sales'
    });
  }
};

module.exports = { 
  createOrder, 
  getOrders, 
  updateOrder, 
  deleteOrder, 
  createOrderOptimized,
  getUserSalesSummary
};
