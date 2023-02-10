/** pragma type script **/

import {
  getEnvironment,
  replaceImportAddresses,
  reportMissingImports,
  reportMissing,
  executeScript
} from '@onflow/flow-cadut'

export const CODE = `
pub fun main(): Int {
    return 42
}

`;

/**
* Method to generate cadence code for getShowcases script
* @param {Object.<string, string>} addressMap - contract name as a key and address where it's deployed as value
*/
export const getShowcasesTemplate = async (addressMap = {}) => {
  const envMap = await getEnvironment();
  const fullMap = {
  ...envMap,
  ...addressMap,
  };

  // If there are any missing imports in fullMap it will be reported via console
  reportMissingImports(CODE, fullMap, `getShowcases =>`)

  return replaceImportAddresses(CODE, fullMap);
};

export const getShowcases = async (props = {}) => {
  const { addressMap = {}, args = [] } = props
  const code = await getShowcasesTemplate(addressMap);

  reportMissing("arguments", args.length, 0, `getShowcases =>`);

  return executeScript({code, processed: true, ...props})
}