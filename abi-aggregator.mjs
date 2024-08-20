import fs from "fs/promises"
import pkgjson from './package.json' assert { type: 'json' }
import { existsSync, mkdirSync } from "fs"

const outputDir = `doom-abis/${pkgjson.version}`

if (process.argv.length != 4 || process.argv[2] != "--branch") {
  console.log("Usage: node abi-aggregator.mjs --branch <repo branch>")
  process.exit(1)
}
const repoBranch = process.argv[3]

/*
 * This list represents all of the ABI files which are output by `forge build` that are
 * relevant to the Admin UI and required for it to function properly. The 'name' key is the name
 * of the output file created by this script which is then migrated to the ABIs module of
 * the Admin UI, so it is important that these names don't change, or if they must, then there must
 * also be a corrsponding Admin UI change. Obviously the Admin UI names mostly match this repository's names,
 * as you'd expect, with the exception of the Rule and Handler diamonds.
 */
const ABIFiles = [
  {
    name: "ApplicationERC20Pricing",
    branches: ["main"],
    files: ["./out/ApplicationERC20Pricing.sol/ApplicationERC20Pricing.json"],
  },
  {
    name: "ApplicationERC721Pricing",
    branches: ["main"],
    files: ["./out/ApplicationERC721Pricing.sol/ApplicationERC721Pricing.json"],
  },
  {
    name: "ApplicationHandler",
    branches: ["main"],
    files: ["./out/ApplicationHandler.sol/ApplicationHandler.json"],
  },
  {
    name: "AppManager",
    branches: ["main"],
    files: ["./out/AppManager.sol/AppManager.json"],
  },
  {
    name: "HandlerDiamond",
    branches: ["main"],
    files: [
      "./out/ERC20HandlerMainFacet.sol/ERC20HandlerMainFacet.json",
      "./out/ERC20TaggedRuleFacet.sol/ERC20TaggedRuleFacet.json",
      "./out/ERC20NonTaggedRuleFacet.sol/ERC20NonTaggedRuleFacet.json",
      "./out/FeesFacet.sol/FeesFacet.json",
      "./out/ERC721HandlerMainFacet.sol/ERC721HandlerMainFacet.json",
      "./out/ERC721TaggedRuleFacet.sol/ERC721TaggedRuleFacet.json",
      "./out/ERC721NonTaggedRuleFacet.sol/ERC721NonTaggedRuleFacet.json",
      "./out/TradingRuleFacet.sol/TradingRuleFacet.json",
    ],
  },
  {
    name: "OracleApproved",
    branches: ["main"],
    files: ["./out/OracleApproved.sol/OracleApproved.json"],
  },
  {
    name: "OracleDenied",
    branches: ["main"],
    files: ["./out/OracleDenied.sol/OracleDenied.json"],
  },
  {
    name: "PauseRules",
    branches: ["main"],
    files: ["./out/PauseRules.sol/PauseRules.json"],
  },
  {
    name: "ApplicationERC20",
    branches: ["main"],
    files: ["./out/ApplicationERC20.sol/ApplicationERC20.json"],
  },
  {
    name: "ApplicationERC721",
    branches: ["main"],
    files: ["./out/ApplicationERC721.sol/ApplicationERC721.json"],
  },
  {
    name: "RuleDiamond",
    branches: ["main"],
    files: [
      "./out/ApplicationAccessLevelProcessorFacet.sol/ApplicationAccessLevelProcessorFacet.json",
      "./out/ApplicationPauseProcessorFacet.sol/ApplicationPauseProcessorFacet.json",
      "./out/ApplicationRiskProcessorFacet.sol/ApplicationRiskProcessorFacet.json",
      "./out/ERC20RuleProcessorFacet.sol/ERC20RuleProcessorFacet.json",
      "./out/ERC20TaggedRuleProcessorFacet.sol/ERC20TaggedRuleProcessorFacet.json",
      "./out/ERC721RuleProcessorFacet.sol/ERC721RuleProcessorFacet.json",
      "./out/ERC721TaggedRuleProcessorFacet.sol/ERC721TaggedRuleProcessorFacet.json",
      //"./out/FeeRuleProcessorFacet.sol/FeeRuleProcessorFacet.json",
      "./out/RuleApplicationValidationFacet.sol/RuleApplicationValidationFacet.json",
      "./out/AppRuleDataFacet.sol/AppRuleDataFacet.json",
      //"./out/FeeRuleDataFacet.sol/FeeRuleDataFacet.json",
      "./out/RuleDataFacet.sol/RuleDataFacet.json",
      "./out/TaggedRuleDataFacet.sol/TaggedRuleDataFacet.json",
    ],
  },
]

const createOutputDir = (dir) => (!existsSync(dir) ? mkdirSync(dir, { recursive: true }) : undefined)

const readAndGetJsonABI = async (filename) => {
  try {
    const abiFile = await fs.readFile(filename, { encoding: "utf-8" })
    return JSON.parse(abiFile).abi
  } catch (err) {
    console.log("Could not open file: ", filename)
    process.exit(1)
  }
}

createOutputDir(outputDir)

ABIFiles.filter((f) => f.branches.includes(repoBranch)).forEach(
  async (abiFile) => {
    const abi =
      abiFile.files.length == 1
        ? await readAndGetJsonABI(abiFile.files[0])
        : (
            await Promise.all(
              abiFile.files.flatMap(
                async (filename) => await readAndGetJsonABI(filename)
              )
            )
          ).flat()

    if (abi) {
      fs.writeFile(
        `./${outputDir}/${abiFile.name}.json`,
        JSON.stringify(abi),
        (err) => {
          if (err) {
            console.log("Could not write file: ", abiFile.name)
            process.exit(1)
          }
        }
      )
    }
  }
)
