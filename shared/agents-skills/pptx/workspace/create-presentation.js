const pptxgen = require('pptxgenjs');
const html2pptx = require('../scripts/html2pptx');
const path = require('path');

async function createPresentation() {
    const pptx = new pptxgen();
    pptx.layout = 'LAYOUT_16x9';
    pptx.author = 'AI Business Analysis Team';
    pptx.title = '抖音AI赋能项目 - 业务价值与风险分析';

    const workDir = __dirname;

    // Slide 1: Cover
    await html2pptx(path.join(workDir, 'slide1-cover.html'), pptx);

    // Slide 2: Business Directions
    await html2pptx(path.join(workDir, 'slide2-business.html'), pptx);

    // Slide 3: Core Values
    await html2pptx(path.join(workDir, 'slide3-values.html'), pptx);

    // Slide 4: Pain Points
    await html2pptx(path.join(workDir, 'slide4-pains.html'), pptx);

    // Slide 5: Risk Matrix
    await html2pptx(path.join(workDir, 'slide5-risk.html'), pptx);

    // Slide 6: Timeline
    await html2pptx(path.join(workDir, 'slide6-timeline.html'), pptx);

    // Slide 7: Revenue
    await html2pptx(path.join(workDir, 'slide7-revenue.html'), pptx);

    // Save presentation
    const outputPath = '/Users/mac-minishu/Documents/【3】Obsidian/Obsidian Work/商业孵化/【7】抖音 AI 赋能/AI陪伴产品商业分析报告.pptx';
    await pptx.writeFile({ fileName: outputPath });
    console.log('✓ Presentation created:', outputPath);
}

createPresentation().catch(console.error);