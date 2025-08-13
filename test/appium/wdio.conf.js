export const config = {
    runner: 'local',
    port: 4723,
    specs: [
        './specs/**/*.spec.js'
    ],
    capabilities: [{
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:app': '../../build/app/outputs/flutter-apk/app-release.apk',
        'appium:deviceName': 'Android Emulator',
        'appium:noReset': false
    }],
    logLevel: 'info',
    bail: 0,
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    }
};
