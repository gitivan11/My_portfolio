# MODULE A — THE REFORMULATION ENGINE (Block 1)

**Version:** v2.4 — Parts 0–6. Use together with the master prompt. Where this module and the master prompt differ on workbook layout or house style, this module prevails (it replaces master §7).

**How to run:** keep this file in the Claude Project next to the master prompt, the course materials and the company documents (folder structure in A0.2). Then send: *"Run Module A on [company], fiscal year T = [year]."*

**What Module A produces:** one Excel calculation workbook, built tab by tab in seven parts that are run in order. Each part uses the output of the part before it.

| Part | Tab | Content | Course basis |
|---|---|---|---|
| 0 | All tabs | Workspace, sources, workflow, workbook house style | Assignment brief; professor's instructions |
| 1 | Reported Financials + Input financials | Figures exactly as reported, with the source of every number | Professor's instructions (extraction) |
| 2 | Reformation & Profitability | Reformulated income statement, rules R1–R11 | Session 2 |
| 3 | Reformation & Profitability | Operating cost structure, rules C1–C5 | Session 3 |
| 4 | Reformation & Profitability | Managerial balance sheet, rules B1–B9 | Session 4 |
| 5 | Reformation & Profitability | ROI and ROE decompositions, rules P0–P8 and E1–E7 | Sessions 5–6 |
| 6 | Reformation & Profitability + Log | Ratio summary, issue log, closing disclosure, chat reply, rules S0–S2 and L1–L3 | Sessions 4–6 thresholds; assignment rules |

**Where the four module components of the assignment are:**

| Component | Where in this module |
|---|---|
| 2. Declared inputs, and stop and ask if missing | A0.2–A0.3 and A1.2 |
| 4. Numbered procedure | A0.4 (workflow), A1.3, and the rules of Parts 2–6 in their order |
| 5. Thresholds and decision rules | Rules R/C/B/P/E; slide thresholds and the material-change screen in A6.2 |
| 7. Prescribed output | A0.5 (house style) and the "Prescribed output" section of every part |

**General rules for every part:**
- **Company-agnostic.** Never hard-code a company, a year or a figure. Everything is derived from the declared documents with the rules below.
- **Formulas, not typed results.** Never type a result where a formula can be used.
- **Printed figures are fixed.** Never change a printed figure to make a check pass.
- **Every number is sourced.** Every row states where its number comes from.
- **Closing statements.** Every part ends with its own closing statement listing what could not be found or verified.
- **Stay in scope.** Module A covers Block 1 only (Sessions 1–6). Do not add Block 2–4 analyses (cash-flow reformulation, KPIs, non-GAAP, valuation) just because more material is in the folder.

---

## MODULE A — PART 0: WORKSPACE, SOURCES, WORKFLOW AND HOUSE STYLE

### A0.1 Purpose
Read this part before any other. It tells you:
- what documents you have and what each may be used for;
- how to work with the supervisor while you work;
- exactly how the workbook must look.

The **supervisor** is the group member running the agent. The aim is that another group can run this module on a different company and get the same workbook structure without asking a single question.

### A0.2 Folder structure and what each folder is for
The workspace (Claude Project or a local project folder) is organised in numbered folders. Use each folder only for its role.

| Folder | What it contains | What you use it for | What you must not do |
|---|---|---|---|
| **1. Instructions & materials** | The group-project instructions (PDF) and the course slide decks, one per session: Session 2 (income statement), Session 3 (operating income / cost structure), Session 4 (balance sheet), Session 5 (ROI), Session 6 (ROE). The professor's written clarifications, if present. | **Methodological authority.** The slides define the structure, the terminology, the subtotals, the formulas and the only thresholds you may apply. Cite the slide number of every rule you apply (e.g. "Session 4 slide 12"). The instructions define scope, deliverables and file names. | Do not take figures from the slides' examples into the company workbook. Do not use a method that is not on the slides or in this prompt. Do not use later sessions' decks for Block 1 outputs. |
| **2. Financials [Company]** | Annual reports for T, T−1 and T−2 (complete: management report, the five primary statements and the notes). Other company documents: results presentations, conference-call transcripts, press releases. | **Factual authority.** Every figure comes from an annual report, quoted with its printed page and note. Other company documents are used only for (a) management's APM and special-items definitions, (b) context for a classification, (c) a figure that the annual report does not contain; in that case its status is "found (other document)". | Never take a figure from a presentation when the annual report has it. Never use memory, training data or outside research. If two documents disagree, do not choose: log the conflict (A0.4) and ask. |
| **3. Prompt** | The master prompt and the module prompts (this file). | **Instructions.** The rules you follow. | Do not change a rule to fit the company. Apply the rule and flag the tension. |
| **4. Clean models** | The empty house-style template (cover page and tab frames), if supplied. | **Layout only.** Copy the frame, fonts and colours. | Never copy figures from a template or from another company's model. |
| **5. Working models** | Earlier versions of the workbook. The group may mark a file "VERIFIED BY SUPERVISOR". | **Input only if the supervisor designates it.** A verified Reported Financials tab is used unchanged. Any figure you read differently is logged, not overwritten. | No other earlier version is a source. |
| **6. TO HAND IN** | Final deliverables: `Gnn_Bk_Agent_vX.md`, `Gnn_Bk_Workbook.xlsx`, `Gnn_Bk_Output.pdf`, `Gnn_Bk_Log.xlsx`, `Gnn_Bk_Note.pdf`. | Where you save the finished workbook, if asked. The progress note and the group's Agent Log are written by the humans. | Never write the progress note. |
| **98. old / 99. inspiration** | Old models and style inspiration. | Ignore, unless the supervisor points you to a file. | — |

**File naming:**
- Working versions: `Financialmodel_[Company]_v[n].xlsx`. Increase n at every delivery; never overwrite an earlier version.
- Final hand-in: `Gnn_B1_Workbook.xlsx`.

### A0.3 Declared inputs and stop rule
**Required:**
- **Course slides** for Sessions 2–6.
- **Annual reports:**
  - T, complete;
  - T−1, complete;
  - T−2, at least the balance sheet and its notes. This is needed for the T−3 balance sheet: opening balances for averages and for the asset schedules.
- **The notes N1–N20 listed in A1.2.**
- **Supervisor inputs:**
  - company name, fiscal year T, group number;
  - whether a verified workbook exists.

**Optional:**
- results presentation and conference call (APM definitions only);
- the house-style template.

**Stop and ask** before starting a part if any of the following is missing:
- a required document;
- a year;
- a note that the stop rule of A1.2 names.

Also stop and ask if two documents give different figures for the same item and neither is a restatement. Say what is missing, where you searched, and which outputs are blocked. Never shorten the period, estimate a figure or fill a blank with zero.

### A0.4 Working procedure with the supervisor (iterative)
1. **Attempt.** Run the parts in order (1 → 6), applying the rules to the declared documents.
2. **Raise conflicts when you meet them, not at the end.**
   - A conflict is information, a classification, a method or a format that is missing, unclear or inconsistent.
   - When you meet one: pause the affected step, open an issue in the Log tab (A6.4), and ask the supervisor in the chat.
   - State the sources, the affected outputs and the decision needed.
   - Continue with the steps that do not depend on the answer.
3. **Apply instructions.** Record the supervisor's instruction and the change made in the Log. Revise the affected rows and everything that depends on them.
4. **Recheck.** Rerun the checks of every part touched. Raise any new conflict the same way.
5. **Deliver.** Save the workbook with a new version number. Report in the chat as prescribed in A6.6.
6. **Unresolved issues.** Any issue still open goes in three places:
   - the Log (status not "Resolved");
   - the closing disclosure;
   - the chat.

**When to proceed alone:** proceed without asking when a result follows directly from a sourced figure and a rule in this prompt. Do not narrate routine steps.

**When not to:**
- Silence is not approval.
- A retry is not permission to resolve a conflict yourself.
- A blocked output stays visibly blocked ("n.d.", "NOT FOUND — searched: …", or "blocked: I-xx"), never a disguised zero.

**Division of work:**
- You extract the figures and write the formulas.
- Excel computes every number.
- You check the results against the controls.
- Anything you interpret is labelled **"Interpretation:"** and kept separate from facts.

### A0.5 Workbook house style (apply exactly, on every tab)
**Tabs, in this order:**
1. `Frontpage`;
2. `Reformation & Profitability`;
3. `Reported Financials`;
4. `Input financials`;
5. `Log`.

The workbook opens on `Reported Financials`, the main input tab.

**Font and colours**

| Element | Rule |
|---|---|
| Font | **Bierstadt** everywhere, never another font. Sizes: tab title 14; section bars and year headers 12; body 10; rule codes, comments and source notes 9. |
| Dark blue (navy) | Hex **002060**. Used for: rows 1–3 of every tab across all used columns; the section bars; the tab colour; sub-header text (bold). |
| Title | Row 3, cell B3: the tab name via the formula `=MID(CELL("filename",B3),FIND("]",CELL("filename",B3))+1,256)`, white, bold, 14. No subtitle and no legend under the title. |
| Section bars | Navy fill across columns B–H, white bold text 12, and a plum **"x"** (hex **89426D**) in column A. Leave one empty row after each bar. |
| Font colour of numbers | **Blue 0000FF** = typed from a report. **Black** = formula in the same tab. **Green 008000** = link to another tab. **Grey 808080 italic** = percentage and margin rows. **Grey 595959 italic 9** = explanations in the comment column. |
| Input cells | Values the supervisor may change (tolerances, balance-sheet basis, material-change factor, rate overrides): blue font on a **yellow FFFF00** fill. |
| Check results | "OK" green fill C6EFCE; "CHECK" red fill FFC7CE; "ALL OK" green; material-change flags orange FCE4D6; results outside a slide threshold red FFC7CE. |
| Gridlines | Off. |

**Frame of every analysis tab (rows 1–9)**
- Rows 1, 2, 4 and 5 have height 12. Row 3 has height 23.25. Rows 1–3 are filled navy across every used column.
- Row 6: the word "Historicals" above the year columns (bold 12).
- Row 7: column B shows the reporting currency and unit, e.g. "(€ million)" (bold 12). The year columns show the fiscal-year labels, e.g. "2022A". The first label is typed; every later one is a formula adding 1 year, with the suffix A for actual. Thin top border.
- Row 8: column B shows "Fiscal year end date". The year columns show the balance-sheet dates (format d-mmm). Medium bottom border.
- Row 7, column C: "Note" (Reported Financials) or "Rule" (Reformation & Profitability).
- Row 7, column J: the header of the comment column.
- Content starts in row 10. Freeze panes at **E9**. Zoom 85%.

**Columns**

| Col | Reported Financials | Input financials | Reformation & Profitability | Width |
|---|---|---|---|---|
| A | "x" marker | "x" marker | "x" marker | 4.86 |
| B | Line as printed | Line | Line (formula stated in the label) | 62–74 |
| C | Note number | Note number | Rule code (R/C/B/P/E/S) | 6–7 |
| D | spacer | spacer | spacer | 2 |
| E | T−3 (balance sheet only) | Source T−3 | T−3 (balance-sheet rows only) | 12.3 (17 in Input financials) |
| F–H | T−2, T−1, T | Sources T−2, T−1, T | T−2, T−1, T | 12.3 (17) |
| I | spacer | spacer | spacer | 3 |
| J | Comment (facts only) | Caption exactly as printed | Where the number comes from / why (course slide) | 70–84 (44) |
| K | margin | Status | margin | 3 (26) |
| M | — | Number ↔ source check | — | 16 |

**Rows**
- **Indentation:** components are indented by two spaces per level directly under their sum line. The sum line is a SUM of its indented lines.
- **Labels:** never write "of which" or "memo:" in Reported Financials.
- **Totals and subtotals:** bold, with thin top and bottom borders across B–H.
- **Sub-headers inside a section:** navy bold text, no fill.
- **Blank rows:** one blank row between blocks.
- **End of tab:**
  - the tab ends with a navy "Checks" bar;
  - the check rows show the difference per year, with OK / CHECK in column J;
  - a navy "Overall status" row returns "ALL OK" or "[n] to check";
  - then a plum "x" and **END** in bold.

**Number formats**
- Amounts: `#,##0_);(#,##0);"-"_)`, i.e. negatives in brackets and zero as "-".
- Percentages: `0.00%;(0.00%);"-"`.
- Multiples: `0.00"x"`.
- Days: one decimal.
- Signs: income and assets are positive; expenses are negative, exactly as printed.

**View and print (every visible tab)**
- The file opens in **Page Break Preview**. The print area runs from A1 to the last used column and row, so only the content is shown.
- Page setup: every tab is fitted to **one single page** (1 page wide × 1 page tall), so page break preview shows the whole tab as one page, with no "Page 2".
  - Long tabs (more than 60 rows) use A3 portrait. Short tabs (Frontpage) use A4 landscape.
  - Margins are 0.4 inch. Excel cannot shrink below 10%, and A3 portrait keeps even the longest tab above that.
- No manual page breaks.

**Frontpage:** navy page showing:
- the company name (large, bold, white);
- "Calculation workbook";
- the university and city;
- "Updated [date]".

No figures.

---

## MODULE A — PART 1: EXTRACTION OF THE REPORTED FINANCIALS

### A1.1 Purpose
Extract the reported figures **exactly as reported** into two tables that match the workbook tabs row for row:
- **Reported Financials** — the numbers;
- **Input financials** — where each number comes from.

This part only extracts. It classifies nothing and computes no ratios; that is Part 2. An extraction error travels through every ratio, so accuracy comes before speed.

### A1.2 Declared inputs
**Documents**
- The annual report for T, complete.
- The annual report for T−1, complete.
- The annual report for T−2: balance sheet and its notes.

**Years:** income statement, OCI and cash flow for T−2, T−1 and T. Balance sheet for T−3, T−2, T−1 and T.

**Where each year comes from:** always take the latest published version of a year.
- T and T−1 come from report T. T−1 is restated if the report says so.
- T−2 comes from report T−1.
- The T−3 balance sheet comes from report T−2.

**Primary statements (all required)**

| # | Statement | What we use it for |
|---|---|---|
| S1 | Income statement | Every line, including the continuing / discontinued split and the NCI attribution |
| S2 | Statement of comprehensive income | Every OCI item and the NCI attribution — comprehensive income is the headline ROE |
| S3 | Balance sheet | Every line — the basis of the managerial balance sheet |
| S4 | Cash flow statement | Operating cash flow, D&A, capex, disposal proceeds (earnings-to-cash gap, capex ratios) |
| S5 | Statement of changes in equity | Dividends, capital increases and conversions that move equity (ROE denominator) |

**Notes (required: the face of the statements shows the amount, the note shows what it is)**

| # | Note | What we need from it | Used for |
|---|---|---|---|
| N1 | Revenue / contract balances | Contract assets and liabilities, customer advances, financing components | Operating vs financial; customer-financed working capital |
| N2 | Cost breakdown by nature (if IS by function) or by function (if IS by nature) | Materials, services, personnel, D&A | Added value, EBITDA, three cost lenses |
| N3 | Changes in inventories / own work capitalised | Split of the line | Value of production |
| N4 | Other operating income | Every line (refunds, grants, reversals, disposal gains) | Unusual-items test |
| N5 | Other operating expenses | Every line | Unusual-items test; variable vs fixed |
| N6 | Personnel expenses | Wages, social security, pensions, redundancy | Cost structure; restructuring test |
| N7 | D&A and impairment | By asset class, PPA amortisation, impairment losses | EBITA, EBITDAaL, impairment test |
| N8 | Financial result | Interest income, interest expense, other financial result, pension interest, lease interest | Net financial expenses; items reclassified to operating |
| N9 | Income taxes | Statutory rate and reconciliation | Tax allocation |
| N10 | Discontinued operations / held for sale | Result, assets and liabilities held for sale, which business | Unusual items; non-core assets; comparability |
| N11 | Equity-accounted investments | Result by investee, gains on disposals | Non-core operating income |
| N12 | Other assets | Split into financial and non-financial (derivatives, bonds, loans, pension surplus, prepaid, taxes) | What is liquidity and what is operating |
| N13 | Cash and cash equivalents | Composition and restrictions | Is the cash genuinely available? |
| N14 | Financial debt / net debt | By instrument, including leases | Definition of financial debt |
| N15 | Pensions | Obligation, plan assets, surplus, net interest and where it is presented | Operating vs financial |
| N16 | Other provisions | By type | Operating liabilities; unusual provisions |
| N17 | Other liabilities | Split into financial and non-financial (derivatives, other taxes, social security) | Operating vs financial |
| N18 | Equity and NCI | Components, treasury shares, NCI | Equity, shareholding leverage |
| N19 | Segment reporting | Segments and what the main business is | Core vs non-core |
| N20 | Management's APM / special-items bridge (management report) | Company "operating result", special items, PPA effects | Unusual-items candidates; APM memo |

**Stop rule:** if a document, a year, or any of N1, N2, N8, N10, N12, N14 or N15 is missing, **stop and ask**. Do not proceed on an assumption. If any other note is missing, continue and write "NOT FOUND — searched: [where]" on the affected rows.

### A1.3 Procedure
1. List the documents received. For each report, give the printed page of S1–S5 and of every note N1–N20. Say whether the income statement is by nature or by function, and whether any year is restated. Stop if the stop rule applies.
2. Copy S1–S3 line by line into **Reported Financials**, in the report's order and with the report's captions. Record the source of each line on the same row of **Input financials**.
3. **Breakdowns.** Where a note breaks a face line into components, the face line becomes the **sum** of its components.
   - The components are listed directly below it, indented by two spaces, with their captions exactly as in the note.
   - Never write "of which".
   - The printed face-line figure goes into the Checks section.
   
   Break down, at least: changes in inventories and own work capitalised; other operating income; cost of materials (or cost of sales); personnel costs; D&A by asset class; other operating expenses.
4. **Section "Additional information from the notes (included in the lines above)".** List on separate rows the figures that are part of a line but are not a full breakdown:
   - PPA amortisation; impairment losses;
   - net interest on pensions; interest on lease liabilities;
   - gains on sale of shares in investments (from the management report);
   - discontinued operations: earnings before taxes and income taxes;
   - each OCI item before tax, plus the total tax effect on OCI (equity/OCI note);
   - R&D costs recognised as expenses;
   - the statutory tax rate.
   
   These rows are never added into a total.
5. **Section "Notes to the balance sheet".** Show other assets (note on other assets), financial debts by instrument (financial debt note), other liabilities (other liabilities note) and the accumulated amortisation, depreciation and impairment as of 31/12 of goodwill and other intangibles, right-of-use assets, PP&E and investment property ("Total" column of each cost / depreciation schedule, notes N7 and the asset notes; needed for the return on gross operating assets, Part 5 P7). Each is a sum line with its components indented below it. Then add the selected cash-flow lines (S4) and management's operating-result bridge (N20).
6. **Checks section.** Type every printed subtotal and every printed face line that was replaced by a sum, exactly as printed. Compare each with its computed figure. Also check that the discontinued-operations and OCI before-tax figures plus their taxes equal the reported after-tax amounts.
7. Before you finish, run the checks in A1.5.

### A1.4 Prescribed output
**Tab "Reported Financials"** (layout of the Ganni template)
- **Header:** the title bar only, with no subtitle. Then the rows "(€ million)" with the years T−3 to T and "Fiscal year end date".
- **Columns:** `Line (caption as printed) | Note | T−3 | T−2 | T−1 | T | Comment`. T−3 is filled for the balance sheet only.
- **Sections (dark-blue bars), in this order:**
  1. Income Statement;
  2. Additional information from the notes;
  3. Statement of Comprehensive Income;
  4. Balance Sheet — Assets;
  5. Balance Sheet — Equity and Liabilities;
  6. Notes to the balance sheet;
  7. Cash Flow Statement (selected lines);
  8. Management's operating result bridge;
  9. Checks.
- **Rows:**
  - components are indented by two spaces under their sum line;
  - subtotals (total operating performance, EBIT, EBT, earnings from continuing operations, earnings after taxes, total assets, and so on) are bold, with top and bottom borders;
  - Growth %, % of sales, margins and tax rate are grey italic with two decimals.
- **Numbers:**
  - exact amounts in the report's unit;
  - income and assets +, expenses −;
  - typed figures in blue; sums and subtotals are formulas in black.
- **Comment column:** only for facts (restated, footnote fused into the number, not disclosed, perimeter change).

**Tab "Input financials" (same rows as Reported Financials)**
- **Columns:** `Line | Note | Source T−3 | Source T−2 | Source T−1 | Source T | Caption exactly as printed | Status | Number ↔ source`.
- **Source format:** `AR[year] p.[printed page]`. The page is the one printed on the page, not the PDF index.
- **Status:** one of found / found; restated / found (management report) / derived (subtotal) / NOT FOUND.
- **Number ↔ source:** a formula returning OK if every number on that row of Reported Financials has a source, otherwise "source missing".

**Format:** the house style in A0.5. If this workspace cannot create files, give the two tabs as tables with exactly these columns, so they can be pasted row by row.

### A1.5 Checks (report them; never overwrite a printed figure to make a check pass)
1. Total assets = total equity and liabilities, every year.
2. Every computed subtotal equals the printed subtotal within the tolerance typed in the input cell at the top of the Checks section (default 3 in the reported unit: printed tables are rounded line by line and a subtotal such as EBIT is rebuilt from many rounded note lines).
3. Every "of which" breakdown adds back to its face line, and every note total ties to its balance-sheet lines.
4. The T−1 figures in report T are compared with the same year in report T−1. Differences are restatements and are listed.
5. **Footnote markers fused into numbers.** Text extraction can glue a superscript onto a figure, e.g. "EBIT¹ 897" read as "1897". Every figure must pass check 2 or 3, or be confirmed in a second place.
6. **Every number has a source.** The overall status in Input financials must read "ALL OK".

End with: **"Extraction checks: [n] OK, [n] CHECK — [list]. Not found: [list or 'none']."**

---

## MODULE A — PART 2: REFORMULATED INCOME STATEMENT

### A2.1 Purpose and course basis
Reformulate the income statement of years T−2, T−1 and T. Start from the figures in the tab "Reported Financials" (Part 1); do not re-extract them.

The layout is the course roadmap (Session 2, slide 3): core operating income [A] + non-core operating income [B] + net financial expenses [C] = income before unusual items and taxes; ± unusual items = earnings before taxes; − income taxes = comprehensive income.

Four principles apply throughout (Session 2, slide 3):
1. **Coherence with the reformulated balance sheet:** an income item follows the classification of the balance-sheet item that generates it.
2. **Separation of all unusual (non-recurring) items.**
3. **Distinction between core and non-core operating income.**
4. **Specific choices about financial income.**

Core costs are presented **by nature**, as external versus internal costs (Session 3, slide 6), so that value of production, added value and EBITDA can be read directly. If the company reports by function, take materials, services, personnel and D&A from the cost-by-nature note (IAS 1.104). If that note does not exist, write "NOT DERIVABLE" on the added-value and EBITDA rows.

### A2.2 Definitions
- **Core operating income [A]:** the result of the company's main business as described in the segment note, i.e. revenue minus the recurring operating costs of producing and selling. It excludes unusual items.
- **Non-core operating income [B]:** income from assets that are not used in the main business (Session 2, slide 3):
  - income from associates and joint ventures (equity method);
  - financial income on non-operating (strategic) financial assets;
  - income from investment property;
  - income from ancillary activities that the segment note reports separately.
- **Net financial expenses [C]:** interest expenses on financial debt minus interest income on cash and short-term financial assets. They are matched with the net financial position (Session 2, slide 4).
- **Unusual items [U]:** items that meet at least one of the five criteria of Session 2, slide 26:
  1. discontinued operations;
  2. changes of accounting principles;
  3. unusual in nature;
  4. infrequent over time;
  5. results of complex valuations (fair-value adjustments and other non-monetary estimates), whether reported above net income or in OCI.
  
  Items that do not respect the matching principle are also unusual (slides 20–21).
- **Comprehensive income:** net income + other comprehensive income. It is the bottom line (Session 2, slides 3, 22–24).

### A2.3 Rules — where each number comes from and what to do
Each rule number is written in the "Rule" column of the reformulated income statement.

**R1 — Net revenues.** Take the revenue line of the income statement (face). Add Growth % = revenue / prior-year revenue − 1. If the prior year is not restated on the same perimeter, say so in the comment.

**R2 — Value of production** = net revenues + change in inventories of finished goods and work in progress + own work capitalised (Session 3, slide 6).
- Take the split between inventory change and own work from the note that explains the line "changes in inventories and own work capitalised".
- If the company reports by function, these lines do not exist: value of production = net revenues. Say so.

**R3 — External costs (recurring)** = raw materials and merchandise + purchased services + other operating expenses − other operating income, excluding every line moved to unusual items under R9.
- Take materials and services from the cost-of-materials note (or the cost-by-nature note).
- Take other operating income and expenses from their notes, **line by line**.
- **Added value** = value of production + external costs (costs negative).

**R4 — Internal costs: personnel** = personnel costs from the income statement, plus the net interest on pensions if it is reported inside the financial result.
- Take the pension interest from the pensions note (interest cost − interest income on plan assets).
- Reason: coherence with the balance sheet, because pension obligations are operating liabilities (employee benefits, Session 4, slide 8).
- **EBITDA** = added value + internal personnel costs (Session 3, slide 7).

**R5 — Depreciation and amortisation (recurring)** = the D&A line of the income statement minus the impairment losses and reversals moved to unusual items under R9. Take impairments from the D&A/impairment note.
- Show the amortisation from purchase price allocations (PPA) as a memo line underneath. It is recurring and stays in [A].
- **Core operating income [A]** = EBITDA + recurring D&A.

**R6 — Non-core operating income [B]** consists of:
- the result from equity-accounted investments (face of the income statement), minus any gain or loss on the disposal of shares in investments, which is moved to R9;
- other financial result items reported inside EBIT, i.e. financial income on non-operating assets (slide 3);
- income from investment property and from ancillary activities, only if a note reports it separately.

If a component is not disclosed, write "not disclosed" in the comment. Do not estimate it.

**R7 — Net financial expenses [C]** = interest income − interest expenses from the income statement, where:
- interest expenses are taken **after removing** any interest already moved to operating under R4 (pension interest);
- interest on lease liabilities stays in [C], because leases are financial debt;
- if the notes say interest expenses include interest on customer advances (IFRS 15 financing component) but do not give the amount, leave it in [C] and write this in the comment.

**R8 — Income before unusual items and taxes** = [A] + [B] + [C].

**R9 — Unusual items (before tax).** List every candidate on its own row, grouped "From the income statement" and "From the statement of comprehensive income". Name the criterion on each row. Apply this list (Session 2, slides 21 and 26), searching the notes for each:

| Item | Where to find it | Criterion | Treatment |
|---|---|---|---|
| Reversal of provisions (provision not used) | Other operating income note | Matching principle (slide 21) | Unusual |
| Income taxes or costs relating to prior years | Tax note, other operating expenses note | Matching principle | Unusual |
| Write-downs / write-offs of receivables | Other operating expenses note | Matching principle | Unusual |
| Gains or losses on disposal of fixed assets | Other operating income and expenses notes | Infrequent | Unusual |
| Gains or losses on disposal of businesses or shares in investments | Equity-method note, management report, other operating income | Infrequent / unusual in nature | Unusual |
| Impairment losses and reversals | D&A / impairment note | Occasional (slide 21 "?") | Unusual if not present in all three years; otherwise recurring D&A |
| Restructuring costs | Personnel note, other operating expenses note, management report | Slide 21 "?" | Unusual if not present in all three years; otherwise recurring |
| Losses from disasters and related insurance refunds | Other operating income and expenses notes | Slide 21 "?" | Unusual if not present in all three years; otherwise recurring **and** flagged as an unusual change of a usual item (slides 31–32) |
| Fair-value gains or losses in profit or loss | Financial result note | Complex valuation (slide 25) | Unusual |
| Discontinued operations | Discontinued-operations note | Criterion 1 | Unusual, **before tax**; its tax goes to R10 |
| Every OCI item (pension remeasurement, cash flow hedges, currency translation, equity-method OCI, fair value through OCI) | OCI statement; gross amounts from the equity / OCI note | Criterion 5 | Unusual, **before tax**; the tax effect goes to R10 (ASICS, slide 27) |

- The "?" test for impairment, restructuring and disaster items is objective: an item present with the same sign in all three years is recurring; otherwise it is unusual.
- Never classify an item from its caption alone. Quote the note that explains it.

**R10 — Income taxes** = income taxes of continuing operations (income statement) + income taxes on discontinued operations (discontinued-operations note) + tax effect on OCI items (equity / OCI note). Add the tax rate = income taxes / earnings before taxes, with the statutory rate from the tax note as a comment.

**R11 — Comprehensive income** = earnings before taxes (comprehensive) + income taxes. Show the split between NCI and parent from the OCI statement. Also show reported net income as a memo line.

### A2.4 Prescribed output — tab "Reformation & Profitability", section "Reformulated Income Statement"
- **Columns:** `Line | Rule | T−2 | T−1 | T | Where the number comes from / why (course slide)`.
- **Rows, in this order and with exactly these labels:**
  1. Net revenues; Growth %;
  2. Change in inventories of finished and unfinished products; Own work capitalised; **Value of production**;
  3. Raw materials, supplies and merchandise; Purchased services; Other operating expenses, recurring; Other operating income, recurring; **Added value**; Added value / value of production;
  4. Personnel costs; Net interest on pensions (reclassified from financial expenses); **EBITDA**; EBITDA margin;
  5. Depreciation and amortisation, recurring; of which amortisation from purchase price allocations; **Core operating income [A]**; Core operating margin (ROS);
  6. Result from equity-accounted investments, excl. disposal gains; Other financial result; **Non-core operating income [B]**;
  7. **Operating income [A+B]**; Operating margin;
  8. Financial income (interest income); Financial expenses (interest expenses excl. pension interest); **Net financial expenses [C]**;
  9. **Income before unusual items and taxes [A+B+C]**;
  10. Unusual items (before tax): the rows "From the income statement", then "From the statement of comprehensive income"; **Total unusual items**; Unusual items / net revenues;
  11. **Earnings before taxes (comprehensive)**;
  12. Income taxes (continuing operations); Income taxes on discontinued operations; Taxes on OCI items; **Income taxes**; Tax rate on earnings before taxes;
  13. **Comprehensive income**; of which non-controlling interests; of which parent shareholders; Memo: net income as reported.
- **Formatting:** every number is a formula linked to "Reported Financials" (green) or computed (black). Subtotals are bold with top and bottom borders; margins are grey italic.

### A2.5 Checks (must show OK within the tolerance of Part 1)
1. [A] + [B] + unusual items from the income statement (excluding discontinued operations) − pension interest reclassified = reported EBIT.
2. Income before unusual items and taxes + the same unusual items = reported EBT.
3. Comprehensive income = reported total comprehensive income.

If a check fails, do not force it. Report the difference and its likely cause.

End with: **"Reformulated income statement: [n] checks OK. Unusual items identified: [list with criterion]. Not disclosed: [list]."**

---

## MODULE A — PART 3: OPERATING COST STRUCTURE

### A3.1 Purpose and course basis
Analyse the costs behind core operating income [A] using the three reformulations of Session 3 (slide 3):
1. by function;
2. external vs internal costs;
3. variable vs fixed costs.

Then add the common-size analysis (slides 19–20), the ratio list (slide 16) and EBITA (slides 17–18).

Every figure comes from the reformulated income statement (Part 2) or from "Reported Financials" (Part 1). Never re-extract. The recurring cost lines are used, i.e. after the unusual items were removed under R9, so that all three reformulations end at the same core operating income [A].

### A3.2 Definitions (Session 3)
- **Value of production** = net revenues + change in inventories of finished goods and work in progress + own work capitalised (slide 6).
- **External costs** = consumption of resources bought from third parties: materials, services and other operating expenses (slide 6).
- **Internal costs** = personnel, plus depreciation and amortisation (slide 6).
- **Added value** = value of production − external costs. **EBITDA** = added value − personnel. **Core operating income** = EBITDA − D&A (slides 6–7).
- **Variable costs** vary in total, directly and proportionally, with production and sales volume (slide 12). Examples: raw materials consumption, electric power, sales commissions, royalties, transport of goods.
- **Fixed costs** are independent of volume in the short term (slide 12). Examples: personnel, D&A, directors' and auditors' fees, indirect taxes, consulting, advertising, R&D.
- **Contribution margin (CM)** = net revenues − variable costs.
- **Degree of operating leverage (DOL)** = CM / operating income, where operating income is core operating income [A] (slide 13).
- **Margin of safety (MOS)** = operating income / CM.
- **Break-even revenues** = fixed costs / CM %.
- **EBITA** = core operating income before amortisation of intangibles acquired in business combinations (PPA) (slide 17).
- **EBITDAR** = EBITDA before rent expenses (slide 9).
- **EBITDAaL** = EBITDA − depreciation of right-of-use assets − interest on lease liabilities (slide 11).

### A3.3 Rules (the rule number is written in the "Rule" column)
**C1 — Reformulation by function (slides 3–5).**
- If the income statement is presented by function, show: net revenues; cost of sales; **gross profit**; selling costs; general and administrative costs; R&D costs; core operating income. Take the amounts from the face and remove the unusual items allocated to each function, using the notes.
- If it is presented by nature and no note allocates costs to functions, write **"n.d."** in every row except net revenues, and state: "Not derivable: the income statement is presented by nature". Never build a proxy for cost of sales.
- If the management report discloses R&D costs recognised as expenses, show them as a memo line (with page) and give R&D / net revenues. Say whether the year is on the same perimeter as the others.

**C2 — External vs internal costs, common size on value of production (slides 6–8, 19 base b).** Express each row of the reformulated income statement as a % of value of production, from value of production down to core operating income [A]. The rows are: materials, services, other operating expenses (recurring), other operating income (recurring), added value, personnel, pension interest, EBITDA, D&A and [A]. Add the degree of externalisation = net external costs / value of production (slide 6).

**C3 — Variable vs fixed costs (slides 12–15).** Classify every cost line of the reformulated income statement, and list each one on its own row with its classification and the reason from slide 12. Apply this mapping:

| Cost line | Classification | Reason |
|---|---|---|
| Raw materials, supplies and merchandise | Variable | Raw materials consumption |
| Purchased services for production (subcontracting) | Variable | Vary with production volume. If the note shows the services are not production-related, classify them as fixed |
| Change in inventories of finished goods and WIP | Variable (adjustment) | Aligns production cost with the volume sold |
| Freight, transport of goods, sales commissions | Variable | Named on slide 12 |
| Warranties | Variable | Proportional to units sold |
| Royalties / patent and licensing fees | Variable | Named on slide 12 |
| Energy / electric power, if disclosed separately | Variable | Named on slide 12 |
| Personnel costs (incl. pension interest reclassified under R4) | Fixed | Named on slide 12. If the note shows temporary or piece-rate labour, report it but keep it fixed |
| Depreciation and amortisation (recurring) | Fixed | Named on slide 12 |
| Advertising, consulting, audit, IT, insurance, rents, travel, administration, maintenance, other taxes, other provisions, miscellaneous | Fixed | Named on slide 12, or independent of volume in the short term |
| Mixed lines (e.g. "distribution and advertising costs") | Fixed | Cannot be split without disclosure. State that the line is mixed |
| Own work capitalised | Reduction of fixed costs | Internal construction absorbs mainly personnel and overheads |
| Other operating income, recurring | Reduction of fixed costs | Grants, refunds, scrap sales, rentals do not vary with volume |

Then compute: CM; CM %; fixed costs; core operating income [A] (it must equal [A] in the reformulated income statement); DOL; MOS; break-even revenues. Add the observed elasticity = %Δ[A] / %Δ net revenues. Compare it with the prior-year DOL (slide 13), and warn if the two years are not on the same perimeter. Label the whole block **"analyst classification by nature (estimate)"** (slide 14: the myth of variable/fixed costs).

**C4 — Common size on net revenues (slides 19–20, base a).** Express each recurring cost line and [A] as a % of net revenues. Comment on which base (net revenues or value of production) shows the relevant change more clearly (slide 20).

**C5 — Ratio list (slide 16) and performance measures (slides 9–11, 17–18).** Compute, in this order:
- EBITA, EBITDAR, EBITDAaL;
- gross profit / net revenues ("n.d." if by nature);
- added value / value of production;
- EBITDA / value of production;
- EBITDA / added value;
- EBITDA margin; EBITDAR margin; EBITDAaL margin; EBITA margin;
- return on sales = operating income [A+B] / net revenues;
- times interest earned = reported EBIT / interest expenses;
- EBITDA / interest expenses;
- (EBIT + rents) / (rents + interest expenses);
- DOL; MOS;
- tax effect ratio = comprehensive income / EBT;
- tax rate ratio = income taxes / EBT.

Where each input comes from:
- Rents: the "rents / leases" line of the other operating expenses note.
- Right-of-use depreciation: the D&A note.
- Lease interest: the leases note.
- PPA amortisation: the D&A note.

### A3.4 Prescribed output — tab "Reformation & Profitability", section "Operating Cost Structure"
- **Columns:** the same as the reformulated income statement: `Line | Rule | T−2 | T−1 | T | Where the number comes from / why (course slide)`.
- **Blocks, in this order:**
  1. Income statement by function;
  2. External vs internal costs, % of value of production;
  3. Variable vs fixed costs, with DOL, MOS, break-even and observed elasticity;
  4. Common size, % of net revenues;
  5. Ratios and EBITA.
- **Formatting:** every number is a formula referring to the reformulated income statement or to "Reported Financials". Percentages are shown with two decimals.

### A3.5 Checks
1. CM + fixed costs = core operating income [A] of the reformulated income statement.
2. In block 2, value of production + external costs (%) = added value (%).
3. All ratios use the recurring figures (after R9). Unusual items are never included in the cost structure.

End with: **"Cost structure: [n] checks OK. Lines classified as variable: [list]. Mixed lines kept as fixed: [list]. Not derivable: [list]."**

---

## MODULE A — PART 4: MANAGERIAL BALANCE SHEET

### A4.1 Purpose and course basis
Reformulate the balance sheet at the end of T−3, T−2, T−1 and T into the **managerial format** of Session 4. Take every figure from "Reported Financials" (Part 1); never re-extract.

**Why the managerial format:** the liquidity format (short-term vs long-term, IAS 1 "current / non-current") is not the basis of our analysis. The managerial format classifies assets and liabilities by their **nature and function** (operating vs non-operating), and it is the basis for ROI, ROE and valuation (slides 3–7).

**Coherence with the reformulated income statement (Session 2, slide 3):** every balance-sheet item must sit in the same category as the income it generates:

| Balance-sheet category | Income-statement category |
|---|---|
| Operating assets and liabilities | Core operating income [A] |
| Non-operating assets | Non-core operating income [B] |
| Net financial position | Net financial expenses [C] |
| Held-for-sale net assets | Discontinued operations (unusual items) |

### A4.2 Definitions (Session 4)
- **Current operating assets:** assets that circulate in the normal operating cycle: inventories, trade receivables, contract assets (accrued revenues), prepaid expenses and other operating receivables (slide 8).
- **Operating liabilities:** liabilities that arise from the recurring operating cycle: trade payables, contract liabilities (deferred revenues, customer advances), accrued expenses, employee benefits (pensions) and provisions (slides 8, 15–16).
  - They are "current" because they are **re-current**, not because they fall due within twelve months. All of them are deducted, whatever their IAS 1 maturity.
- **Non-current operating assets:** tangible and intangible assets used in operations (slide 8).
- **Non-operating ('surplus') assets:** long-term financial assets and strategic investments that do not serve the main business, plus held-for-sale net assets (slides 8, 13, 19).
- **Financial liabilities:** explicitly interest-bearing debts: bank loans, bonds, promissory notes, commercial paper, lease liabilities, other financial loans (slides 8, 12; Session 6, slide 9).
- **Net operating working capital (NOWC)** = current operating assets − operating liabilities (slide 9, metric 1). It can be negative (slide 15).
- **Gross operating invested capital** = current operating assets + non-current operating assets (slide 9, metric 2).
- **Net operating invested capital** = NOWC + non-current operating assets (slide 9, metric 3).
- **Net financial position (NFP)** = financial debts − cash − short-term financial assets (slides 12–13).
- **Net financial obligations (NFO)** = financial debts − all financial assets, short- and long-term (slides 12–13). Since the non-operating assets are financial assets, NFO = NFP − non-operating assets: "non-operating assets disappear" (slide 13, point 4). This is the NFO used in the ROE decomposition (Part 5).
- **Net short-term financial debt** = short-term financial debts − cash − short-term financial assets (slide 12).

### A4.3 Rules (the rule number is written in the "Rule" column)
**B1 — Start from the notes, not the face.** Before classifying a balance-sheet line, open the note behind it and read what it contains (professor's instructions). Lines that are split by their note are classified component by component:
- other assets;
- other liabilities;
- financial debts;
- cash;
- held-for-sale items.

If a line has no note, classify it by the default in B2–B6 and write "classified without note support" in the comment.

**B2 — Operating assets.**
- **Current operating assets:** inventories; contract assets; trade receivables; the operating part of other current assets (other taxes, prepaid expenses, derivatives hedging operating flows, other non-interest-bearing receivables); tax assets under B7.
- **Non-current operating assets:** goodwill; other intangible assets; right-of-use assets; property, plant and equipment; investment property (slide 8: classified as operating by many analysts, and its rental income stays in core operating income); the operating part of other non-current assets (pension surplus, contract costs, operating derivatives, other non-interest-bearing receivables).
- Remove from "other assets" every component that is a financial asset under B5 or B6 (bonds, securities, interest-bearing loans), using the other-assets note.

**B3 — Operating liabilities:**
- trade payables;
- contract liabilities / customer advances;
- all provisions other than pensions (current and non-current);
- provisions for pensions and similar obligations (employee benefits, slide 8). This is coherent with moving the net pension interest to operating costs (R4);
- other liabilities, current and non-current, that are not interest-bearing (other taxes, social security, derivatives hedging operating flows, other);
- tax liabilities under B7.

Use the other-liabilities note to remove any interest-bearing component; it goes to B6.

**B4 — Subtotals.** Compute NOWC, non-current operating assets and net operating invested capital as defined in A4.2.

**B5 — Non-operating ('surplus') assets:**
- investments accounted for using the equity method (coherent with [B], R6);
- other strategic participations;
- long-term financial assets (bonds and loans held, slide 13 point 2);
- securities that are strategic stakes rather than liquidity;
- **net assets held for sale** = assets held for sale − liabilities directly associated with them (slide 19, option 1). If the net amount is negative, show it as "other liabilities" on the sources side (slide 19, option 2).

Also compute net invested capital = net operating invested capital + non-operating assets.

**B6 — Net financial position.**
- **Financial debts:** non-current + current financial debts from the face. Check the financial-debt note to confirm lease liabilities are included (show them as a memo line) and that no operating item is included.
- **Minus cash and cash equivalents:** all of it (slide 11, option 1: no "working cash" for a non-retail company). If the cash note shows restricted cash, keep that part in current operating assets and say so.
- **Minus short-term financial assets:** securities held for trade, money-market funds, short-term deposits.

NFP is coherent with net financial expenses [C] (R7). Also compute NFO = NFP − non-operating assets (slides 12–13).

**B7 — Tax assets and liabilities.** Apply slide 18, option 2: all tax assets (current and deferred) go into current operating assets, and all tax liabilities (current and deferred) into operating liabilities. This keeps the sources side limited to financial debt and equity, which is the format needed for the ROE decomposition (slides 18, 21). Show the net tax position as a memo if needed.

**B8 — Net equity and non-controlling interests.** Net equity = equity attributable to the parent + non-controlling interests (slide 26: minorities treated as strategic partners → equity). Treasury shares stay deducted inside parent equity. Report the shareholding leverage in the metrics (B9).

**B9 — Metrics (slides 9, 12, 25–28).** Compute, for every year:
- gross operating invested capital;
- operating liability leverage = operating liabilities / gross operating invested capital;
- NFO;
- net short-term financial debt;
- NOWC / net revenues and ΔNOWC / Δnet revenues (slides 15–16: focus on the change, not only the size);
- debt-to-equity = total liabilities / net equity;
- financial debt-to-equity = financial debts / net equity;
- debt-to-assets = total liabilities / total assets;
- NFP / net equity (benchmark ≤ 3, slide 12);
- NFO / net equity;
- NFP / EBITDA (benchmark ≤ 4, slide 12), using EBITDA from Part 2;
- financial leverage = financial debts / parent equity (slide 27);
- shareholding leverage = NCI / parent equity (slide 27);
- adjusted total assets = total assets − goodwill (slide 28);
- tangible net equity = net equity − goodwill (slide 28).

### A4.4 Prescribed output — tab "Reformation & Profitability", section "Managerial Balance Sheet"
- **Placement:** below the operating cost structure.
- **Columns:** `Line | Rule | T−3 | T−2 | T−1 | T | Where the number comes from / why (course slide)`.
- **Rows, in this order and with exactly these labels:**
  1. **Current operating assets:** inventories; contract assets; trade receivables; other current assets (operating); income tax receivables; deferred tax assets; **Current operating assets**.
  2. **Operating liabilities:** trade liabilities; contract liabilities (customer advances); other provisions (current and non-current); provisions for pensions; other liabilities (current and non-current); income tax liabilities; deferred tax liabilities; **Operating liabilities**.
  3. **Net operating working capital (NOWC).**
  4. **Non-current operating assets:** goodwill; other intangible assets; right-of-use assets; property, plant and equipment; investment property; other non-current assets (operating); **Non-current operating assets**.
  5. **Net operating invested capital.**
  6. **Non-operating assets:** equity-accounted investments; long-term financial assets; strategic securities; net assets held for sale; **Non-operating assets**.
  7. **Net invested capital.**
  8. **Financed by:** non-current financial debts; current financial debts; of which lease liabilities; less cash and cash equivalents; less short-term financial assets; **Net financial position (NFP)**.
  9. Equity attributable to parent shareholders; non-controlling interests; **Net equity**.
  10. **Net financial position + net equity.**
  11. **Metrics** (B9).
- **Formatting:** every number is a formula linked to "Reported Financials" (green) or computed (black). Subtotals are bold with borders.

### A4.5 Checks (must show OK within the tolerance of Part 1)
1. Net invested capital = NFP + net equity, every year.
2. Current operating assets + non-current operating assets + equity-accounted investments + long-term financial assets + strategic securities + assets held for sale (gross) + cash + short-term financial assets = reported total assets.
3. Operating liabilities + liabilities held for sale + financial debts + net equity = reported total equity and liabilities.

If a check fails, do not force it. Report the difference and the line most likely misclassified.

End with: **"Managerial balance sheet: [n] checks OK. Lines split using notes: [list]. Classified without note support: [list]. Held for sale: [amount, year]."**

---

## MODULE A — PART 5: ROI AND ROE DECOMPOSITIONS

### A5.1 Purpose and course basis
Explain the operating profitability (ROI, Session 5) and the return on equity (ROE, Session 6) for T−2, T−1 and T by decomposing them into their drivers. Use exactly the formulas taught on the slides.

Every input comes from:
- the reformulated income statement (Part 2);
- the managerial balance sheet (Part 4);
- "Reported Financials" (Part 1), only for the reported figures that the DuPont formulas and the capex ratios need.

Never re-extract a figure. Never type a ratio: every cell is a formula.

**Two principles from the slides:**
1. "The name is not important. It is important to clarify what you put both at the numerator and at the denominator" (Session 5, slide 3). Every row therefore states its numerator and its denominator in the label.
2. Numerator and denominator must be coherent: an income is divided by the assets that generate it (Session 2, slide 3; Session 5, slide 5).

| Income (Part 2) | Assets / capital that generate it (Part 4) |
|---|---|
| Core operating income [A] | Operating invested capital (gross, or net of operating liabilities) |
| Non-core operating income [B] | Non-operating assets |
| Financial income | Cash and short-term financial assets |
| Financial expenses | Financial liabilities |
| Net financial expenses −([B] + [C]) | Net financial obligations (NFO) |
| Comprehensive income | Net equity (incl. NCI) |

### A5.2 Definitions
**Session 5 (ROI)**
- **ROA** = net income / total assets (slide 3).
- **ROI** = operating income / operating assets: the operating profitability ratio, also called ROIC, ROCE or RONA (slide 3).
- **Gross invested capital** = gross operating invested capital (current + non-current operating assets) + non-operating assets (slide 5).
- **Net invested capital** = net operating invested capital (NOIC) + non-operating assets. Operating liabilities are always subtracted from the core operating assets only (slide 6).
- **Operating liability leverage** = operating liabilities / gross operating invested capital. Gross / net operating invested capital = 1 / (1 − operating liability leverage) (slide 6).
- **Assets turnover** = net revenues / gross operating invested capital (slides 9, 15).
- **Days sales outstanding (DSO)** = accounts receivable / (net revenues / 360).
- **Days payable outstanding (DPO)** = accounts payable / (purchases of materials and services / 360).
- **Days inventory outstanding (DIO)** = inventory / (COGS / 360).
- **Cash conversion cycle (CCC)** = DSO + DIO − DPO (slides 15–16).
- **Fixed assets turnover** = net revenues / fixed (tangible) assets. **Long-term productive assets turnover** = net revenues / (tangible + intangible assets) (slide 10).
- **Capex** = acquisitions of tangible and intangible assets, net of disposals (slide 11).
  - **Capex-to-sales** (capital intensity) = capex / net revenues.
  - **Productive capacity replacement** = capex / D&A. A value ≈ 1 means maintenance; > 1 means development (growth) investment (slides 11–12).
- **Net adjusted operating assets** = NOWC + tangible assets + specific intangibles, i.e. operating assets without goodwill and trademarks (slide 17).
- **Gross operating assets** = operating assets at historical cost, before accumulated depreciation (slide 18).

**Session 6 (ROE)**
- **ROE** = comprehensive income / net equity = net income / net equity + OCI / net equity (slide 3).
- **Equity multiplier** = total assets / equity = 1 + total liabilities / equity (slide 4).
- **Net financial obligations (NFO)** = financial liabilities − all financial assets. Following Session 4, slide 13, the non-operating assets are financial assets, so NFO = NFP − non-operating assets. If NFO < 0, the company has **net financial assets (NFA)** (slide 16).
- **Net financial expenses (NFE)** = financial expenses − financial income, including the income on the non-operating assets: NFE = −([B] + [C]) (slide 10, point 3).
- **NOPAT** = core operating income [A] × (1 − t), where t is the average tax rate (slides 13, 26).
- **RNOA** = NOPAT / NOIC (RONA after taxes). **ROOA** = (NOPAT + implicit interest on operating liabilities) / gross operating invested capital (slide 12).
- **Implicit interest** = operating liabilities × short-term borrowing rate after taxes (slide 12).

### A5.3 Rules (the rule number is written in the "Rule" column)
**P0 — Denominators and balance-sheet basis.**
- Put an input cell at the top of the section: "END" (year-end balances) by default, or "AVG" (average of opening and closing balances). The slide examples use year-end amounts (Session 5, slides 7–8; Session 6, slides 13–18).
- Build a block "Balance-sheet amounts used as denominators" with one row per balance-sheet amount. Each row links to the managerial balance sheet (Part 4) or to "Reported Financials", and switches with the basis cell.
- Every ratio below refers to these rows, never directly to the balance sheet. Changing the basis cell then changes every ratio consistently, and every identity still holds.
- The rows are:
  - total assets;
  - total liabilities (= total assets − net equity);
  - net equity;
  - gross operating invested capital;
  - operating liabilities;
  - NOIC;
  - non-operating assets;
  - net invested capital;
  - financial liabilities;
  - cash and short-term financial assets;
  - NFP;
  - NFO;
  - NOWC;
  - trade receivables;
  - inventories;
  - trade liabilities;
  - tangible assets (PP&E + right-of-use assets);
  - tangible and intangible assets (PP&E + right-of-use + goodwill + other intangibles);
  - goodwill;
  - accumulated amortisation, depreciation and impairment;
  - gross invested capital.

**P1 — ROA** = reported net income (earnings after taxes, Reported Financials) / total assets (slide 3).

**P2 — Gross ROI (slides 5 and 7).** Operating income [A+B] / gross invested capital, decomposed as:

  [A] / gross operating invested capital × (gross operating invested capital / gross invested capital)
  + [B] / non-operating assets × (non-operating assets / gross invested capital).

Show each ratio and each weight on its own row.

**P3 — Net ROI (slides 6–8).** Operating income [A+B] / net invested capital, decomposed as:

  [A] / NOIC × (NOIC / net invested capital) + [B] / non-operating assets × (non-operating assets / net invested capital).

[A] / NOIC is the core (net) operating profitability, the typical RONA.

**P4 — Decomposition of core net ROI (slide 8; Session 6, slides 11 and 14).**

  [A] / NOIC = [A] / net revenues (ROS) × net revenues / gross operating invested capital (assets turnover) × gross / net operating invested capital.

- Also show the operating liability leverage (operating liabilities / gross operating invested capital) and prove that 1 / (1 − operating liability leverage) equals gross / net.
- Add the memo line ROS × assets turnover = return on gross operating invested capital (Session 6, slide 31: the "operating" part before the benefit from operating liabilities).

**P5 — Assets turnover: the summary of ratios (slides 9–16).** Compute, in this order:
1. NOWC / net revenues. Slide 16: preferred to the CCC because it has predictive value. Comment the sign: negative = operations financed by customers and suppliers.
2. DSO = trade receivables / (net revenues / 360).
   - Trade receivables are taken as reported. Say that VAT cannot be removed (not disclosed).
   - Contract assets are not accounts receivable (not yet invoiced), so leave them out and say so.
3. DIO = inventories / (COGS / 360).
   - If the income statement is by function, COGS = cost of sales.
   - If it is by nature, use the proxy COGS = materials + purchased services − change in inventories of finished goods and WIP (Part 2, R2–R3), and state it is a proxy.
4. DPO = trade liabilities / (purchases of materials and services / 360).
   - Purchases = cost of materials and services (cost-of-materials note).
   - If the change in raw-material inventories is not disclosed, state that consumption is used as a proxy for purchases.
5. CCC = DSO + DIO − DPO. Comment with slide 16: one day of A/R is not worth the same in euros as one day of A/P, so read the CCC together with NOWC / net revenues.
6. Fixed assets turnover = net revenues / tangible assets. Tangible assets = PP&E + right-of-use assets (leased buildings and equipment). It is a proxy for capacity utilisation (slide 10).
7. Long-term productive assets turnover = net revenues / (tangible + intangible assets incl. goodwill) (slide 10). Remind the reader of depreciation policies and impairments.
8. Net capex = −(cash outflows for PP&E, intangible assets and investment property + cash inflows from their disposal), from the cash flow statement (Reported Financials) (slide 11).
9. Capex-to-sales = net capex / net revenues (slides 11–13).
10. Productive capacity replacement = net capex / D&A. Take D&A from the cash flow statement, so that numerator and denominator cover the same perimeter (both include discontinued operations). Say that this D&A includes impairments.

**P6 — Adjusted ROI: goodwill and trademarks (slide 17).**
- Net adjusted operating assets = NOIC − goodwill − trademarks and other intangibles with indefinite useful life.
- Take goodwill from the balance sheet. Take trademarks from the intangible-assets note. If they are not disclosed separately, remove goodwill only and say so.
- Adjusted core ROI = [A] / net adjusted operating assets.

**P7 — Return on gross operating assets (slide 18).**
- Gross operating assets = gross operating invested capital + accumulated amortisation, depreciation and impairment of goodwill and other intangibles, right-of-use assets, PP&E and investment property.
- Take the accumulated amounts from the "cost / accumulated depreciation" schedules in the notes on intangible assets, right-of-use assets, PP&E and investment property. Part 1 extracts them into "Notes to the balance sheet".
- Return on gross operating assets = [A] / gross operating assets.
- If a year's schedule moved assets to held for sale (IFRS 5), say that the base falls for that reason.
- If the schedules are not disclosed, write "n.d." and state why.

**P8 — GMROI (slides 19–22).** GMROI = gross margin / inventory. It is a retail metric and needs gross margin, i.e. an income statement by function. If the company is not a retailer or reports by nature, write "n.a." and state the reason. Otherwise compute gross margin %, inventory turnover (COGS / inventory) and GMROI = GPM% / (1 − GPM%) × inventory turnover (slide 22).

**E1 — ROE (slide 3).**
- ROE = comprehensive income (Part 2, R11) / net equity.
- Show the split: reported net income / net equity + reported OCI / net equity.
- Net equity includes NCI (B8), so net income and comprehensive income are taken before the NCI split. This keeps numerator and denominator coherent.

**E2 — DuPont basic formula (slide 4).**
- ROE (net income) = net income / sales × sales / total assets × total assets / net equity.
- Prove that the equity multiplier = 1 + total liabilities / net equity.
- Use reported net income. Use net equity incl. NCI as "common equity", for coherence with net income incl. NCI.

**E3 — DuPont broader decomposition (slide 5).**
- ROE (net income) = NI / EBT × EBT / EBIT × EBIT / sales × sales / total assets × total assets / net equity.
- Use reported EBIT and EBT (continuing operations) and reported NI.
- Comment on the five limits in slide 5:
  1. EBIT includes non-core results and unusual items;
  2. total assets include non-operating assets;
  3. the leverage mixes operating and financial liabilities;
  4. financial income is hidden inside EBT/EBIT;
  5. unusual items are not separated.
- These limits are why E4–E7 follow.

**E4 — Modigliani–Miller original formula (slides 6–8).**

  ROE = [OI/IC + (OI/IC − FE/TL) × TL/NE] × CI/IBUIT

where:
- IC = total assets;
- OI = [A] + [B] + financial income (everything earned on total assets);
- FE = financial expenses from Part 2, R7 (positive);
- TL = total liabilities;
- CI/IBUIT = comprehensive income / income before unusual items and taxes.

Show the four drivers of slide 7 on separate rows:
1. operating profitability;
2. spread;
3. debt-to-equity;
4. unusual items and taxes.

**E5 — First technical adjustment (slide 9; Example 5, slides 28–32).**
- Remove the operating liabilities from both invested capital and liabilities. The three areas become:
  - net invested capital incl. financial assets (= financial liabilities + net equity = total assets − operating liabilities − liabilities held for sale);
  - financial liabilities;
  - net equity.
- ROE = [(OI + FI) / (NIC + FA) + ((OI + FI) / (NIC + FA) − FE / FL) × FL / NE] × CI / IBUIT.
- Split the first ratio as in slide 29, three ways:
  - core: [A] / NOIC × NOIC / (NIC + FA);
  - non-core: [B] / non-operating assets × non-operating assets / (NIC + FA);
  - financial: financial income / (cash + short-term financial assets) × (cash + short-term financial assets) / (NIC + FA).
- FE / FL is the cost of financial debt (Kd).
- Split the last factor as in slide 30: CI / IBUIT = CI / EBT (= 1 − average tax rate) × EBT / IBUIT (effect of unusual items).
- Add ROE before unusual items and taxes = IBUIT / net equity (slide 32), the figure to compare with a pre-tax cost of equity.

**E6 — Second technical adjustment: NOIC and NFO (slides 10–11 and 14; slides 16–18 when NFO < 0; slide 21).**
- The three areas become NOIC, NFO and net equity. The non-operating assets are financial assets (Session 4, slide 13), so their income [B] joins the net financial expenses:
  - NFE = −([B] + [C]);
  - NFO = NFP − non-operating assets.
- ROE = [RONA + (RONA − NFE / NFO) × NFO / NE] × CI / IBUIT, with RONA = [A] / NOIC decomposed as in P4 (slide 11).
- **If NFO < 0 in a year**, also show the net-financial-assets form of slide 16 (A):
  - NFA = −NFO;
  - return on NFA = ([B] + [C]) / NFA;
  - ROE = [RONA − (RONA − return on NFA) × NFA / NE] × CI / IBUIT.
  - Comment: a positive spread reduces ROE (slide 16).
  - Show these rows only in the years with NFO < 0 and write "n.a." in the others.
- **If NOIC < 0** (operating liabilities higher than operating assets), state that RONA is not meaningful (slide 21, Dell) and interpret through the operating liabilities.
- Write the sign of NOIC for every year.

**E7 — Penman after-tax formula and operating liability leverage (slides 12, 15; slide 16 (B)).**
- **Tax rate:** t = average tax rate of the reformulated income statement (income taxes / EBT, Part 2, R10), as in Examples 1 and 5.
- **After-tax amounts:**
  - NOPAT = [A] × (1 − t);
  - NFE after taxes = NFE × (1 − t);
  - income before unusual items after taxes = NOPAT − NFE after taxes.
- **ROE** = [RNOA + (RNOA − NFE_at / NFO) × NFO / NE] × CI / IBUIT_at.
- **Short-term borrowing rate after tax (slide 12).**
  - Use short-term interest expenses / short-term financial liabilities × (1 − t) when disclosed.
  - If not, use the proxy financial expenses / financial liabilities × (1 − t) and say so.
  - Provide a blue input cell to override it with a market short-term rate (slide 12 alternative).
- **Operating liability leverage:**
  - implicit interest = operating liabilities × short-term rate;
  - ROOA = (NOPAT + implicit interest) / gross operating invested capital;
  - RNOA = ROOA + (ROOA − short-term rate) × operating liabilities / NOIC.
  - Prove that this RNOA equals NOPAT / NOIC.

### A5.4 Prescribed output — tab "Reformation & Profitability", section "ROI and ROE Decompositions"
- **Placement:** below the managerial balance sheet, before the checks.
- **Columns:** `Line | Rule | T−2 | T−1 | T | Where the number comes from / why (course slide)`.
- **Blocks, in this order:**
  1. Balance-sheet basis cell (input, yellow) and "Balance-sheet amounts used as denominators" (P0).
  2. **Return on investment (Session 5):**
     - ROA (P1);
     - gross ROI (P2);
     - net ROI (P3);
     - decomposition of core net ROI (P4);
     - assets turnover summary (P5);
     - the two adjustments (P6, P7);
     - GMROI (P8).
  3. **Return on equity (Session 6):**
     - ROE and its split (E1);
     - DuPont basic (E2);
     - DuPont broader (E3);
     - Modigliani–Miller original (E4);
     - first technical adjustment (E5);
     - second technical adjustment with the NFA form and the NOIC sign (E6);
     - Penman (E7).
- **Row style:**
  - Each decomposition is a header row (navy, bold), its components indented below, and the resulting ratio as a bold total row.
  - Labels state the formula ("× weight: NOIC / net invested capital").
  - Percentages have two decimals, multiples the format 0.00x, days one decimal.
  - Amounts in € million are marked "(€ million)" in the label.
- **Formatting:**
  - every number is a formula;
  - input cells (basis, short-term rate override, ratio tolerance) are blue on yellow;
  - text results ("n.a.", NOIC sign) are grey italic.

### A5.5 Checks (in the checks section; ratio tolerance 0.05 percentage points because the managerial balance sheet carries ± 2 of rounding)
1. Gross ROI = core × weight + non-core × weight.
2. Net ROI = core × weight + non-core × weight.
3. ROS × assets turnover × gross / net = [A] / NOIC.
4. Gross / net = 1 / (1 − operating liability leverage).
5. DuPont basic = NI / NE, and the equity multiplier = 1 + TL / NE.
6. DuPont five factors = NI / NE.
7. The following each return CI / NE:
   - Modigliani–Miller original;
   - first adjustment;
   - second adjustment;
   - the NFA form (years with NFO < 0);
   - Penman.
8. First adjustment: core + non-core + financial split = (OI + FI) / (NIC + FA). Also CI / IBUIT = CI / EBT × EBT / IBUIT.
9. RNOA from ROOA = NOPAT / NOIC.

If a check fails, do not force it. Report the difference and the input most likely wrong. A failure usually points to a classification that is not coherent between Parts 2 and 4.

**Self-test before running on the company:** rebuild the slide examples with the same formulas. Each must reproduce the slide figure:
- Session 5, slide 7: gross ROI 17.00%, net ROI 23.18%;
- Session 5, slide 8: 30.0% = 15.0% × 1.33 × 1.50;
- Session 6, Example 1: ROE 25.00%, Penman RNOA 18.00% = 12.75% + (12.75% − 4.00%) × 0.60;
- Session 6, Example 2: ROE 12.86%;
- Session 6, Example 5: ROE 33.95%, ROE before unusual items and taxes 36.00%.

End with:

**"ROI and ROE: [n] checks OK. Balance-sheet basis: [END/AVG]. Years with net financial assets: [list]. Years with negative NOIC: [list or 'none']. Proxies used: [list]. Not derivable: [list]."**

Then write three sentences on the main drivers of ROE, one per year-on-year change, naming the factor that moved most:
- ROS;
- turnover;
- operating liability leverage;
- spread;
- financial leverage;
- CI / IBUIT.

---

## MODULE A — PART 6: RATIO SUMMARY, ISSUE LOG, CLOSING DISCLOSURE AND CHAT REPLY

### A6.1 Purpose
Present the three-year evolution of the key measures of Parts 2–5 in one table, and mark two things:
- where a slide-defined threshold applies;
- where the latest change is material compared with the company's own history.

Then document every conflict in the Log tab, close with a disclosure of what is unresolved, and report in the chat. Every figure in the summary is a link to a row above; never recompute or type it.

### A6.2 Rules
**S0 — Material-change screen (supervisor-delegated judgement; not a slide threshold).**
- Put an input cell at the top of the section with the factor k (default 2.0, blue on yellow).
- For each ratio, flag the latest year T as **"MATERIAL CHANGE in T"** when |value T − value T−1| > k × |value T−1 − value T−2|.
- Always show both changes: percentage points for percentages, "x" for multiples, days for days.
- A flag is an **observation**. Never state a cause, a forecast or a good/bad judgement in the flag. Reasons go only in the chat reading, labelled "Interpretation:".
- With three years there is only one previous change. Say so under the table.
- Also say whether the years are comparable (restatements, discontinued operations, perimeter changes, Part 1). If they are not comparable enough to judge, log the limitation (L1) and ask the supervisor.
- For a ratio with only two years (e.g. growth), write "only one prior year: no screen".

**S1 — Slide-defined thresholds only.** Apply a threshold only where a course slide states one. Show the observed value of T beside it, with the slide reference. The thresholds on the slides are:

| Ratio | Threshold | Slide |
|---|---|---|
| NFP / net equity | ≤ 3.00x (benchmark, e.g. covenants) | Session 4 slide 12 |
| NFP / EBITDA | ≤ 4.00x | Session 4 slide 12 |
| Productive capacity replacement (capex / D&A) | ≈ 1 = maintenance; > 1 = development investment | Session 5 slides 11–12 |
| Spread (ROI − cost of debt) | > 0: financial leverage raises ROE; < 0 lowers it | Session 6 slide 7 |

Never invent generic ratio cut-offs or sector benchmarks. Other thresholds are the supervisor's decision.

**S2 — Which ratios, in this order, each linked to its row above:**
- **Income statement and cost structure:**
  - growth of net revenues;
  - EBITDA margin;
  - core operating margin (ROS);
  - operating margin [A+B];
  - unusual items / net revenues;
  - tax rate on EBT (comprehensive);
  - DOL.
- **Managerial balance sheet:**
  - NOWC / net revenues;
  - operating liability leverage;
  - NFP / net equity;
  - NFP / EBITDA;
  - NFO / net equity;
  - debt-to-equity.
- **ROI:**
  - ROA;
  - gross ROI;
  - net ROI;
  - RONA;
  - assets turnover;
  - DSO, DIO, DPO;
  - cash conversion cycle;
  - capex-to-sales;
  - capex / D&A;
  - adjusted core ROI;
  - return on gross operating assets.
- **ROE:**
  - ROE (comprehensive income);
  - net income / net equity;
  - cost of financial debt (Kd);
  - spread ROI − Kd;
  - financial liabilities / net equity;
  - CI / IBUIT;
  - ROE before unusual items and taxes;
  - RNOA;
  - ROOA.

Close the table with the reading rule: "A flag reports the size of the movement against the previous one. It does not state a cause, a forecast or a good/bad judgement". Add the comparability statement.

**L1 — Issue log (tab `Log`).**
- **One record per distinct conflict or analytical issue**, with a stable Issue ID (I-01, I-02, …). Keep resolved records; never delete them.
- **Columns, in this order:** `Issue ID | Date | Agent / module version | Iteration(s) | Task / request | Conflict or analytical issue | Evidence (document, page/note or tab/cells) | Question to supervisor | Supervisor instruction | Change made / reason unchanged | Affected outputs | Status / remaining decision`.
- **What to record:**
  - Quote the erroneous, missing or oversimplified item.
  - Evidence names the document, printed page and note, or the tab and cells.
  - Record the supervisor's actual instruction. Never invent an instruction, a conflict or a resolution.
  - If the prompt's rule decided the issue, write the rule number.
- **Status is one of:**
  - **Resolved**;
  - **Resolved — limitation disclosed**;
  - **For supervisor review** (a proxy or judgement used, awaiting confirmation);
  - **Awaiting supervisor decision** (output blocked or provisional);
  - **Blocked**.
  
  A matter left to the supervisor is never marked Resolved.
- **Always log these issues when they occur:**
  - restated or non-comparable years;
  - footnote markers fused into numbers;
  - figures that differ between documents;
  - items that the notes mention without an amount;
  - reclassifications between operating and financial;
  - statements presented by nature (so no function lens);
  - every proxy (COGS, purchases, short-term rate);
  - items not disclosed separately (e.g. trademarks);
  - held-for-sale and discontinued operations;
  - check tolerances;
  - limits of the material-change screen.

**L2 — Closing disclosure (bottom of the Log tab).** One row each for:
1. figures not found;
2. classifications awaiting a decision;
3. inconsistencies between documents;
4. analyses that could not be completed;
5. supervisor decisions supplied during the work;
6. supervisor-approved assumptions and proxies;
7. the count of open issues, computed by formula from the Status column.

Refer to Issue IDs; do not repeat the text. If nothing is open, write **"None"**.

**L3 — The group's Agent Log is a different file.** `Gnn_Bk_Log.xlsx` records the agent's defects found by the humans. It is written by the group, not by you. Your Log tab is the agent's own record of conflicts, and it is an input to that file.

### A6.3 Prescribed output — tab "Reformation & Profitability", section "Ratio Summary"
- **Placement:** below the ROI and ROE section, before the checks.
- **Rows:**
  - the input row for k (rule S0);
  - one sub-header per block (navy bold);
  - one row per ratio: label, rule "S1", T−2 to T as links (same formats as above), and column J as a text formula containing:
    - the slide-threshold result, when S1 applies;
    - "MATERIAL CHANGE in T: Δ … vs Δ … in T−1", or "Δ T … vs Δ T−1 …".
- **Formatting:** column J rows with "MATERIAL" in orange (FCE4D6); rows "OUTSIDE" a slide threshold in red (FFC7CE).

### A6.4 Prescribed output — tab "Log"
- **Frame:**
  - same frame as the other tabs: rows 1–3 navy, title formula in B3;
  - navy bar "Issue log" in row 7;
  - column headers in row 9: navy bold, wrapped, medium bottom border;
  - records from row 10; wrapped text, font 9, the Issue ID in bold;
  - freeze panes at C10.
- **Status colours:**
  - Resolved: green C6EFCE;
  - For supervisor review: yellow FFEB9C;
  - Awaiting or Blocked: red FFC7CE.
- **After the records:** a navy bar "Closing disclosure", the seven rows of L2, then "x" and END.

### A6.5 Checks
1. Every link in the Ratio Summary points to the row of the same ratio in Parts 2–5. Recompute nothing.
2. Every Issue ID named in the closing disclosure exists in the log.
3. The open-issue count equals the number of records whose status is not "Resolved…".
4. The overall status of the tab still reads "ALL OK". If not, the failing checks are listed in the Log.

### A6.6 Chat reply at delivery (at most 400 words)
1. The file name and version.
2. **Checks:** the number that are OK, which ones are CHECK, and the likely cause of each.
3. **Slide thresholds:** the value of T beside each threshold (S1).
4. **Material changes flagged in T:** list them with both changes. Add no causes.
5. **Reading:** three sentences on the drivers of ROI and ROE (Part 5 closing statement), each labelled "Interpretation:" and citing the rows used.
6. **Open issues:** every Issue ID not "Resolved", with the decision needed. Write "None" if there are none.
