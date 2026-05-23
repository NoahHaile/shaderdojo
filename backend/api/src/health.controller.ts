import { Controller, Get } from '@nestjs/common';

@Controller()
export class HealthController {
    @Get('health')
    health(): { status: string } { return { status: 'UP' }; }

    /** /actuator/health alias for any tooling still pointed at the Spring path. */
    @Get('actuator/health')
    actuatorHealth(): { status: string } { return { status: 'UP' }; }
}
