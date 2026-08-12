import { config } from 'dotenv';
import { PrismaClient } from '@prisma/client';
import * as argon2 from 'argon2';

config({ path: '.env.local' });
const prisma = new PrismaClient();

async function main(): Promise<void> {
  const email = process.env.ADMIN_EMAIL ?? 'admin@chowk.local';
  const password = process.env.ADMIN_PASSWORD ?? 'Chowk@12345';
  const name = process.env.ADMIN_NAME ?? 'Chowk Admin';

  await prisma.user.upsert({
    where: { email },
    update: {
      name,
      role: 'admin',
      isActive: true,
      passwordHash: await argon2.hash(password),
    },
    create: {
      name,
      email,
      passwordHash: await argon2.hash(password),
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

  console.log(`Development admin ready: ${email}`);
  console.log(`Development super admin ready: ${superAdminEmail}`);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());