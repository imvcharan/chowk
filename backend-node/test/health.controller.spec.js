"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const health_controller_1 = require("../src/health.controller");
describe('HealthController', () => {
    it('reports the backend service as healthy', () => {
        expect(new health_controller_1.HealthController().getHealth()).toEqual({
            status: 'ok',
            service: 'chowk-backend',
        });
    });
});
//# sourceMappingURL=health.controller.spec.js.map