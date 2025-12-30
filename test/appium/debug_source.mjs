import { remote } from 'webdriverio';
import { homedir } from 'os';

const ANDROID_HOME = `${homedir()}/Library/Android/sdk`;
process.env.ANDROID_HOME = ANDROID_HOME;
process.env.ANDROID_SDK_ROOT = ANDROID_HOME;

async function main() {
    console.log('Starting Appium session...');

    const driver = await remote({
        hostname: '127.0.0.1',
        port: 4723,
        path: '/',
        capabilities: {
            platformName: 'Android',
            'appium:automationName': 'UiAutomator2',
            'appium:app': '/Users/higherway/projects/flutter-appium/build/app/outputs/flutter-apk/app-debug.apk',
            'appium:deviceName': 'Android Emulator',
            'appium:noReset': true,
            'appium:newCommandTimeout': 120
        },
        logLevel: 'warn'
    });

    console.log('Session started, waiting for app to load...');
    await driver.pause(8000);

    console.log('Getting page source...');
    const source = await driver.getPageSource();
    console.log('\n=== PAGE SOURCE ===\n');
    console.log(source);

    await driver.deleteSession();
    console.log('Session closed');
}

main().catch(err => {
    console.error('Error:', err.message);
    process.exit(1);
});
