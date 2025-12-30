import { expect } from 'chai';
import HomePage from '../pageobjects/home.page';

describe('Bible App Options', () => {
    beforeEach(async () => {
        await HomePage.waitForAppLoaded();
    });

    it('should change bible translation', async () => {
        await HomePage.selectTranslation('English Standard Version');
        await driver.pause(3000);
        const translationText = await HomePage.getTranslationText();
        expect(translationText).to.include('English Standard Version');
    });

    it('should change background', async () => {
        await HomePage.selectBackground('Ocean Sunset');
        await driver.pause(1000);
        // Verify the background dropdown now shows the selected option
        const dropdown = await $('~Ocean Sunset');
        await dropdown.waitForDisplayed({ timeout: 5000 });
        expect(await dropdown.isDisplayed()).to.be.true;
    });
});
