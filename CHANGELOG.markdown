# 0.13.0
- Add explicit Zeta.create_instance initializer with support to pass in options

# 0.12.5
- More conservative locking

# 0.12.4
- More conservative locking

# 0.12.3
- Force rspec examples (in RSpec integration of zeta, not its own tests) to run in order

# 0.12.1
- Retry failed downloads up to 3 times

# 0.12.0
- Update Lacerda (fixes required arrays being marked as invalid
  when they're empty)
- Update a couple of dependency
- Drop ruby 1.9 support, tests run on 2.3.0

# 0.11.2
- Make RSpec runner less verbose when downloading specifications

# 0.11.1
- Fix RSpec runner

# 0.11.0
- Use a lacerda version that makes optional attributes nullable by
  default. If you have an object with an optional property `foo`,
  now both {"foo": null} and {} will be valid objects (up to 0.11.0
  only the latter was valid)

# 0.10.0
- The Zeta singleton will only transform its own contracts after it's
  initialized, but not fetch remote contracts as this is not necessary
  at runtime see [#15](https://github.com/moviepilot/zeta/issues/15)

# 0.9.0
- Change http basic auth env vars to ZETA_HTTP_USER and ZETA_HTTP_PASSWORD

# 0.8.0
- The Zeta singleton will update its contracts after it's initialized

# 0.7.4
- Hint to --trace option on error
- Fix cache dir cleanup on refetch

# 0.7.3
- Fix https://github.com/moviepilot/zeta/issues/13

# 0.7.2
- Broken 😱

# 0.7.1
- Remove require 'pry'

# 0.7.0
- Update Lacerda to ~> 0.12
- Add Zeta.convert_all! convenience method

# 0.6.0 (06-Nov-15)
- Update Lacerda

# 0.6.2 (04-Nov-15)
- Update Lacerda
- Add --trace option so we don't bother people with exception traces all the time

# 0.6.1 (03-Nov-15)
- Make rspec integration a little more convenient

# 0.6.0 (03-Nov-15)
- Make reporter configurable for contracts_fulfilled?
- Add rspec integration
- Add Zeta.verbose= setter

# 0.5.0 (02-Nov-15)
- Update lacerda
- Use lacerda stdout reporter by default

# 0.4.0 (30-Oct-15)
- Update lacerda which uses ServiceName::Object in favor of ServiceName:Object

# 0.3.0 (29-Oct-15)
- Forward published/consume object validation method to the current service in the infrastructure
- Forward wrapped consume object creation to the current service
- Use ZETA_HTTP_USER and ZETA_HTTP_PASSWORD instead of GITHUB_USER and GITHUB_TOKEN

# 0.2.5 (28-Oct-15)
- Better CLI help
- Update lacerda version

# 0.2.3 (22-Oct-15)
- Log urls of downloaded service files

# 0.1.2 (20-Oct-15)
- Add `zeta` runner
