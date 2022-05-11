
# Change Log
All notable changes to this project will be documented in this file.


## [0.8.24] - 2022-05-11
### Changes
 - Fixed wrong spacing in is_water parsing
 
## [0.8.15] - 2022-05-1
### Changes
 - Added SCM Messages to the SCM+ parsing

## [0.8.0] - 2022-04-29
### Changes
 - Added capability for automatically adding R900 Water Meters
 - Added capability for automatically adding SCM+ Gas meters with Endpoint Type 156
 - Added Gas Unit of measurement selector
 - Added SCM+ Gas Divisor (defaults to 1
 
## [0.7.17] - 2022-04-29
### Changes
 - add meter attributes to post 
 
## [0.7.15] - 2022-04-29
### Changes
 - Clean up Comments in run.sh
 - Remove duration enable boolean (enabled if over 0)

## [0.7.14] - 2022-04-28
### Changes
 - Fix issues regarding using an id

## [0.7.6] - 2022-04-17
### Changes
- Added read duration option
- Removed Initial Wait Time Option and replaced it with a static 15s

## [0.7.5] - 2022-04-16
### Changes
- Modified Dockerfile to no longer need to be rebuilt each update

## [0.7.4] - 2022-04-15
### Added
- Inital Listen Time option
- Time Between Readings option

## [0.7.3] - 2022-04-14
### Changes
- Converted msgType to a list

## [0.7.2] - 2022-04-14
### Changed
- Modified bash file to support no IDs

## [0.7.1] - 2022-04-14
### Changed
- Ongoing log is now 1 line

## [0.7.0] - 2022-04-14
### Added

- Use internal API URL
- Use Built in authentication for Addons

### Changed

- Cleaned up curl output for much cleaner logs
- Ongoing log is now 2 lines instead of 5
1. A message containing the data being sent, and th url its being sent to
2. A HTTP response code from CURL

### Removed

- Port Configuration Option
- Host Configuration Option
- Token Configuration Option
