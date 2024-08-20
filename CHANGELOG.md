## 2.0.0 - 2024-08-19

### Changed
- The repository was renamed to rules-engine
- The Minimum Hold Time rule was refactored to conform to common rule storage and processing conventions
- Documentation was added for admin role removal and renunciation
- Additional data was added to the TokenRegistered event to support offchain processing
- Deployment Scripts were updated to better align with the documented integration strategy and AppManager based RBAC items were removed
- String parameters in the event were changed to not be indexed

### Added
- FeeCollected events are now emitted when fees are collected
- Token Max Trading Volume and Token Max Supply Volatility rule now have additional configuration functions

### Removed
- ProtocolERC20 was removed in favor of minimalistic integration strategies