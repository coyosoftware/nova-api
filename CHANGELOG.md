# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2026-11-09

### Added

- Forecast resource

- Forecast confirmation endpoint (`Forecast.confirm` and `Forecast#confirm`)

- Forecast confirmation from an installment (`Installment#confirm`)

## [1.7.0] - 2026-03-26

### Added

- Installment write offs cancellation endpoint (`Installment.cancel_write_offs` and `Installment#cancel_write_offs`)

## [1.6.1] - 2025-09-11

### Added

- Missing fields for company resource: `city`, `complement`, `email`, `logo`, `municipal_inscription`, `neighborhood`, `number`, `social_reason`, `state`, `tax_regime` and `zipcode`

### Removed

- `social_contract_date` and `social_contract_number` fields from company resource

## [1.6.0] - 2025-09-04

### Added

- Invoice resource, with `STATUS` and `TYPE` enums

- Invoice creation endpoint for payables and receivables (`save_invoice`)

## [1.5.0] - 2025-09-01

### Added

- Installment write off endpoint (`Installment.write_off` and `Installment#write_off`)

- `installments` accessor on `Nova::API::Client`

- Find endpoint for payables and receivables (`Payable.find` and `Receivable.find`)

### Fixed

- Nested attributes without an allowed attributes list were not being serialized to plain values

## [1.4.7] - 2024-05-20

### Changed

- Requests now build the full URL from the current configuration on each call instead of changing the HTTParty base URI on the class

### Removed

- `HTTParty` is no longer included in `Nova::API::Base`

## [1.4.6] - 2024-04-29

### Changed

- Debug messages now show the full request URL

## [1.4.5] - 2024-04-05

### Changed

- Debug messages now report base URI changes

## [1.4.4] - 2024-04-05

### Added

- Debug message when the subdomain is changed

### Removed

- Unused `host` and `scheme` readers from the configuration

## [1.4.3] - 2024-04-03

### Added

- Configuration to enable debug output (`debug`)

### Changed

- Request logs are now only printed when `debug` is enabled

## [1.4.2] - 2024-04-03

### Added

- Request logging to stdout, including the request headers

## [1.4.1] - 2023-10-03

### Fixed

- Company social contract date constraint was not accepting nil values

## [1.4.0] - 2023-10-03

### Added

- Complementary fields for company resource

## [1.3.0] - 2023-10-03

### Added

- Configuration to use the staging environment (```use_staging```)

## [1.2.0] - 2023-09-29

### Added

- Apportionment name to ApportionmentValue class
- Active flag to FinancialAccount class

## [1.1.0] - 2023-09-22

### Added

- Webhooks endpoint

## [1.0.0] - 2023-07-11

### Added

- Permissions list endpoint

- Direct bill endpoint

- New bill document type (ORDER_NUMBER)

- Attachment support for bills

- Write off document types enum

- CardTax id on card list endpoint

- CardTax type enum

### Changed

- No longer accepting financial_account_id parameter in Receivable and Payable creation/update endpoints. Now the financial account information must be sent using the new financial_accounts array parameter. This was made to accept multiple financial accounts for the same bill.

## [0.8.0] - 2021-03-16

### Added

- HTTP status code to Response and ListResponse classes

## [0.7.0] - 2021-03-12

### Added

- Bill document types constants

- Bill due types constants

- Identifier attribute to bill resource

- Receivables search endpoint

- Payables search endpoint

## [0.6.0] - 2021-03-10

### Added

- The financial account reasons constants

## [0.5.0] - 2021-03-09

### Added

- Payables & Receivables related stuff

- Card taxes to cards asset

## [0.4.0] - 2021-03-05

### Added

- Current asset related stuff (still missing Card Taxes)

### Changed

- The 'with_deleted' flag is now called 'with_inactive'

- The 'deleted' flags are now called 'active'

## [0.3.0] - 2021-03-04

### Added

- Third party related stuff

## [0.2.0] - 2021-03-03

### Added

- Financial account related stuff

### Fixed

- The way that the token was sent

## [0.1.1] - 2021-03-02

### Added

- Apportionment related stuff

[unreleased]: https://github.com/coyosoftware/nova-api/compare/v1.8.0...HEAD
[1.8.0]: https://github.com/coyosoftware/nova-api/releases/tag/v1.8.0
[1.7.0]: https://github.com/coyosoftware/nova-api/releases/tag/v1.7.0
[1.6.1]: https://github.com/coyosoftware/nova-api/releases/tag/v1.6.1
[1.6.0]: https://github.com/coyosoftware/nova-api/releases/tag/v1.6.0
[1.5.0]: https://github.com/coyosoftware/nova-api/releases/tag/v1.5.0
[1.4.7]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.7
[1.4.6]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.6
[1.4.5]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.5
[1.4.4]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.4
[1.4.3]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.3
[1.4.2]: https://github.com/coyosoftware/nova-api/releases/tag/v1.4.2
[1.4.1]: https://github.com/coyosoftware/nova-api/releases/tag/1.4.1
[1.3.0]: https://github.com/coyosoftware/nova-api/releases/tag/1.3.0
[1.2.0]: https://github.com/coyosoftware/nova-api/releases/tag/1.2.0
[1.1.0]: https://github.com/coyosoftware/nova-api/releases/tag/1.1.0
[1.0.0]: https://github.com/coyosoftware/nova-api/releases/tag/1.0.0
[0.8.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.8.0
[0.7.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.7.0
[0.6.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.6.0
[0.5.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.5.0
[0.4.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.4.0
[0.3.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.3.0
[0.2.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.2.0
[0.1.1]: https://github.com/coyosoftware/nova-api/releases/tag/0.1.1