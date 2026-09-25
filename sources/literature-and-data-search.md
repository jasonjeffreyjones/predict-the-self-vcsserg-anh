# Source checks and additional-data search

Access date: 25 September 2026. This is a targeted discovery search, not a
systematic review or proof that no other dataset exists. Searches included
`longitudinal self descriptions Who am I open data repeated identity`,
`"twenty statements" "longitudinal" "data availability"`,
`"longitudinal" "self-description" "dataset"`, and author/title searches for
the candidates below. Both commissioned bibliographies were consulted; they
contain suggestions rather than a validated bibliography of only Jones's work.

## Data decisions

| Candidate and checked primary source | Evidence and decision |
|---|---|
| [JJJ Pro Who am I, Ipseome preprint, section 3](https://arxiv.org/html/2607.02488v1) | Required source family. Zenodo concept DOI 10.5281/zenodo.21134632 resolves to record 21134633, whose API listing on the access date contained only `jjj-pro-wai-2024.csv`. Used the two-wave public GitHub release supplied by Dr. Jones instead. |
| [Future Selves data statement](https://github.com/jasonjeffreyjones/predict-future-selves/blob/9b6a766712583fec8d3182957260b1123fbfa146/docs/data_statement.md) | Train and dev contain 200 labeled pairs. Exact files preserved with SHA-256 manifest. Full cohort timing and selection are publisher reports, not independently verifiable from public timestamps or platform IDs. Test targets are private; no participation or submissions. |
| [Self-concept in adolescence, Hards and Fisk](https://reshare.ukdataservice.ac.uk/853128/) | Archive describes 6,558 statements from 822 adolescents, indexed by age and gender. No repeated-person wave structure documented on the catalog page. Not treated as longitudinal. |
| [Rathbone and Moulin, 2017](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2017.01445/full) | Self-image norms and age comparisons; collection-year information does not establish repeated observations of the same individual. Not eligible on available documentation. |
| [Lumma et al., 2017, author-hosted manuscript](https://pure.mpg.de/pubman/item/item_3162757_1/component/file_3162758/Lumma_2017.pdf) and [author project page](https://pvrticka.com/projects/resource_project/) | Genuine repeated TST measurements in the ReSource intervention project (T0–T3). No downloadable linked raw text located in the checked paper/project page or targeted searches. Publisher supplement endpoint failed to load. Potentially suitable if raw texts become available; absence from this analysis is an access limitation, not evidence the data do not exist. |
| [Vahabli and Jones, 2025](https://link.springer.com/article/10.1007/s42001-025-00358-y) | Longitudinal Twitter descriptions. Publisher's Data availability section says data are available upon reasonable request. No public raw-text download located. No unsolicited request sent. |
| [Guo et al., 2024, paper](https://par.nsf.gov/servlets/purl/10548356) | Longitudinal Twitter bios underlie occupational transitions, but paper explicitly limits sharing to job-transition data rather than rich text. Aggregate transition graph cannot validate person-specific full-text forecasts. |
| [HINENI and Identity Trends, Ipseome sections 4–5](https://arxiv.org/html/2607.02488v1) | Public signifier frequencies aggregated over countries/years, not paired individual descriptions. Ineligible for the present estimand. |
| [AboutMe dataset card](https://huggingface.co/datasets/allenai/aboutme) | Web-page self-descriptions; no repeated-person temporal design established. Not a longitudinal replication. |

No second dataset meeting both the linked-text requirement and accessible-data
requirement was obtained. The manuscript must report this limitation rather than
portray the search as a comprehensive inventory. New collection or permission
requests are not necessary to complete the primary public-data study.

## Claims checked for the article

* Kuhn and McPartland (1954), *An Empirical Investigation of Self-Attitudes*,
  American Sociological Review 19(1), 68–76, DOI 10.2307/2088175. Original paper:
  https://stelar.edc.org/sites/default/files/Kuhn_TwentyStatementsTest.pdf .
  Supports the elicitation tradition; does not establish the reliability of this
  modern sample or the validity of lexical prediction as a measure of all selfhood.
* Hofman, Sharma, and Watts (2017), *Prediction and explanation in social
  systems*, Science 355, 486–488, DOI 10.1126/science.aal3856. Author's
  institutional page: https://www.microsoft.com/en-us/research/publication/prediction-explanation-social-systems/ .
  Supports distinguishing predictive accuracy from explanatory interpretation.
* Salganik et al. (2020), *Measuring the predictability of life outcomes with a
  scientific mass collaboration*, PNAS 117(15), 8398–8403, DOI
  10.1073/pnas.1915006117. https://pmc.ncbi.nlm.nih.gov/articles/PMC7165437/ .
  Supports setting measured predictive performance against benchmarks, not
  extrapolating one task's accuracy to the inherent predictability of every life.
* Vahabli and Jones (2025), above: journal page verifies bibliographic details,
  abstract findings of lexical/semantic diversification, and request-only data.
  Full paywalled text was not used for unverified methodological claims.
* Jones (2026), *Building the Ipseome*, arXiv:2607.02488v1. Sections 3–3.2
  support the data-family description, public-data consent, and heterogeneous
  response format. Follow-up timing, precise linkage rules, and complete-pair
  counts come from the versioned GitHub statement, not the earlier preprint.

No claims rest on search snippets alone when a primary source was available.
