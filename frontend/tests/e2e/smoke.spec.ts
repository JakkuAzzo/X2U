import { test, expect } from '@playwright/test';

test.describe('X2U Frontend Smoke', () => {
  test('signup page renders', async ({ page }) => {
    await page.goto('/');

    await expect(page.getByRole('heading', { name: 'Join X2U' })).toBeVisible();
    await expect(page.getByPlaceholder('your@email.com')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Get Started' })).toBeVisible();
  });
});
