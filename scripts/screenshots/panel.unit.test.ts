import { describe, expect, test } from 'bun:test'
import { PANEL_HEIGHT, PANEL_WIDTH, panelHtml } from './panel'

describe('panelHtml', () => {
  const html = panelHtml({
    caption: 'Tout ce que vous possédez,\nrangé par lieu',
    subtitle: 'Filtrez par catégorie, cherchez un nom.',
    screenshotPath: '/tmp/items.png',
  })

  test('renders at the 6.5-inch size the App Store listing uses', () => {
    expect(PANEL_WIDTH).toBe(1242)
    expect(PANEL_HEIGHT).toBe(2688)
    expect(html).toContain('width: 1242px')
    expect(html).toContain('height: 2688px')
  })

  test('turns the newline of a caption into a line break', () => {
    expect(html).toContain('Tout ce que vous possédez,<br>rangé par lieu')
  })

  test('points at the screenshot as a file URL', () => {
    expect(html).toContain('src="file:///tmp/items.png"')
  })

  test('gives the text block a fixed height so every screen starts at the same offset', () => {
    expect(html).toContain('height: 26%')
    expect(html).toContain('height: 74%')
  })

  test('leaves the corners square, since a store screenshot is a plain rectangle', () => {
    expect(html).not.toContain('body { border-radius')
  })

  test('escapes copy that would otherwise break out of the markup', () => {
    const risky = panelHtml({
      caption: 'Outils & <boîtes>',
      subtitle: '"cave"',
      screenshotPath: '/tmp/a.png',
    })
    expect(risky).toContain('Outils &amp; &lt;boîtes&gt;')
    expect(risky).toContain('&quot;cave&quot;')
  })
})
