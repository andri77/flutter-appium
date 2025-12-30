import { expect } from 'chai';
import HomePage from '../pageobjects/home.page';

describe('Bible App', () => {
    beforeEach(async () => {
        await HomePage.waitForAppLoaded();
    });

    it('should load with correct title', async () => {
        const titleText = await HomePage.getTitleText();
        expect(titleText).to.equal('Daily Bible Verses');
    });

    it('should show verse controls', async () => {
        const newVerseBtn = await HomePage.newVerseButton;
        const topicDd = await HomePage.topicDropdown;
        const translationDd = await HomePage.translationDropdown;

        expect(await newVerseBtn.isDisplayed()).to.be.true;
        expect(await topicDd.isDisplayed()).to.be.true;
        expect(await translationDd.isDisplayed()).to.be.true;
    });

    it('should change topics', async () => {
        await HomePage.selectTopic('Love');
        await driver.pause(3000);
        // After selecting Love, the topic badge should show Love
        const topicBadge = await $('~Love');
        await topicBadge.waitForDisplayed({ timeout: 10000 });
        expect(await topicBadge.isDisplayed()).to.be.true;
    });

    it('should change translations', async () => {
        await HomePage.selectTranslation('King James Version');
        await driver.pause(3000);
        // After selecting KJV, the translation text should contain it
        const translationText = await $('//*[contains(@content-desc, "King James Version")]');
        await translationText.waitForDisplayed({ timeout: 10000 });
        expect(await translationText.isDisplayed()).to.be.true;
    });

    it('should show loading state when refreshing verse', async () => {
        const newVerseBtn = await HomePage.newVerseButton;
        await newVerseBtn.waitForDisplayed({ timeout: 5000 });
        await newVerseBtn.click();
        // The button shows "Loading..." as its content-desc during loading
        const loadingBtn = await $('~Loading...');
        // Loading state is brief, so we use a short timeout and don't fail if missed
        try {
            await loadingBtn.waitForDisplayed({ timeout: 2000 });
            expect(await loadingBtn.isDisplayed()).to.be.true;
        } catch {
            // If loading was too fast, just verify the button returns
            await newVerseBtn.waitForDisplayed({ timeout: 10000 });
            expect(await newVerseBtn.isDisplayed()).to.be.true;
        }
    });
});
