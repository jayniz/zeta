# 0.8.0
- the Zeta singleton will update its contracts after it's initialized

# 0.7.4
- hint to --trace option on error
- fix cache dir cleanup on refetch

# 0.7.3
- fix https://github.com/moviepilot/zeta/issues/13

# 0.7.2
- broken 😱

# 0.7.1
- remove require 'pry'

# 0.7.0
- update Lacerda to ~> 0.12
- add Zeta.convert_all! convenience method

# 0.6.0 (06-Nov-15)
- update Lacerda

# 0.6.2 (04-Nov-15)
- update Lacerda
- add --trace option so we don't bother people with exception traces all the time

# 0.6.1 (03-Nov-15)
- make rspec integration a little more convenient

# 0.6.0 (03-Nov-15)
- make reporter configurable for contracts_fulfilled?
- add rspec integration
- add Zeta.verbose= setter

# 0.5.0 (02-Nov-15)
- update lacerda
- use lacerda stdout reporter by default

# 0.4.0 (30-Oct-15)
- update lacerda which uses ServiceName::Object in favor of ServiceName:Object

# 0.3.0 (29-Oct-15)
- forward published/consume object validation method to the current service in the infrastructure
- forward wrapped consume object creation to the current service
- use HTTP_USER and HTTP_PASSWORD instead of GITHUB_USER and GITHUB_TOKEN

# 0.2.5 (28-Oct-15)
- better CLI help
- update lacerda version

# 0.2.3 (22-Oct-15)
-  log urls of downloaded service files

# 0.1.2 (20-Oct-15)
- add `zeta` runner
