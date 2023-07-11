# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[unreleased]: https://github.com/coyosoftware/nova-api/compare/1.0.0...HEAD
[1.0.0]: https://github.com/coyosoftware/nova-api/releases/tag/1.0.0
[0.8.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.8.0
[0.7.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.7.0
[0.6.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.6.0
[0.5.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.5.0
[0.4.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.4.0
[0.3.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.3.0
[0.2.0]: https://github.com/coyosoftware/nova-api/releases/tag/0.2.0
[0.1.1]: https://github.com/coyosoftware/nova-api/releases/tag/0.1.1