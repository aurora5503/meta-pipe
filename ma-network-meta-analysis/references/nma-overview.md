# Network Meta-Analysis: When and Why

**Time**: 10 minutes
**Purpose**: Decide whether your research question requires NMA or standard pairwise MA

---

## What is Network Meta-Analysis?

Network meta-analysis (NMA), also called mixed-treatment comparison (MTC), simultaneously compares **three or more treatments** using both:

- **Direct evidence**: Head-to-head comparisons from trials
- **Indirect evidence**: Inferred comparisons through a common comparator

Example: If trials compare A vs B and B vs C, NMA can estimate the A vs C effect indirectly through B.

---

## Decision Criteria

### Use NMA when ALL of these apply:

1. **≥3 distinct treatments** are being compared
2. **Connected network**: At least one path of evidence connects all treatments
3. **Transitivity assumption is plausible**: Study populations, designs, and effect modifiers are sufficiently similar across comparisons
4. **Clinical question demands ranking**: Decision-makers need to know which treatment is "best"

### Use standard pairwise MA when:

1. Only **2 treatments** are compared (intervention vs control)
2. Network would be **disconnected** (isolated treatment comparisons)
3. Treatments are too **heterogeneous** to assume transitivity
4. Research question is about a **single specific comparison**, not ranking

---

## Decision Flowchart

```
How many treatments?
├─ 2 treatments → Standard pairwise MA (ma-meta-analysis)
└─ ≥3 treatments
   ├─ Are all treatments connected? (shared comparators)
   │  ├─ No → Cannot do NMA. Consider separate pairwise MAs
   │  └─ Yes
   │     ├─ Is transitivity plausible?
   │     │  ├─ No → Discuss limitations; consider sensitivity analyses
   │     │  └─ Yes → Network Meta-Analysis (ma-network-meta-analysis)
   │     └─ Do you need treatment rankings?
   │        ├─ Yes → NMA with P-scores
   │        └─ No → NMA still valid for indirect comparisons
```

---

## Key Differences from Pairwise MA

| Aspect | Pairwise MA | Network MA |
|--------|------------|------------|
| Comparisons | A vs B only | A vs B vs C vs D... |
| Evidence | Direct only | Direct + indirect |
| Assumptions | Homogeneity | Homogeneity + transitivity + consistency |
| Key output | Pooled effect (1 comparison) | League table (all pairwise comparisons) |
| Rankings | Not applicable | P-scores, SUCRA |
| Reporting | PRISMA 2020 | PRISMA-NMA extension |
| R package | meta/metafor | netmeta (frequentist) / gemtc (Bayesian) |

---

## The Three NMA Assumptions

### 1. Homogeneity
Same as pairwise MA: studies within each comparison are sufficiently similar.

### 2. Transitivity
Study characteristics that modify the treatment effect are balanced across comparisons. If A vs B studies enroll younger patients than B vs C studies, indirect estimates of A vs C may be biased.

### 3. Consistency
Direct and indirect evidence for the same comparison agree. Tested statistically via node-splitting and design decomposition.

See [nma-assumptions.md](nma-assumptions.md) for detailed assessment methods.

---

## Pipeline Integration

When `analysis_type: nma` is set in `pico.yaml`:

1. **Extraction** (Stage 05): Include `treat1`, `treat2` columns for each comparison
2. **Analysis** (Stage 06): Use `nma_*.R` scripts instead of standard `01-09` scripts
3. **Manuscript** (Stage 07): Report per PRISMA-NMA checklist
4. **QA** (Stage 09): Verify network connectivity, consistency, PRISMA-NMA compliance

---

## Further Reading

- [NMA R Guide](nma-r-guide.md) — Step-by-step netmeta workflow
- [NMA Assumptions](nma-assumptions.md) — How to assess transitivity and consistency
- [NMA Reporting Checklist](nma-reporting-checklist.md) — PRISMA-NMA 32-item checklist
- [Package Comparison](nma-package-comparison.md) — netmeta vs gemtc vs multinma
