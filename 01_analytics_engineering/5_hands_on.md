# Let's Play

## Models,

- Create 3 folder under models
    - Staging
        ```sh
            mkdir staging
        ```
    - Intermediate
        ```sh
            mkdir intermediate
        ```
    - Marts
        ```sh
            mkdir marts
        ```
        


### Staging

The staging model is a model that:

- taking raw data into views
- apply some type casting from raw data
- renaming field
- deduplicate data

To create a staging model, 
    - create 
        ```sh
            touch _model.yml 
        ```
    - create 
        ```sh
            _src_.yml 
        ```

_model.yml is the file to populate model definition
```yaml
version: 2

models:
  - name: stg_international_top_terms
  - name: stg_international_top_terms_two
```
_src.yml is the file to populate source data 
```yaml
version: 2
sources:
  - name: s_google_trends
    database: bigquery-public-data
    schema: google_trends
    tables:
      - name: s_international_top_terms
        identifier: international_top_terms
```
