import { AuthService } from '../src/auth/auth.service';
import { AdminService } from '../src/admin/admin.service';
import * as argon2 from 'argon2';

jest.mock('argon2', () => ({
  hash: jest.fn().mockResolvedValue('hashed-password'),
  verify: jest.fn().mockResolvedValue(true),
}));

describe('role assignment flow', () => {
  const mockPrisma = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    refreshToken: {
      create: jest.fn(),
      findUnique: jest.fn(),
      delete: jest.fn(),
    },
  } as any;

  const jwt = { signAsync: jest.fn().mockResolvedValue('token') } as any;
  const config = { getOrThrow: jest.fn().mockReturnValue('secret') } as any;

  beforeEach(() => {
    jest.clearAllMocks();
    (argon2.hash as jest.Mock).mockResolvedValue('hashed-password');
    (argon2.verify as jest.Mock).mockResolvedValue(true);
  });

  it('assigns the subscriber role for public registration', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(null);
    mockPrisma.user.create.mockResolvedValue({ id: 42, name: 'Alice', email: 'alice@example.com', role: 'subscriber', city: null, state: null });
    mockPrisma.user.update.mockResolvedValue({ id: 42, name: 'Alice', email: 'alice@example.com', role: 'subscriber', city: null, state: null, userCode: 'USER00042' });
    mockPrisma.refreshToken.create.mockResolvedValue({});

    const service = new AuthService(mockPrisma, jwt, config);
    const result = await service.register({ name: 'Alice', email: 'Alice@example.com', password: 'password123', city: '', state: '' } as any);

    expect(mockPrisma.user.create).toHaveBeenCalledWith(expect.objectContaining({ data: expect.objectContaining({ role: 'subscriber' }) }));
    expect(result.user.role).toBe('subscriber');
  });

  it('allows admins to create users with publisher and moderator roles', async () => {
    const service = new AdminService(mockPrisma);

    mockPrisma.user.findUnique.mockResolvedValue(null);
    mockPrisma.user.create.mockResolvedValue({ id: 43, name: 'Bob', email: 'bob@example.com', role: 'publisher', city: null, state: null });
    mockPrisma.user.update.mockResolvedValue({ id: 43, name: 'Bob', email: 'bob@example.com', role: 'publisher', city: null, state: null, userCode: 'USER00043' });

    const publisherResult = await service.createUser({ name: 'Bob', email: 'bob@example.com', password: 'password123', role: 'publisher' });
    expect(publisherResult.data.role).toBe('publisher');

    mockPrisma.user.findUnique.mockResolvedValue(null);
    mockPrisma.user.create.mockResolvedValue({ id: 44, name: 'Cathy', email: 'cathy@example.com', role: 'moderator', city: null, state: null });
    mockPrisma.user.update.mockResolvedValue({ id: 44, name: 'Cathy', email: 'cathy@example.com', role: 'moderator', city: null, state: null, userCode: 'USER00044' });

    const moderatorResult = await service.createUser({ name: 'Cathy', email: 'cathy@example.com', password: 'password123', role: 'moderator' });
    expect(moderatorResult.data.role).toBe('moderator');
  });
});
