import Page from './page';

class HomePage extends Page {
    // Flutter uses content-desc for accessibility labels
    get title() {
        return $('~Daily Bible Verses');
    }

    // Translation dropdown shows current value as content-desc
    get translationDropdown() {
        return $('//android.widget.Button[contains(@content-desc, "Version")]');
    }

    // Topic dropdown shows current value (default: "All")
    get topicDropdown() {
        return $('//android.widget.Button[@content-desc="All" or @content-desc="Love" or @content-desc="Faith" or @content-desc="Hope" or @content-desc="Joy" or @content-desc="Health" or @content-desc="Finance" or @content-desc="Miracle" or @content-desc="Gratitude"]');
    }

    // Background dropdown shows current value
    get backgroundDropdown() {
        return $('//android.widget.Button[contains(@content-desc, "Dawn") or contains(@content-desc, "Sunset") or contains(@content-desc, "Path") or contains(@content-desc, "Night") or contains(@content-desc, "Fields") or contains(@content-desc, "Lake") or contains(@content-desc, "Peace") or contains(@content-desc, "Bloom") or contains(@content-desc, "View") or contains(@content-desc, "Stones")]');
    }

    get newVerseButton() {
        return $('~New Verse');
    }

    async waitForAppLoaded() {
        const title = await this.title;
        await title.waitForDisplayed({ timeout: 15000 });
    }

    async selectTranslation(translationName) {
        const dropdown = await this.translationDropdown;
        await dropdown.waitForDisplayed({ timeout: 5000 });
        await dropdown.click();
        await driver.pause(1000);
        const translationOption = await $(`//*[contains(@content-desc, "${translationName}")]`);
        await translationOption.waitForDisplayed({ timeout: 5000 });
        await translationOption.click();
        await driver.pause(500);
    }

    async selectTopic(topicName) {
        const dropdown = await this.topicDropdown;
        await dropdown.waitForDisplayed({ timeout: 5000 });
        await dropdown.click();
        await driver.pause(1000);
        const topicOption = await $(`//*[@content-desc="${topicName}"]`);
        await topicOption.waitForDisplayed({ timeout: 5000 });
        await topicOption.click();
        await driver.pause(500);
    }

    async selectBackground(backgroundName) {
        const dropdown = await this.backgroundDropdown;
        await dropdown.waitForDisplayed({ timeout: 5000 });
        await dropdown.click();
        await driver.pause(1000);
        const backgroundOption = await $(`//*[@content-desc="${backgroundName}"]`);
        await backgroundOption.waitForDisplayed({ timeout: 5000 });
        await backgroundOption.click();
        await driver.pause(500);
    }

    async getVerseText() {
        const verse = await $('//*[starts-with(@content-desc, "\"")]');
        await verse.waitForDisplayed({ timeout: 5000 });
        return verse.getAttribute('content-desc');
    }

    async getTranslationText() {
        const translation = await $('//*[contains(@content-desc, "Version") and @class="android.view.View"]');
        await translation.waitForDisplayed({ timeout: 5000 });
        return translation.getAttribute('content-desc');
    }

    async getTitleText() {
        const titleElement = await this.title;
        await titleElement.waitForDisplayed({ timeout: 5000 });
        return titleElement.getAttribute('content-desc');
    }
}

export default new HomePage();
