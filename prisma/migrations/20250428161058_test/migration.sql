/*
  Warnings:

  - Added the required column `regionId` to the `Stores` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE `ManagerCheckin` ADD COLUMN `checkoutLatitude` DOUBLE NULL,
    ADD COLUMN `checkoutLongitude` DOUBLE NULL,
    ADD COLUMN `imageUrl` VARCHAR(191) NULL,
    ADD COLUMN `status` VARCHAR(191) NULL,
    ADD COLUMN `timezone` VARCHAR(191) NULL,
    ADD COLUMN `visitDuration` INTEGER NULL,
    ADD COLUMN `visitNumber` INTEGER NULL;

-- AlterTable
ALTER TABLE `Stores` ADD COLUMN `regionId` INTEGER NOT NULL;

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

-- CreateIndex
CREATE INDEX `Stores_regionId_fkey` ON `Stores`(`regionId`);

-- AddForeignKey
ALTER TABLE `Stores` ADD CONSTRAINT `Stores_regionId_fkey` FOREIGN KEY (`regionId`) REFERENCES `Regions`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `ClientPayment` ADD CONSTRAINT `ClientPayment_clientId_fkey` FOREIGN KEY (`clientId`) REFERENCES `Clients`(`id`) ON DELETE RESTRICT ON UPDATE CASCADE;
