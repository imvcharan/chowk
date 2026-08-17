import { resolveRuntimeEnv } from '../src/config/runtime-env';

describe('resolveRuntimeEnv', () => {
  it('copies JWT_SECRET into JWT_ACCESS_SECRET when JWT_ACCESS_SECRET is missing', () => {
    const env = { JWT_SECRET: 'render-secret-value' };

    expect(resolveRuntimeEnv(env)).toMatchObject({
      JWT_SECRET: 'render-secret-value',
      JWT_ACCESS_SECRET: 'render-secret-value',
    });
  });
});
