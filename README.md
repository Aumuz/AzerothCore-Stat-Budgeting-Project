# AzerothCore Stat Budgeting Project



The AzerothCore Stat Budgeting Project is a documentation-first reference project that derives, validates, and formalizes stat budgeting rules for custom items in AzerothCore (World of Warcraft 3.3.5a).



This repository does **not** provide a tool, addon, or script that automatically generates items.

Instead, it provides a rigorously validated framework that developers can use to:



* understand how stat budgets behave in AzerothCore,
* create custom items with appropriate power levels,
* verify and audit existing items,
* and reason about item progression in a consistent, data-driven way.



The primary output of this project is **documentation**.



---



## What This Repository Is (and Is Not)



**This repository is**:

* A set of authoritative reference documents.
* A validated model of stat budgeting behavior in AzerothCore 3.3.5.
* A practical guide for developers creating or auditing custom items.



**This repository is not**:

* An executable calculator or automation tool.
* A Blizzard design replica or reverse-engineered design intent.
* A replacement for gameplay judgment or encounter tuning.



The goal is consistency, transparency, and usability — not automation.



---



## How to Use This Repository



Most readers should start with the documents below, in order.



### Core Documents (Start Here)



These four documents are the core of the AzerothCore Stat Budgeting Project and are intentionally placed at the root of the repository.



1\. **Validation-Reference.md**

   *A Derivation and Validation of Stat Budgeting in AzerothCore*

   Explains the data sources, methodology, assumptions, and validation process used to derive all values in this project.



2\. **Developer-Handbook.md**

   *A Developer’s Handbook to Stat Budgeting Custom Items*

   Defines the recommended workflow for calculating stat budgets and item prices for custom equipment and weapons.



3\. **Developer-Recommendations.md**

   *Developer Recommendations for Stat Allocation*

   Provides practical guidance on stat distributions, DPS values, armor expectations, and progression patterns.



4\. **Precision-Reference.md**

   *A Verification Guide to Stat Budgeting in AzerothCore*

   Documents observed itemization behavior using raw, non-interpolated data for auditing and verification purposes.



You do **not** need to read all four documents to use the AzerothCore Stat Budgeting Project effectively.

Each document is scoped to a specific audience and purpose.



---



## Repository Structure



```text

AzerothCore-Stat-Budgeting-Project/

├── README.md

│

├── Validation-Reference.md

├── Developer-Handbook.md

├── Developer-Recommendations.md

├── Precision-Reference.md

│

└── supporting-material/

&nbsp;   ├── data/

&nbsp;   │   ├── canonical/

&nbsp;   │   ├── depreciated/

&nbsp;   │   └── dataset.csv

&nbsp;   └── sql/

&nbsp;       ├── canonical/

&nbsp;       └── depreciated/
```



---





## Supporting Material



The `supporting-material/` directory contains the data and SQL scripts used to derive

and validate the documentation.



These materials are provided for:

* transparency,
* reproducibility,
* and deeper inspection by interested developers.



They are **not required** for normal use of the documentation and are intentionally

separated to avoid confusion.



---



## Scope and Versioning



* Target Platform: **AzerothCore (ACDB 335.14-dev)**
* Game Version: **World of Warcraft 3.3.5a**
* Database: **MySQL 8.0**
* Operating Environment: **Linux (Ubuntu 24.04)**



The AzerothCore Stat Budgeting Project models observed itemization behavior within this scope.

No assumptions are made about later expansions or alternate rule sets.



---



## Design Philosophy



The AzerothCore Stat Budgeting Project is built on a few simple principles:



* Observed behavior is more important than assumed intent.
* Averages describe tendencies, not rules.
* Itemization variance is structural, not anomalous.
* Documentation should empower judgment, not replace it.



Where interpolation or derived values are used, they are explicitly identified and justified.



---



## Authorship and Acknowledgments



Author: **Aumuz Messick**



ChatGPT was used as a collaborative assistant for analysis, validation, and formatting.

All conclusions and results were manually reviewed and verified.



---



### License



This project is provided for reference and educational use.

Licensing terms may be added depending on downstream distribution needs.

