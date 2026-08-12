import { HealthController } from '../src/health.controller';

describe('HealthController', () => {
  it('reports the backend service as healthy', () => {
    expect(new HealthController().getHealth()).toEqual({
      status: 'ok',
      service: 'chowk-backend',
    });
  });
});