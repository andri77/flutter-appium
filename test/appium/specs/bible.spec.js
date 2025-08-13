import { expect } from 'chai';

describe('Bible App', () => {
    it('should load with correct title', async () => {
        // Wait for app to load
        const title = await $('//android.widget.TextView[@text="Daily Bible Verses"]');
        await title.waitForDisplayed({ timeout: 5000 });
        expect(await title.getText()).to.equal('Daily Bible Verses');
    });

    it('should show verse controls', async () => {
        const refreshButton = await $('//android.widget.Button[@text="New Verse"]');
        const topicSelector = await $('//android.widget.Spinner[1]');
        const translationSelector = await $('//android.widget.Spinner[2]');
        
        expect(await refreshButton.isDisplayed()).to.be.true;
        expect(await topicSelector.isDisplayed()).to.be.true;
        expect(await translationSelector.isDisplayed()).to.be.true;
    });

    it('should change topics', async () => {
        // Open topic dropdown
        const topicSelector = await $('//android.widget.Spinner[1]');
        await topicSelector.click();
        
        // Select Love topic
        const loveTopic = await $('//android.widget.TextView[@text="Love"]');
        await loveTopic.click();
        
        // Verify topic badge
        const topicBadge = await $('//android.widget.TextView[@text="Love"]');
        expect(await topicBadge.isDisplayed()).to.be.true;
    });

    it('should change translations', async () => {
        // Open translation dropdown
        const translationSelector = await $('//android.widget.Spinner[2]');
        await translationSelector.click();
        
        // Select KJV
        const kjvOption = await $('//android.widget.TextView[contains(@text, "King James Version")]');
        await kjvOption.click();
        
        // Wait for translation to change
        const translationText = await $('//android.widget.TextView[contains(@text, "King James Version")]');
        expect(await translationText.isDisplayed()).to.be.true;
    });

    it('should show loading state when refreshing verse', async () => {
        const refreshButton = await $('//android.widget.Button[@text="New Verse"]');
        await refreshButton.click();
        
        const loadingText = await $('//android.widget.TextView[@text="Loading..."]');
        expect(await loadingText.isDisplayed()).to.be.true;
    });
});
