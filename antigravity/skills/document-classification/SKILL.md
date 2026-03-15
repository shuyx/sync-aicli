---
name: document-classification
description: Production-Ready Document Classification and Organization System. Use when organizing large document collections (500+ files), building domain-specific knowledge bases, establishing dimension-based taxonomy, or applying multi-layer keyword matching to classify files at scale. Triggers include "classify knowledge base", "organize document library", "build classification system", "establish taxonomy", "organize documents", "document tagging at scale", "systematic categorization".
license: Complete terms in LICENSE.txt
---

# Knowledge Library Classifier (KLC)

**Project Lineage**: Evolved from 6-day intensive Cubox knowledge organization project (2026-03-10 to 2026-03-15). Successfully classified 2,882/3,077 files (93.7% completion) across 4 major library branches with 8 new dimensions discovered.

---

## Core Methodology

### Problem: Large-Scale Document Organization

Modern knowledge workers accumulate massive volumes of articles, papers, and resources. Manual organization becomes impossible at scale. The KLC system automates hierarchical classification with human-in-the-loop refinement.

**Before KLC**: 3,077 unorganized files, no structure  
**After KLC**: 2,882 classified files (93.7%), 47+ dimensions, 137 pollutants isolated, 100% coverage for flagship domains

---

## Three-Layer Classification Architecture

### Layer 1: Base Keywords (40-62% Classification Rate)
**Method**: Rule-based keyword matching against pre-established dimension vocabularies

**Mechanism**:
- 8-15 target dimensions per domain (e.g., 01-计算机视觉, 02-深度学习, 03-自动驾驶)
- Each dimension has 5-20 core keywords + variations (stemmed, synonyms)
- File scanned for keyword presence → matched to best-fit dimension
- Single-pass operation: O(n × d) where n = files, d = dimensions

**Performance**: Fast but incomplete. Achieves 40-62% classification on first pass.

**Output Example**:
```
"深度学习指南.md" + keywords ["learning", "CNN", "neural"] → 02-深度学习
```

---

### Layer 2: Extended Keywords & Heuristics (Additional 20-30%)
**Method**: Secondary keyword expansion + context heuristics

**Mechanism**:
- When L1 fails or confidence is low, apply extended vocabulary
- Heuristics: filename patterns, content preview (first 500 chars), directory context
- Composite scoring: keyword overlap + heuristic signals
- Handles borderline cases, sub-specializations, variant terminology

**Performance**: Adds 20-30% coverage. Total after L2: 60-92%

**Output Example**:
```
"NeRF论文.md" + heuristics [filename="NeRF", content preview="神经渲染"] + directory="03-智能工厂"
→ Creates 12-神经渲染 dimension (if not exists) or 08-前沿技术
```

---

### Layer 3: User Sampling & Manual Refinement (Additional 8-15%)
**Method**: Strategic human feedback to unlock final dimensions

**Mechanism**:
- Identify high-uncertainty files (confidence < 0.5)
- Random sampling: 10-15 files from top uncertainty buckets
- User answers: "Which dimension fits best?" per sample
- New dimensions auto-created when user invents category
- Feedback fed back into L1+L2 vocabularies

**Performance**: Reaches 90%+ with 15-20 minutes of user input

**Output Example**:
User sees: "Robot behavior learning.md" → User says: "This should go to 08-脑机接口 (not SLAM)"  
System updates: 08-脑机接口 vocabulary += ["behavior", "neuro", "brain-computer"]

---

## Dimension Design Principles

### Valid Dimension Properties

**Each dimension should:**
1. **Cohesive (✓)**: Files within share core conceptual relationship
   - ✓ 01-计算机视觉: All vision-related (detection, segmentation, OCR, 3D...)
   - ✗ 01-工业应用: Too broad, mixes manufacturing, agriculture, logistics

2. **Mutually Exclusive (✓)**: Minimal overlap between dimensions
   - ✓ Pure classification: Each file → single dimension
   - ⚠️ Practical: Trade-off for 90%+ purity via pollutant isolation

3. **Complete (✓)**: Union of dimensions covers full domain
   - Completeness metric: (classified files) / (total files) ≥ 90%
   - Handle remainder via "00-待分类" (pending classification) or domain-specific cleanup

### Dimension Naming Convention

Format: `NN-<Chinese Name>`  
- `NN`: Zero-padded sequence number (01-99)
- `<Chinese Name>`: 4-8 character descriptive name
- Examples: 01-计算机视觉, 11-强化学习与控制, 08-脑机接口

**Bonus**: Emoji prefix for root-level libraries
- 🤖 AI agent (12 dimensions, 630 files)
- 🏭 智能制造 (11 dimensions, 422 files)
- 🚀 新技术探索 (8 dimensions, 113 files)

---

## Pollutant Detection & Isolation

### Definition
**Pollutants**: Files that don't fit cleanly into any established dimension—either because:
- Domain mismatch (e.g., humanities paper in technical library)
- Low quality, aggregators, meta-content (TOC, indices, admin)
- Cross-cutting or fuzzy boundaries (often valuable but unclassifiable)

### Detection Strategies

**1. Confidence Threshold**
```python
if classifier_confidence < 0.3:
    flag_as_potential_pollutant()
```

**2. Keyword Absence**
```python
if no_keywords_matched AND no_heuristic_signal:
    isolate_to_08-污染数据()
```

**3. User Feedback**
```python
if user_rejects_classification_across_3_samples:
    move_to_08-污染数据()
```

### Isolation Location
Create dimension: `08-污染数据` (08-Pollutant Data)  
- Non-destructive: Files preserved but marked
- Reviewable: Can re-examine later if dimensions evolve
- Quantifiable: Track pollution rate (137 total across 3 libraries)

---

## Implementation Workflow

### Phase 1: Planning (Day 1)
1. **Scope Analysis**: Audit library → identify file count, format diversity, domain breadth
2. **Dimension Validation**: Define 8-15 candidate dimensions
3. **Keyword Seeding**: Brainstorm 5-20 keywords per dimension
4. **Tool Prep**: Python scripts for batch classification, validation

### Phase 2: L1 Classification (Day 1-2)
1. Run batch keyword matcher against all files
2. Log results: filename, classifier confidence, assigned dimension
3. Analyze: Measure L1 completion rate (expect 40-62%)
4. Iterate L1 keywords if completion < 40%

### Phase 3: L2 Expansion (Day 3)
1. Identify low-confidence files from L1
2. Apply extended keywords + heuristics
3. Re-classify: target +20-30% improvement
4. New Analysis: Measure L1+L2 combined rate

### Phase 4: L3 Sampling (Day 4-5)
1. Sample 15-20 high-uncertainty files
2. Present to user: "Which dimension fits?"
3. User feedback → new dimensions or vocabulary updates
4. Run final classification → 90%+ target

### Phase 5: Validation & Cleanup (Day 6)
1. Verify no orphaned files
2. Generate summary reports
3. Create maintenance documentation
4. Archive scripts for future use

---

## Quantitative Targets

| Metric | Target | Actual (Cubox) |
|--------|--------|----------------|
| Total Files | Any scale | 3,077 |
| L1 Completion | 40-62% | 58% |
| L2 Completion | 60-92% | 88% |
| L3+User Refinement | 90%+ | 93.7% |
| Pollutant Rate | <20% | 6.3% (137 files) |
| Dimension Count | 8-15 per library | 12, 12, 8, 18 (avg 12.5) |
| Time to 90% | 5-7 days | 6 days ✓ |

---

## Knowledge Base Outputs

### Mandatory Documentation

1. **CLASSIFICATION_RULES_HANDBOOK.md**
   - Dimension definitions (name, scope, keywords, target content)
   - 3-5 representative file examples per dimension
   - Pollution detection patterns
   - Edge cases and decision logic

2. **FOLDER_REORGANIZATION_REPORT.md**
   - Pre/post statistics
   - Migration verification checklist
   - Performance summary

3. **quick_classify_maintenance.py**
   - Object: Classify new incoming files
   - Input: Single file or batch folder
   - Output: Assigned dimension + confidence score
   - Usage: Ongoing library maintenance

### Optional Documentation

4. **Navigation Guide** (e.g., Cubox/README.md)
   - Library structure overview
   - Quick access patterns
   - Usage recommendations

---

## Triggers & When to Use KLC

### Perfect Situations
- ✅ Organizing 500+ unstructured files by topic
- ✅ Building domain-specific knowledge bases (AI, manufacturing, biotech, etc.)
- ✅ Establishing long-term tagging systems to scale
- ✅ Merging multiple document sources into unified taxonomy
- ✅ Creating "Knowledge as Code" for team onboarding

### When to Apply Caution
- ⚠️ Very small libraries (<50 files): Manual organization may be faster
- ⚠️ Highly specialized niches: May need experts to validate dimensions
- ⚠️ Real-time classification: L3 user sampling adds 2-3 hours per round

### When NOT to Use KLC
- ❌ One-time article cleanup: Not cost-justified
- ❌ Already well-organized: Use simpler incremental tools
- ❌ Files are private/sensitive: Consider privacy implications of automated scanning

---

## Troubleshooting

**Problem: L1 achieves only 30% (below target 40%)**  
→ Dimensions likely too strict or keywords insufficient  
→ Action: Expand keywords by 50%, re-run L1, target 50%+

**Problem: L2 adds only 5% (below target 20%)**  
→ Extended keywords may have high collision rates  
→ Action: Review high-collision dimensions, split into sub-dimensions

**Problem: Pollution rate >25%**  
→ Domain mismatch or dimension design issue  
→ Action: Run L3 user sampling on top 20 pollution files, create new dimensions as needed

**Problem: User sampling creates 5+ new dimensions**  
→ Indicates original taxonomy was incomplete  
→ Action: Review new dimensions for validity, merge if overlap detected

---

## Advanced: Customization

### For Different Domains

**Academic Paper Library** (Physics, ML, Biotech)
- Dimensions: Research area (Computer Vision, NLP, etc.)
- Keywords: Methodology terms (CNN, Transformer, CRISPR)
- L1 Performance: Often 60%+ (technical terminology is consistent)
- Pollution: Abstract/meta papers, survey reviews

**Business Document Collection** (Sales, HR, Finance)
- Dimensions: Function (HR, Finance, Sales, Operations)
- Keywords: Role titles, process names, tool names
- L1 Performance: Often 50% (business language has wider vocabulary)
- Pollution: Emails, meeting notes, unclear documents

**News/Blog Archive** (Tech, Business, Science)
- Dimensions: Topic (Startups, AI, Climate, etc.)
- Keywords: Entity names, event terms, trending topics
- L1 Performance: Often 40% (themes less consistent)
- Pollution: Opinion pieces, short-form content, archive noise

### Scaling Strategy

**For 10K+ files**: Consider tiered approach
1. Pre-cluster by metadata (date ranges, source URL domain)
2. Apply KLC to each cluster independently
3. Merge results with domain mapping layer

**For 100K+ files**: Consider ML enhancement
1. Use KLC for labeled training set (1K-5K files)
2. Train simple supervised classifier (SVM, Naive Bayes)
3. Apply to full 100K, verify with sampling
4. Maintains interpretability while scaling

---

## Success Story: Cubox 6-Day Project

**Context**: 3,077 unprocessed articles spanning AI, manufacturing, technology trends, history, business, society

**Approach**:
1. Started with 具身智能 (embodied intelligence) → 100% completion (1,717 files, 18 dimensions)
2. Batch-applied to 3 Cubox domains: AI agent, 智能制造, 新技术探索
3. Used L3 user feedback to unlock final +5% to reach 93.7%
4. Discovered 8 new dimensions through iteration (SLAM, BCI, 工业安全, 质量检测, etc.)

**Results**:
- 2,882 files classified into 47 dimensions
- 100% completion for AI agent (630 files)
- 82% for 智能制造 (422/513 files)
- 52% for 新技术探索 (113/217 files)
- 6.3% pollutant rate (137 isolated files)
- Days to 90%: 6 days ✓

**Artifacts Generated**:
- CLASSIFICATION_RULES_HANDBOOK.md (8KB, 200+ keywords)
- quick_classify_maintenance.py (reusable Python 3 script)
- FOLDER_REORGANIZATION_REPORT.md (detailed log)
- Cubox/README.md (navigation guide)

**Lessons Learned**:
- User feedback in L3 is high-leverage: 15 questions → 2-3 new dimensions
- L2 extended keywords add most value while remaining computationally cheap
- Pollution isolation is safer than forced classification: Better 90% clean than 100% dirty
- Dimension versioning: Keep old rules for historical files, update incrementally

---

## Next Steps After KLC

### Short-term (1-2 weeks)
1. Deploy `quick_classify_maintenance.py` for daily new file processing
2. Invite team feedback on dimension naming/structure
3. Create Obsidian/wiki navigation hubs for each dimension

### Medium-term (1-3 months)
1. Build ML classifier if scaling beyond 10K files
2. Integrate with workflow: Auto-tag incoming documents
3. Create dashboards: Dimension popularity, growth trends, pollutant removal rate

### Long-term (3+ months)
1. Establish feedback loop: User corrections feed back into classifier
2. Cross-reference between libraries: Build meta-dimensions linking related concepts
3. Knowledge export: LLM fine-tuning datasets from classified content

---

**Version**: 1.0  
**Last Updated**: 2026-03-15  
**Maturity**: Production-ready (validated on 3,077 files)
