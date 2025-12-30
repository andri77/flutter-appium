import { homedir } from 'os';

const ANDROID_HOME = `${homedir()}/Library/Android/sdk`;
process.env.ANDROID_HOME = ANDROID_HOME;
process.env.ANDROID_SDK_ROOT = ANDROID_HOME;
process.env.JAVA_HOME = '/opt/homebrew/opt/openjdk';

export const config = {
    runner: 'local',
    port: 4723,
    specs: [
        './specs/**/*.spec.js'
    ],
    maxInstances: 1,
    capabilities: [{
        platformName: 'Android',
        'appium:automationName': 'UiAutomator2',
        'appium:app': '/Users/higherway/projects/flutter-appium/build/app/outputs/flutter-apk/app-debug.apk',
        'appium:deviceName': 'Android Emulator',
        'appium:noReset': false,
        'appium:newCommandTimeout': 240
    }],
    logLevel: 'info',
    bail: 0,
    waitforTimeout: 10000,
    connectionRetryTimeout: 120000,
    connectionRetryCount: 3,
    services: [
        ['appium', {
            args: {
                relaxedSecurity: true
            }
        }]
    ],
    framework: 'mocha',
    reporters: ['spec'],
    mochaOpts: {
        ui: 'bdd',
        timeout: 60000
    }
};
