-- CreateTable
CREATE TABLE `SalesRep` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `email` VARCHAR(191) NOT NULL,
    `phoneNumber` VARCHAR(191) NOT NULL,
    `password` VARCHAR(191) NOT NULL,
    `countryId` INTEGER NOT NULL,
    `region_id` INTEGER NOT NULL,
    `region` VARCHAR(191) NOT NULL,
    `role` VARCHAR(191) NULL DEFAULT 'USER',
    `status` INTEGER NULL DEFAULT 0,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `photoUrl` VARCHAR(191) NULL DEFAULT '',

    UNIQUE INDEX `SalesRep_email_key`(`email`),
    UNIQUE INDEX `SalesRep_phoneNumber_key`(`phoneNumber`),
    INDEX `SalesRep_countryId_fkey`(`countryId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `managers` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` INTEGER NOT NULL,
    `department` VARCHAR(191) NULL,

    UNIQUE INDEX `managers_userId_key`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Token` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `token` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `expiresAt` DATETIME(3) NOT NULL,
    `salesRepId` INTEGER NOT NULL,

    INDEX `Token_userId_fkey`(`salesRepId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Regions` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `status` INTEGER NULL DEFAULT 0,
    `countryId` INTEGER NOT NULL,

    INDEX `Regions_countryId_fkey`(`countryId`),
    UNIQUE INDEX `Regions_name_countryId_key`(`name`, `countryId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Country` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `status` INTEGER NULL DEFAULT 0,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Product` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `category` VARCHAR(191) NOT NULL,
    `category_id` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `description` VARCHAR(191) NULL,
    `updatedAt` DATETIME(3) NOT NULL,
    `image` VARCHAR(191) NULL DEFAULT '',
    `clientId` INTEGER NULL,

    INDEX `Product_clientId_fkey`(`clientId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Category` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PriceOption` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `option` VARCHAR(191) NOT NULL,
    `value` INTEGER NOT NULL,
    `categoryId` INTEGER NOT NULL,

    INDEX `PriceOption_categoryId_fkey`(`categoryId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `StoreQuantity` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `quantity` INTEGER NOT NULL,
    `storeId` INTEGER NOT NULL,
    `productId` INTEGER NOT NULL,

    INDEX `StoreQuantity_productId_fkey`(`productId`),
    INDEX `StoreQuantity_storeId_fkey`(`storeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Stores` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `regionId` INTEGER NOT NULL,

    INDEX `Stores_regionId_fkey`(`regionId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Purchase` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `productId` INTEGER NOT NULL,
    `storeId` INTEGER NOT NULL,
    `quantity` INTEGER NOT NULL,
    `totalPrice` INTEGER NOT NULL,
    `date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `Purchase_productId_fkey`(`productId`),
    INDEX `Purchase_storeId_fkey`(`storeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `PurchaseHistory` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `storeId` INTEGER NOT NULL,
    `productId` INTEGER NOT NULL,
    `previousQuantity` INTEGER NOT NULL,
    `purchaseQuantity` INTEGER NOT NULL,
    `newBalance` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    INDEX `PurchaseHistory_productId_fkey`(`productId`),
    INDEX `PurchaseHistory_storeId_fkey`(`storeId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Clients` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `region_id` INTEGER NOT NULL,
    `region` VARCHAR(191) NOT NULL,
    `contact` VARCHAR(191) NOT NULL,
    `tax_pin` VARCHAR(191) NOT NULL,
    `location` VARCHAR(191) NOT NULL,
    `status` INTEGER NOT NULL DEFAULT 0,
    `countryId` INTEGER NOT NULL,
    `client_type` INTEGER NULL,
    `address` VARCHAR(191) NULL,
    `balance` VARCHAR(191) NULL,
    `email` VARCHAR(191) NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,

    INDEX `Clients_countryId_fkey`(`countryId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ClientPayment` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `clientId` INTEGER NOT NULL,
    `amount` DOUBLE NOT NULL,
    `imageUrl` VARCHAR(191) NULL,
    `date` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `status` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Riders` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `status` INTEGER NULL,
    `company` VARCHAR(191) NOT NULL,
    `company_id` INTEGER NOT NULL,
    `contact` VARCHAR(191) NOT NULL,
    `id_number` VARCHAR(191) NOT NULL,
    `device_id` VARCHAR(191) NULL,
    `device_name` VARCHAR(191) NULL,
    `device_status` VARCHAR(191) NULL,
    `password` VARCHAR(191) NULL,
    `token` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `RidersCompany` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `status` INTEGER NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ManagerCheckin` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `managerId` INTEGER NOT NULL,
    `date` DATETIME(3) NOT NULL,
    `checkInAt` DATETIME(3) NULL,
    `checkOutAt` DATETIME(3) NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `checkoutLatitude` DOUBLE NULL,
    `checkoutLongitude` DOUBLE NULL,
    `status` VARCHAR(191) NULL,
    `notes` VARCHAR(191) NULL,
    `imageUrl` VARCHAR(191) NULL,
    `visitNumber` INTEGER NULL,
    `visitDuration` INTEGER NULL,
    `timezone` VARCHAR(191) NULL,
    `clientId` INTEGER NOT NULL,

    INDEX `ManagerCheckin_managerId_idx`(`managerId`),
    INDEX `ManagerCheckin_clientId_idx`(`clientId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `MyOrder` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `totalAmount` DOUBLE NOT NULL,
    `comment` VARCHAR(191) NOT NULL,
    `customerId` VARCHAR(191) NOT NULL,
    `orderDate` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `riderId` INTEGER NULL,
    `riderName` VARCHAR(191) NULL,
    `status` INTEGER NOT NULL DEFAULT 0,
    `approvedTime` VARCHAR(191) NULL,
    `dispatchTime` VARCHAR(191) NULL,
    `deliveryLocation` VARCHAR(191) NULL,
    `customerName` VARCHAR(191) NOT NULL,
    `customerType` VARCHAR(191) NOT NULL,
    `complete_address` VARCHAR(191) NULL,
    `complete_latitude` VARCHAR(191) NULL,
    `complete_longitude` VARCHAR(191) NULL,
    `deliveryTime` VARCHAR(191) NULL,
    `cancel_reason` VARCHAR(191) NULL,
    `pickupTime` VARCHAR(191) NULL,
    `recepient` VARCHAR(191) NULL,
    `clientId` INTEGER NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `userId` INTEGER NOT NULL,

    INDEX `MyOrder_userId_idx`(`userId`),
    INDEX `MyOrder_clientId_idx`(`clientId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `OrderItem` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `productId` INTEGER NOT NULL,
    `quantity` INTEGER NOT NULL,
    `orderId` INTEGER NOT NULL,
    `priceOptionId` INTEGER NULL,

    INDEX `OrderItem_orderId_idx`(`orderId`),
    INDEX `OrderItem_priceOptionId_idx`(`priceOptionId`),
    INDEX `OrderItem_productId_fkey`(`productId`),
    UNIQUE INDEX `OrderItem_orderId_productId_priceOptionId_key`(`orderId`, `productId`, `priceOptionId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `JourneyPlan` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `date` DATETIME(3) NOT NULL,
    `time` VARCHAR(191) NOT NULL,
    `userId` INTEGER NULL,
    `status` INTEGER NOT NULL DEFAULT 0,
    `checkInTime` DATETIME(3) NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `imageUrl` VARCHAR(191) NULL,
    `notes` VARCHAR(191) NULL,
    `checkoutLatitude` DOUBLE NULL,
    `checkoutLongitude` DOUBLE NULL,
    `checkoutTime` DATETIME(3) NULL,
    `clientId` INTEGER NOT NULL,

    INDEX `JourneyPlan_clientId_idx`(`clientId`),
    INDEX `JourneyPlan_userId_idx`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `NoticeBoard` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(191) NOT NULL,
    `content` VARCHAR(191) NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Report` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `orderId` INTEGER NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `userId` INTEGER NOT NULL,
    `journeyPlanId` INTEGER NULL,
    `type` ENUM('PRODUCT_AVAILABILITY', 'VISIBILITY_ACTIVITY', 'FEEDBACK') NOT NULL,
    `clientId` INTEGER NOT NULL,

    INDEX `Report_clientId_idx`(`clientId`),
    INDEX `Report_journeyPlanId_fkey`(`journeyPlanId`),
    INDEX `Report_orderId_fkey`(`orderId`),
    INDEX `Report_userId_fkey`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `FeedbackReport` (
    `reportId` INTEGER NOT NULL,
    `comment` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`reportId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `ProductReport` (
    `reportId` INTEGER NOT NULL,
    `productName` VARCHAR(191) NULL,
    `quantity` INTEGER NULL,
    `comment` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`reportId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `VisibilityReport` (
    `reportId` INTEGER NOT NULL,
    `comment` VARCHAR(191) NULL,
    `imageUrl` VARCHAR(191) NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    PRIMARY KEY (`reportId`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `leaves` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `userId` INTEGER NOT NULL,
    `leaveType` VARCHAR(191) NOT NULL,
    `startDate` DATETIME(3) NOT NULL,
    `endDate` DATETIME(3) NOT NULL,
    `reason` VARCHAR(191) NOT NULL,
    `attachment` VARCHAR(191) NULL,
    `status` VARCHAR(191) NOT NULL DEFAULT 'PENDING',
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,

    INDEX `leaves_userId_fkey`(`userId`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `Outlet` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(191) NOT NULL,
    `address` VARCHAR(191) NOT NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `balance` VARCHAR(191) NULL,
    `email` VARCHAR(191) NULL,
    `kraPin` VARCHAR(191) NULL,
    `phone` VARCHAR(191) NULL,

    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `sales` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `productId` INTEGER NOT NULL,
    `quantity` INTEGER NOT NULL,
    `unitPrice` DOUBLE NOT NULL,
    `total` DOUBLE NOT NULL,
    `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updatedAt` DATETIME(3) NOT NULL,
    `clientId` INTEGER NULL,
    `createdBy` INTEGER NOT NULL,
    `isLocked` BOOLEAN NOT NULL DEFAULT false,
    `status` VARCHAR(191) NOT NULL DEFAULT 'pending',

    INDEX `sales_productId_idx`(`productId`),
    INDEX `sales_clientId_idx`(`clientId`),
    INDEX `sales_createdBy_idx`(`createdBy`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `_MyOrderToReport` (
    `A` INTEGER NOT NULL,
    `B` INTEGER NOT NULL,

    UNIQUE INDEX `_MyOrderToReport_AB_unique`(`A`, `B`),
    INDEX `_MyOrderToReport_B_index`(`B`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `SalesRep` ADD CONSTRAINT `SalesRep_countryId_fkey` FOREIGN KEY (`countryId`) REFERENCES `Country`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `managers` ADD CONSTRAINT `managers_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `SalesRep`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Token` ADD CONSTRAINT `Token_salesRepId_fkey` FOREIGN KEY (`salesRepId`) REFERENCES `SalesRep`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Regions` ADD CONSTRAINT `Regions_countryId_fkey` FOREIGN KEY (`countryId`) REFERENCES `Country`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Product` ADD CONSTRAINT `Product_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PriceOption` ADD CONSTRAINT `PriceOption_categoryId_fkey` FOREIGN KEY (`categoryId`) REFERENCES `Category`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `StoreQuantity` ADD CONSTRAINT `StoreQuantity_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `Product`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `StoreQuantity` ADD CONSTRAINT `StoreQuantity_storeId_fkey` FOREIGN KEY (`storeId`) REFERENCES `Stores`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Stores` ADD CONSTRAINT `Stores_regionId_fkey` FOREIGN KEY (`regionId`) REFERENCES `Regions`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Purchase` ADD CONSTRAINT `Purchase_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `Product`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Purchase` ADD CONSTRAINT `Purchase_storeId_fkey` FOREIGN KEY (`storeId`) REFERENCES `Stores`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PurchaseHistory` ADD CONSTRAINT `PurchaseHistory_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `Product`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `PurchaseHistory` ADD CONSTRAINT `PurchaseHistory_storeId_fkey` FOREIGN KEY (`storeId`) REFERENCES `Stores`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Clients` ADD CONSTRAINT `Clients_countryId_fkey` FOREIGN KEY (`countryId`) REFERENCES `Country`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ClientPayment` ADD CONSTRAINT `ClientPayment_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ManagerCheckin` ADD CONSTRAINT `ManagerCheckin_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ManagerCheckin` ADD CONSTRAINT `ManagerCheckin_managerId_fkey` FOREIGN KEY (`managerId`) REFERENCES `managers`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MyOrder` ADD CONSTRAINT `MyOrder_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `MyOrder` ADD CONSTRAINT `MyOrder_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `SalesRep`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OrderItem` ADD CONSTRAINT `OrderItem_orderId_fkey` FOREIGN KEY (`orderId`) REFERENCES `MyOrder`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OrderItem` ADD CONSTRAINT `OrderItem_priceOptionId_fkey` FOREIGN KEY (`priceOptionId`) REFERENCES `PriceOption`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `OrderItem` ADD CONSTRAINT `OrderItem_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `Product`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `JourneyPlan` ADD CONSTRAINT `JourneyPlan_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `JourneyPlan` ADD CONSTRAINT `JourneyPlan_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `SalesRep`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Report` ADD CONSTRAINT `Report_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Report` ADD CONSTRAINT `Report_journeyPlanId_fkey` FOREIGN KEY (`journeyPlanId`) REFERENCES `JourneyPlan`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `Report` ADD CONSTRAINT `Report_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `SalesRep`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `FeedbackReport` ADD CONSTRAINT `FeedbackReport_reportId_fkey` FOREIGN KEY (`reportId`) REFERENCES `Report`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ProductReport` ADD CONSTRAINT `ProductReport_reportId_fkey` FOREIGN KEY (`reportId`) REFERENCES `Report`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `VisibilityReport` ADD CONSTRAINT `VisibilityReport_reportId_fkey` FOREIGN KEY (`reportId`) REFERENCES `Report`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `leaves` ADD CONSTRAINT `leaves_userId_fkey` FOREIGN KEY (`userId`) REFERENCES `SalesRep`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `sales` ADD CONSTRAINT `sales_productId_fkey` FOREIGN KEY (`productId`) REFERENCES `Product`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `sales` ADD CONSTRAINT `sales_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `sales` ADD CONSTRAINT `sales_createdBy_fkey` FOREIGN KEY (`createdBy`) REFERENCES `SalesRep`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_MyOrderToReport` ADD CONSTRAINT `_MyOrderToReport_A_fkey` FOREIGN KEY (`A`) REFERENCES `MyOrder`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `_MyOrderToReport` ADD CONSTRAINT `_MyOrderToReport_B_fkey` FOREIGN KEY (`B`) REFERENCES `Report`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
