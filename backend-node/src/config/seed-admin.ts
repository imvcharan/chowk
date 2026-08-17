import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

export async function ensureDefaultAdmin(prisma: PrismaClient): Promise<void> {
  const adminEmail = process.env.ADMIN_EMAIL ?? 'admin@chowk.local';
  const adminPassword = process.env.ADMIN_PASSWORD ?? 'Chowk@12345';
  const adminName = process.env.ADMIN_NAME ?? 'Chowk Admin';

  await prisma.user.upsert({
    where: { email: adminEmail },
    update: {
      name: adminName,
      role: 'admin',
      isActive: true,
      passwordHash: await argon2.hash(adminPassword),
    },
    create: {
      name: adminName,
      email: adminEmail,
      passwordHash: await argon2.hash(adminPassword),
      role: 'admin',
      isActive: true,
    },
  });

  const superAdminEmail = process.env.SUPERADMIN_EMAIL ?? 'superadmin@enews.com';
  const superAdminPassword = process.env.SUPERADMIN_PASSWORD ?? 'Admin123!';
  const superAdminName = process.env.SUPERADMIN_NAME ?? 'Super Admin';

  await prisma.user.upsert({
    where: { email: superAdminEmail },
    update: {
      name: superAdminName,
      role: 'super_admin',
      isActive: true,
      passwordHash: await argon2.hash(superAdminPassword),
    },
    create: {
      name: superAdminName,
      email: superAdminEmail,
      passwordHash: await argon2.hash(superAdminPassword),
      role: 'super_admin',
      isActive: true,
    },
  });
}
