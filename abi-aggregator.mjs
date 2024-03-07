import fs from "fs/promises"

const ABIFiles = [
  {
    name: "ApplicationERC20Pricing",
    files: ["./out/ApplicationERC20Pricing.sol/ApplicationERC20Pricing.json"],
  },
  {
    name: "ApplicationERC721Pricing",
    files: ["./out/ApplicationERC721Pricing.sol/ApplicationERC721Pricing.json"],
  },
  {
    name: "ApplicationHandler",
    files: ["./out/ApplicationHandler.sol/ApplicationHandler.json"],
  },
  {
    name: "AppManager",
    files: ["./out/AppManager.sol/AppManager.json"],
  },
  {
    name: "HandlerDiamond",
    files: [
      "./out/ERC20HandlerMainFacet.sol/ERC20HandlerMainFacet.json",
      "./out/ERC20TaggedRuleFacet.sol/ERC20TaggedRuleFacet.json",
      "./out/ERC20NonTaggedRuleFacet.sol/ERC20NonTaggedRuleFacet.json",
      "./out/FeesFacet.sol/FeesFacet.json",
      "./out/ERC721HandlerMainFacet.sol/ERC721HandlerMainFacet.json",
      "./out/ERC721TaggedRuleFacet.sol/ERC721TaggedRuleFacet.json",
      "./out/ERC721NonTaggedRuleFacet.sol/ERC721NonTaggedRuleFacet.json",
      "./out/TradingRuleFacet.sol/TradingRuleFacet.json",
      "./out/StorageLib.sol/StorageLib.json",
      "./out/RuleStorage.sol/RuleStorage.json",
    ],
  },
  {
    name: "OracleApproved",
    files: ["./out/OracleApproved.sol/OracleApproved.json"],
  },
  {
    name: "OracleDenied",
    files: ["./out/OracleDenied.sol/OracleDenied.json"],
  },
  {
    name: "PauseRules",
    files: ["./out/PauseRules.sol/PauseRules.json"],
  },
  {
    name: "ProtocolAMMCalcConst",
    files: ["./out/ProtocolAMMCalcConst.sol/ProtocolAMMCalcConst.json"],
  },
  {
    name: "ProtocolAMMCalcCP",
    files: ["./out/ProtocolAMMCalcCP.sol/ProtocolAMMCalcCP.json"],
  },
  {
    name: "ProtocolAMMCalcLinear",
    files: ["./out/ProtocolAMMCalcLinear.sol/ProtocolAMMCalcLinear.json"],
  },
  {
    name: "ProtocolAMMCalcSample01",
    files: ["./out/ProtocolAMMCalcSample01.sol/ProtocolAMMCalcSample01.json"],
  },
  {
    name: "ProtocolAMMFactory",
    files: ["./out/ProtocolAMMFactory.sol/ProtocolAMMFactory.json"],
  },
  {
    name: "ProtocolAMMHandler",
    files: ["./out/ProtocolAMMHandler.sol/ProtocolAMMHandler.json"],
  },
  {
    name: "ProtocolERC20",
    files: ["./out/ProtocolERC20.sol/ProtocolERC20.json"],
  },
  {
    name: "ProtocolERC20AMM",
    files: ["./out/ProtocolERC20AMM.sol/ProtocolERC20AMM.json"],
  },
  {
    name: "ProtocolERC721",
    files: ["./out/ProtocolERC721.sol/ProtocolERC721.json"],
  },
  {
    name: "ProtocolERC721AMM",
    files: ["./out/ProtocolERC721AMM.sol/ProtocolERC721AMM.json"],
  },
  {
    name: "ProtocolNFTAMMCalcDualLinear",
    files: [
      "./out/ProtocolNFTAMMCalcDualLinear.sol/ProtocolNFTAMMCalcDualLinear.json",
    ],
  },
  {
    name: "RuleDiamond",
    files: [
      "./out/ApplicationAccessLevelProcessorFacet.sol/ApplicationAccessLevelProcessorFacet.json",
      "./out/ApplicationPauseProcessorFacet.sol/ApplicationPauseProcessorFacet.json",
      "./out/ApplicationRiskProcessorFacet.sol/ApplicationRiskProcessorFacet.json",
      "./out/ERC20RuleProcessorFacet.sol/ERC20RuleProcessorFacet.json",
      "./out/ERC20TaggedRuleProcessorFacet.sol/ERC20TaggedRuleProcessorFacet.json",
      "./out/ERC721RuleProcessorFacet.sol/ERC721RuleProcessorFacet.json",
      "./out/ERC721TaggedRuleProcessorFacet.sol/ERC721TaggedRuleProcessorFacet.json",
      "./out/FeeRuleProcessorFacet.sol/FeeRuleProcessorFacet.json",
      "./out/RuleApplicationValidationFacet.sol/RuleApplicationValidationFacet.json",
      "./out/AppRuleDataFacet.sol/AppRuleDataFacet.json",
      "./out/FeeRuleDataFacet.sol/FeeRuleDataFacet.json",
      "./out/RuleDataFacet.sol/RuleDataFacet.json",
      "./out/TaggedRuleDataFacet.sol/TaggedRuleDataFacet.json",
    ],
  },
]

const readAndGetABI = async (filename) => {
  try {
    const abiFile = await fs.readFile(filename, { encoding: "utf-8" })
    return JSON.parse(abiFile).abi
  } catch (err) {
    console.log("Could not open file: ", filename)
  }
}

ABIFiles.forEach(async (abiFile) => {
  const abi =
    abiFile.files.length == 1
      ? await readAndGetABI(abiFile.files[0])
      : (
          await Promise.all(
            abiFile.files.flatMap(
              async (filename) => await readAndGetABI(filename)
            )
          )
        ).flat()

  if (abi) {
    fs.writeFile(
      `./doom-abis/${abiFile.name}.json`,
      JSON.stringify(abi),
      (err) => {
        if (err) console.log("Could not write file: ", abiFile.name)
      }
    )
  }
})
