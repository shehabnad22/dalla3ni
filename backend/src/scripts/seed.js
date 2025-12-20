require('dotenv').config();
const { sequelize, User, Driver, Order, Review, Settlement } = require('../models');
const { featureFlags } = require('../config/featureFlags');

const AREAS = [
  'وسط البلد', 'جبل عمان', 'جبل الحسين', 'الشميساني',
  'عبدون', 'الرابية', 'خلدا', 'الجبيهة', 'صويلح',
  'طبربور', 'ماركا', 'الهاشمي', 'أبو نصير', 'شفا بدران',
];

const CUSTOMER_NAMES = [
  'محمد أحمد', 'سارة خالد', 'علي حسن', 'فاطمة محمود', 'خالد سعيد',
];

const DRIVER_NAMES = [
  'أحمد محمد', 'محمود سعيد', 'خالد علي', 'عمر حسن', 'يوسف أحمد',
  'حسام الدين', 'طارق محمود', 'نادر خالد', 'باسم علي', 'رامي سعيد',
];

const ORDER_ITEMS = [
  '2 شاورما دجاج + بيبسي كبير من مطعم الشام',
  'بيتزا كبيرة + كوكاكولا من مطعم إيطاليا',
  'وجبة برجر كاملة + بطاطس من ماكدونالدز',
  'سندويشات شاورما + عصير من مطعم الشرق',
  'وجبة دجاج مشوي + سلطة من مطعم الطازج',
  'بيتزا متوسطة + مشروب غازي من دومينوز',
  'سندويش فلافل + حمص من مطعم فلسطين',
  'وجبة كباب + خبز من مطعم الشام',
  'برجر دبل + بطاطس من برجر كنج',
  'سندويشات لحم + مشروب من مطعم اللحوم',
];

async function seedDatabase() {
  try {
    console.log('🌱 Starting database seed...');
    
    // Sync database
    await sequelize.sync({ force: false });
    console.log('✅ Database synced');

    // Create Admin User
    const admin = await User.findOrCreate({
      where: { email: 'admin@dalla3ni.com' },
      defaults: {
        name: 'مدير النظام',
        phone: '0790000000',
        email: 'admin@dalla3ni.com',
        password: 'Admin123!',
        role: 'admin',
        isVerified: true,
        isActive: true,
      },
    });
    console.log('✅ Admin user created');

    // Create 5 Customers
    const customers = [];
    for (let i = 0; i < 5; i++) {
      const customer = await User.findOrCreate({
        where: { phone: `079100000${i}` },
        defaults: {
          name: CUSTOMER_NAMES[i] || `زبون ${i + 1}`,
          phone: `079100000${i}`,
          email: `customer${i + 1}@dalla3ni.app`,
          password: Math.random().toString(36),
          role: 'customer',
          isVerified: true,
          isActive: true,
        },
      });
      customers.push(customer[0]);
    }
    console.log(`✅ Created ${customers.length} customers`);

    // Create 10 Drivers (3 approved, 7 pending)
    const drivers = [];
    for (let i = 0; i < 10; i++) {
      const user = await User.findOrCreate({
        where: { phone: `079200000${i}` },
        defaults: {
          name: DRIVER_NAMES[i] || `سائق ${i + 1}`,
          phone: `079200000${i}`,
          email: `driver${i + 1}@dalla3ni.app`,
          password: Math.random().toString(36),
          role: 'driver',
          isVerified: i < 3, // First 3 verified
          isActive: true,
        },
      });

      const isApproved = i < 3;
      const driver = await Driver.findOrCreate({
        where: { userId: user[0].id },
        defaults: {
          userId: user[0].id,
          idImage: `https://storage.dalla3ni.com/drivers/id_${i + 1}.jpg`,
          motorImage: `https://storage.dalla3ni.com/drivers/bike_${i + 1}.jpg`,
          plateNumber: `${10 + i}-${10000 + i}`,
          bikeModel: i % 2 === 0 ? 'Honda CG 125' : 'Yamaha YBR 125',
          workingAreas: [AREAS[i % AREAS.length], AREAS[(i + 1) % AREAS.length]],
          workStartTime: '08:00:00',
          workEndTime: '22:00:00',
          isApproved,
          isAvailable: isApproved && i % 2 === 0, // Half of approved are online
          accountStatus: isApproved ? 'APPROVED' : 'PENDING_REVIEW',
          rating: isApproved ? (4.0 + Math.random() * 1.0).toFixed(1) : 0,
          totalDeliveries: isApproved ? Math.floor(Math.random() * 100) : 0,
          pendingSettlement: isApproved ? parseFloat((Math.random() * 50).toFixed(2)) : 0,
        },
      });
      drivers.push({ user: user[0], driver: driver[0] });
    }
    console.log(`✅ Created ${drivers.length} drivers (3 approved, 7 pending)`);

    // Create 30 Demo Orders
    const orders = [];
    const statuses = ['REQUESTED', 'ASSIGNED', 'PICKED_UP', 'EN_ROUTE', 'DELIVERED', 'COMPLETED'];
    
    for (let i = 0; i < 30; i++) {
      const customer = customers[Math.floor(Math.random() * customers.length)];
      const status = statuses[Math.floor(Math.random() * statuses.length)];
      const approvedDriver = drivers.find(d => d.driver.isApproved);
      const driverId = (status !== 'REQUESTED' && approvedDriver) ? approvedDriver.driver.id : null;
      
      const order = await Order.create({
        customerId: customer.id,
        driverId,
        itemsText: ORDER_ITEMS[i % ORDER_ITEMS.length],
        estimatedPrice: parseFloat((3 + Math.random() * 10).toFixed(2)),
        deliveryFee: 1.5,
        commissionAmount: featureFlags.commission_amount,
        deliveryCode: Math.floor(1000 + Math.random() * 9000).toString(),
        deliveryAddress: `شارع ${i + 1}، عمارة ${i + 10}، الطابق ${(i % 5) + 1}`,
        pickupAddress: `مطعم ${['الشام', 'إيطاليا', 'الشرق', 'الطازج'][i % 4]}`,
        status,
        invoiceImageUrl: status !== 'REQUESTED' ? `https://storage.dalla3ni.com/invoices/inv_${i + 1}.jpg` : null,
        createdAt: new Date(Date.now() - Math.random() * 7 * 24 * 60 * 60 * 1000), // Random date in last 7 days
      });
      orders.push(order);

      // Add reviews for completed orders
      if (status === 'COMPLETED' && driverId) {
        await Review.create({
          orderId: order.id,
          customerId: customer.id,
          driverId,
          rating: Math.floor(3 + Math.random() * 3), // 3-5
          comment: ['ممتاز', 'جيد', 'مقبول'][Math.floor(Math.random() * 3)],
        });
      }
    }
    console.log(`✅ Created ${orders.length} demo orders`);

    // Create some settlements
    for (let i = 0; i < 5; i++) {
      const driver = drivers.find(d => d.driver.isApproved && d.driver.pendingSettlement > 0);
      if (driver) {
        await Settlement.create({
          driverId: driver.driver.id,
          amount: parseFloat(driver.driver.pendingSettlement.toFixed(2)),
          ordersCount: Math.floor(Math.random() * 10) + 1,
          periodStart: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
          periodEnd: new Date(),
          status: i < 3 ? 'paid' : 'pending',
          paidAt: i < 3 ? new Date() : null,
          paidBy: admin[0].id,
        });
      }
    }
    console.log('✅ Created sample settlements');

    console.log('\n🎉 Database seed completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - Admin: 1`);
    console.log(`   - Customers: ${customers.length}`);
    console.log(`   - Drivers: ${drivers.length} (${drivers.filter(d => d.driver.isApproved).length} approved)`);
    console.log(`   - Orders: ${orders.length}`);
    console.log(`   - Settlements: 5`);
    console.log('\n🔑 Admin credentials:');
    console.log(`   Email: admin@dalla3ni.com`);
    console.log(`   Password: Admin123!`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error);
    process.exit(1);
  }
}

// Run seed
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };

