Subject: Exploratory Data Analysis Findings and Next Steps

Hi All,

Hope you are doing well. 

I have recently completed an exploratory data analysis on our three core datasets: users, brands, and receipts. This analysis has revealed several key questions regarding data quality and consistency, which I believe require our collaborative attention to ensure accurate reporting and analysis.

My goal is to identify and address potential data issues proactively. To do this, I have used various analytical strategies and would appreciate your feedback to help refine our data processes. I have also included some standard best practices that are commonly used to address these types of issues and looking forward to hearing your feedback on these.

I have summarized the critical questions below and propose a follow-up meeting to discuss these in detail and align on processes for better data integrity.

A. Deep-dive into the Users Dataset

User Roles: The user dataset definition specifies that the "user role" should always be "consumer." However, I have found that approximately 16.5% of the data includes "fetch-staff" roles. We need to determine if this is expected. Should we filter out "fetch-staff" when conducting user data analysis?

B. Deep-dive into the Brand Dataset

(i) Multiple Brand Categories for Barcodes: 7 item barcodes are associated with more than one brand category. For instance, barcode 511111305125 is linked to both "Baby" and "Magazines." Additionally, some brand codes and names appear to be test data. Could you please review samples and confirm their validity according to business logic?

(ii) Unique Item Identification: The receipt dataset, containing transactional information, might produce cross-product outputs due to the barcode matching between brand and receipts, which is not ideal. Are there other business-critical identifiers, either within this dataset or in additional datasets, that can help us uniquely identify an item's barcode?

(iii) Missing Brand Categories: Around 13% of the brand dataset (155 items) lacks a brand category. When creating reports, these null categories are undesirable in filters and visuals. Should these records be ungrouped? If so, do you have a preference for how they should be internally grouped (e.g. "Unknown Group", "Not Available" or "Non-Group")? Assigning a dummy group would provide clarity during reporting. Here are some examples for your review:

| BRAND_UUID              | BARCODE     | BRAND_CODE | BRAND_CATEGORY | BRAND_CATEGORY_CODE | CPG_ID              | CPG_REF              | BRAND_NAME              |
|-------------------------|-------------|------------|----------------|---------------------|---------------------|----------------------|-------------------------|
| 57c08106e4b0718ff5fcb02c| 511111102540|            |                |                     | 5332f5f2e4b03c9a25efd0aa | Cpgs                 | MorningStar        |
| 5332f5fee4b03c9a25efd0bd| 511111303947|            |                |                     | 53e10d6368abd3c7065097cc | Cpgs                 | Bottled Starbucks  |
| 5332fa7ce4b03c9a25efd22e| 511111802914|            |                |                     | 5332f5ebe4b03c9a25efd0a8 | Cpgs                 | Full Throttle      |

(iv) Missing Brand Category Codes: 56% of the data lacks brand category codes. For example, 13% of items in the "BAKING" brand category have null codes. Should we backfill these null codes with "baking"? I can provide an extract of the affected records.

(v) Un-grouped Brand Category Codes: For some brand categories like "Condiments & Sauces" and "Canned Goods & Soups," all category codes are missing. Do you have a preference for assigning a category like "Un-grouped" or "Not Applicable" for filtering purposes? We can also establish a process for periodic review through automated reporting.

(vi) CPG Collection: We have "COGS" and "CPGS" collections with IDs. What is their business significance? Are "COGS" and "CPGS" related to cost of goods sold and consumer product goods sold? Are there additional data sources to explore for relationships with the brand dataset?

(vii) Top Brand Flag: 52% of records lack a "top brand" flag. Should we automate updating null values with a default "false"?

(viii) Brand Name Formats: Some brand names follow a standard format, while others are "test brand@ <number>." Are these test data, and can they be filtered?

C. Deep-dive into the Receipts Dataset

(i) Bonus Points Earned Skew: A five-number summary analysis revealed skewed data in the "bonus points earned" field. Do we have a business use-case for flagging transactions with significantly high bonus points?

| FIVE_NUMBER_SUMMARY_COLUMN | MAX   | MIN  | AVG    | MEDIAN | MODE | SKEW   | KURTOSIS |
|----------------------------|-------|------|--------|--------|------|--------|----------|
| bonus_points_earned        | 750.00| 5.00 | 238.89 | 45.00  | 5.00 | 0.8997 | -0.9166  |

(ii) Missing Transaction Dates: Several transactional records lack finished or modified dates. Can you explain the business use-case for these records?

(iii) Points Earned Analysis: A similar analysis on "points earned" shows skewed data. We can discuss business checks for customer behavior and segmentation analysis.

| FIVE_NUMBER_SUMMARY_COLUMN | MAX      | MIN  | AVG    | MEDIAN | MODE | SKEW   | KURTOSIS |
|----------------------------|----------|------|--------|--------|------|--------|----------|
| points_earned              | 10200.00 | 0.00 | 585.98 | 150.00 | 5.00 | 4.7279 | 25.0035  |

(iv) User ID Discrepancies: 117 user IDs in the receipt data are missing from the user data. These users have 148 transactions, with user ID "5fff2698b3348b03eb45bb10" having 7 transactions on 2021-01-13, two of which were "FLAGGED" and the rest "FINISHED." I'd like to share examples and discuss creating a report for Fetch review.

Please let me know your availability for a follow-up meeting to discuss these findings and align on next steps.

Thank you for your time and collaboration.

Best,
Shankar