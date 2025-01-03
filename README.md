# activerecord-retry-reads

Automatically retry read queries.

Supports Rails 8.0+ and the `mysql2`, `postgresql`, `sqlite3`, or `trilogy` adapters.

## Installation
In your Gemfile:

```
gem 'activerecord-retry-reads'
```

## Usage

There is currently no configuration for this gem.

## Why this gem?

Historically, gems like [activerecord-mysql-reconnect](https://github.com/planningcenter/activerecord-mysql-reconnect) have been used to automatically reconnect and retry queries after a disconnect from MySQL. They are not compatible with Rails >= 7.1.

Rails 7.1 added native reconnect and retry functionality, but it is _extremely_ conservative about what queries are automatically retried. In almost every Rails app any _read_ query is idempotent and safe to retry. If this is not true in your app, do not use this gem!

This gem expands the automatic retry functionality added in Rails 7.1 to enable retries for every _read_ query.

## Testing

Run tests with:

```
bundle exec appraisal install
bundle exec appraisal rake test
```
