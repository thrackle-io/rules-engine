/* global ethers */
/* eslint prefer-const: "off" */

//const { getSelectors} = require('./libraries/diamond.js')
// console.log('Hello');
function getContractSelectors () {
    const sel = 1
    // return sel
//   return getSelectors("VersionFacet")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    getContractSelectors()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

// exports.getContractSelectors = getContractSelectors